import 'package:battleship_fe/common/app_colors.dart';
import 'package:battleship_fe/view/game/widget/enemy_board.dart';
import 'package:battleship_fe/view/game/widget/my_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/utils/logger.dart';
import '../../../controller/game/game_controller.dart';
import '../../../service/game_service.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  /// GameController (board 표시 등을 위해)
  final GameController controller = Get.find<GameController>();

  /// 게임 서버 통신을 테스트하기 위한 GameService
  final GameService _gameService = GameService();

  /// 예시) 두 사용자 ID
  int user1Id = 25;
  int user2Id = 50;

  /// attack = 1이면 user1이 공격자, 2면 user2가 공격자
  int attack = 1;

  /// 현재 생성된 방 코드
  String? _roomCode;

  /// 콘솔에만 찍히게 할 헬퍼
  void _log(String message) {
    Log.info(message);
  }

  /// 현재 공격자/수비자 ID
  int get _attackerId => (attack == 1) ? user1Id : user2Id;
  int get _defenderId => (attack == 1) ? user2Id : user1Id;

  /// 공격자/수비자 텍스트
  String get _attackerString =>
      attack == 1 ? 'User1($user1Id)' : 'User2($user2Id)';
  String get _defenderString =>
      attack == 1 ? 'User2($user2Id)' : 'User1($user1Id)';

  /// 1) 방 생성
  Future<void> _createInvite() async {
    try {
      final result = await _gameService.createInvite(_attackerId);
      _roomCode = result['room_code'];
      _log(
          "방 생성 완료\nRoomCode: $_roomCode\nInviteLink: ${result['invite_link']}");
    } catch (e) {
      _log("방 생성 실패: $e");
    }
  }

  /// 2) 방 참가
  Future<void> _joinRoom() async {
    if (_roomCode == null) {
      _log("먼저 방을 생성(createInvite)하세요.");
      return;
    }
    try {
      final result = await _gameService.joinRoom(_roomCode!, _defenderId);
      _log("""
방 참가 성공
is_matched: ${result["is_matched"]}
room_code: ${result["room_code"]}
opponent: ${result["opponent"]}
is_first: ${result["is_first"]}
      """);
    } catch (e) {
      _log("방 참가 실패: $e");
    }
  }

  /// 3) 공격 시퀀스 테스트
  ///    performAttack -> getAttackStatus -> sendDamageStatus -> getDamageStatus -> endTurn
  Future<void> _attackSequence() async {
    if (_roomCode == null) {
      _log("먼저 방을 생성(createInvite) 및 참가(joinRoom)하세요.");
      return;
    }

    // (1) 공격자 -> performAttack
    try {
      final performAttackResult = await _gameService.performAttack(
        _roomCode!,
        _attackerId,
        _defenderId,
        'A', // 예시 위치 X
        1, // 예시 위치 Y
      );
      _log(
          "공격 수행: attackStatus = ${performAttackResult ? 'attack' : 'not attack'}");

      // 공격 성공/실패 여부를 이용해 enemyBoardMarkers 업데이트 예시
      // 여기서는 row=0, col=0 위치를 공격했다고 가정
      // 필요에 따라 실제 (A1) -> (row=0, col=0) 매핑
      final rowIndex = 0;
      final colIndex = 0;
      if (performAttackResult) {
        // 임의로 "my_hit" 표시
        controller.enemyBoardMarkers[rowIndex][colIndex] = 'my_hit';
      } else {
        controller.enemyBoardMarkers[rowIndex][colIndex] = 'my_miss';
      }
      controller.enemyBoardMarkers.refresh();
    } catch (e) {
      _log("공격 수행 실패: $e");
      return;
    }

    // (2) 수비자 -> getAttackStatus
    try {
      final attackStatusResponse =
          await _gameService.getAttackStatus(_roomCode!);
      _log("""
공격 상태 조회 성공:
attackStatus: ${attackStatusResponse.attackStatus}
attackPositionX: ${attackStatusResponse.attackPositionX}
attackPositionY: ${attackStatusResponse.attackPositionY}
damageStatus: ${attackStatusResponse.damageStatus}
      """);

      // 수비자가 공격받았다고 판단되면, 실제 내 보드에 enemy_hit/ enemy_miss 표기 가능
      // 예: attackPositionX='A'(row=0), attackPositionY=1(col=0) 로 가정
      if (attackStatusResponse.attackStatus == 'attack') {
        // 간단하게 "enemy_hit" 표시
        final rowIndex = 0;
        final colIndex = 0;
        controller.enemyAttacksCell(rowIndex, colIndex);
        // 내부적으로 myBoardMarkers[rowIndex][colIndex] = 'enemy_hit' or 'enemy_miss'
      }
    } catch (e) {
      _log("공격 상태 조회 실패: $e");
      return;
    }

    // (3) 수비자 -> sendDamageStatus (맞았다고 가정)
    try {
      final isFinished = await _gameService.sendDamageStatus(
        _roomCode!,
        'A', // 공격 위치 x
        1, // 공격 위치 y
        true, // 대미지 여부
        false, // 게임 종료 여부
      );
      _log("데미지 리포트 전송 완료, 게임 종료 여부: $isFinished");
    } catch (e) {
      _log("데미지 상태 전달 실패: $e");
      return;
    }

    // (4) 공격자 -> getDamageStatus
    try {
      final damageStatusResponse =
          await _gameService.getDamageStatus(_roomCode!);
      _log("""
공격 결과(대미지) 조회 성공:
attackStatus: ${damageStatusResponse.attackStatus}
damageStatus: ${damageStatusResponse.damageStatus}
      """);
    } catch (e) {
      _log("대미지 결과 조회 실패: $e");
      return;
    }

    // (5) 공격자 -> endTurn (턴 종료 후, 공격자/수비자 교대)
    try {
      final endTurnResult = await _gameService.endTurn(_attackerId, _roomCode!);
      _log("턴 종료: ${endTurnResult ? '성공(상대에게 턴 넘어감)' : '실패'}");

      if (endTurnResult) {
        setState(() {
          attack = (attack == 1) ? 2 : 1;
        });
      }
    } catch (e) {
      _log("턴 종료 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info("Building GameView");

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // -------------------------
              // (1) 상단 : 내 보드 표시
              // -------------------------
              Container(
                height: 0.35.sh,
                padding: EdgeInsets.only(top: 40.sp),
                alignment: Alignment.center,
                child: Container(
                  height: 0.35.sh - 40.sp,
                  width: 0.35.sh - 40.sp,
                  alignment: Alignment.center,
                  child: MyBoardView(
                    cellSize: ((0.35.sh - 40.sp) - 11.sp) / 11,
                    borderWidth: 1.sp,
                    controller: controller,
                  ),
                ),
              ),
              SizedBox(height: 10.sp),

              // -------------------------
              // (2) 하단 : 적 보드 표시
              // -------------------------
              Container(
                height: 1.sw - 10.sp,
                width: 1.sw - 10.sp,
                alignment: Alignment.center,
                child: EnemyBoardView(
                  cellSize: ((1.sw - 10.sp) - 22.sp) / 11,
                  borderWidth: 2.sp,
                  controller: controller,
                ),
              ),
              SizedBox(height: 10.sp),

              // -------------------------
              // (3) 공격하기 버튼 (원래 GameView에 있던 기능)
              // -------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TODO : 남은 배치시간 받아서 표시하도록 (서버 연결 필요)
                  Container(
                    height: 0.06.sh,
                    width: 0.30.sw,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.timeWidgetColor,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Text(
                      "00:57",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Obx(() {
                    bool canAttack =
                        (controller.selectedAttackCell.value != null);
                    return SizedBox(
                      height: 0.06.sh,
                      width: 0.30.sw,
                      child: ElevatedButton(
                        onPressed: canAttack
                            ? () {
                                Log.debug(
                                    "Attempting to attack selected cell...");
                                controller.attackSelectedCell();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.attackButtonColor,
                          disabledBackgroundColor: AppColors.timeWidgetColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                        ),
                        child: Text(
                          "공격하기",
                          style: TextStyle(
                            color: canAttack ? Colors.white : Colors.grey,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),

              SizedBox(height: 10.sp),
              const Divider(thickness: 2, height: 2),

              // -------------------------
              // (4) [추가] GameServiceTest와 유사한 버튼들
              // -------------------------
              // 화면에 텍스트는 표시하지 않고, 콘솔 출력만 하도록 구성
              Text(
                  "현재 공격자: $_attackerString / 수비자: $_defenderString\nRoomCode: $_roomCode"),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    attack = (attack == 1) ? 2 : 1;
                  });
                  _log("공격자/수비자 교체: $_attackerString -> $_defenderString");
                },
                child: const Text("공격자 <-> 수비자 교체"),
              ),
              ElevatedButton(
                onPressed: _createInvite,
                child: const Text("방 생성 (createInvite)"),
              ),
              ElevatedButton(
                onPressed: _joinRoom,
                child: const Text("방 참가 (joinRoom)"),
              ),
              ElevatedButton(
                onPressed: _attackSequence,
                child: const Text("공격 시퀀스 테스트 (performAttack 등)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
