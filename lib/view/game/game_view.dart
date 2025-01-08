import 'dart:async';
import 'package:battleship_fe/common/app_colors.dart';
import 'package:battleship_fe/view/game/widget/enemy_board.dart';
import 'package:battleship_fe/view/game/widget/my_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/utils/logger.dart';
import '../../../controller/game/game_controller.dart';
import '../../model/game_state.dart';
import '../../model/user_model.dart';
import '../../service/game_service.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  /// GameController (board 표시 등을 위해)
  final GameController controller = Get.find<GameController>();

  /// 게임 서버 통신을 위한 GameService
  final GameService _gameService = GameService();

  Timer? _defenderCheckTimer;

  @override
  void initState() {
    super.initState();
    _startDefenderCheckTimer(); // 처음 진입 시, 혹시 내가 수비자라면 폴링 시작
  }

  @override
  void dispose() {
    _defenderCheckTimer?.cancel();
    super.dispose();
  }

  /// 5초 간격으로 수비자 Damage 상태 확인
  void _startDefenderCheckTimer() {
    // 이미 존재하던 타이머가 있으면 해제
    _defenderCheckTimer?.cancel();

    int elapsed = 0;
    _defenderCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted || GameState().isGameOver) {
        timer.cancel();
        return;
      }
      elapsed += 5;
      // 필요에 따라 제한 시간을 조정 (여기서는 100초로 가정)
      if (elapsed > 100) {
        timer.cancel();
        return;
      }

      // 내가 수비자(즉, isMyTurn == false)일 때만 체크
      if (GameState().isMyTurn == false) {
        final result = await _gameService.checkDamageStatusAsDefender(
          GameState().roomCode!,
        );
        final damageStatus = result["damage_status"];
        final attackPos = result["attack_position"] ?? "";
        final gameStatus = result["game_status"];

        // "damage_status" 가 "damaged"/"missed" 라면 => 공격이 들어옴
        if (damageStatus == "damaged" || damageStatus == "missed") {
          // 내 보드에 히트/미스 표시
          _markMyBoard(attackPos, damageStatus);

          if (gameStatus == "completed") {
            // 게임 종료 - 수비자 패배
            GameState().endGame();
            Get.snackbar("패배", "상대의 마지막 공격이 적중했습니다!");
            Log.wtf('패배바라 : 상대의 마지막 공격이 적중했습니다!');
            Get.offNamed("/lose");
          } else {
            // 공격 끝 -> 턴 종료 + 공격/수비 교대
            await _gameService.endTurn(GameState().roomCode!);
            GameState().toggleTurn();
          }
          timer.cancel();
        }
      }
    });
  }

  /// 공격자가 '공격하기' 버튼을 누를 때
  void _onAttackButtonPressed() async {
    // 내가 공격자( isMyTurn == true )인지 확인
    if (GameState().isMyTurn == false || GameState().isGameOver) return;

    // 예: controller.selectedAttackCell.value -> [row, col]
    final selectedCell = controller.selectedAttackCell.value;
    if (selectedCell == null) return;

    final row = selectedCell[0];
    final col = selectedCell[1];

    // (1) row,col -> "A1" 형태 문자열로 변환
    final String cellPos = _convertRowColToString(row, col);

    // (2) 공격 수행
    final result = await _gameService.performAttack(
      GameState().roomCode!,
      AppUser().id!, // 나의 ID
      GameState().opponentId!, // 상대방 ID
      cellPos,
    );

    final damageStatus = result["damage_status"];
    final gameStatus = result["game_status"];

    // (3) 내 EnemyBoard 에 히트/미스 표시
    if (damageStatus == "damaged") {
      _markEnemyBoard(cellPos, isHit: true);
    } else if (damageStatus == "missed") {
      _markEnemyBoard(cellPos, isHit: false);
    }

    // (4) 게임 종료 여부
    if (gameStatus == "completed") {
      // 내가 최종 성공 -> 승리
      GameState().endGame();
      Get.snackbar("승리", "게임에서 승리하였습니다!");
      Log.info('승리바라 : 마지막 공격이 적중했습니다!');
      Get.offNamed("/win");
    } else {
      // 공격 끝 -> 공격/수비 교대 (턴 종료 안함)
      GameState().toggleTurn();

      // 이제 내가 수비자가 되었다면, 다시 _startDefenderCheckTimer 실행
      if (GameState().isMyTurn == false && !GameState().isGameOver) {
        _startDefenderCheckTimer();
      }
    }
  }

  /// "A1" -> (row=0, col=0)
  void _markMyBoard(String cellPos, String damageStatus) {
    // 파싱
    final parsed = _convertStringToRowCol(cellPos);
    if (parsed == null) return;
    final row = parsed[0];
    final col = parsed[1];

    // damageStatus = "damaged" or "missed"
    if (damageStatus == "damaged") {
      controller.myBoardMarkers[row][col] = 'enemy_hit';
    } else {
      controller.myBoardMarkers[row][col] = 'enemy_miss';
    }
    controller.myBoardMarkers.refresh();
  }

  /// 공격자가 Enemy보드(상대 보드)에 히트/미스 표시
  void _markEnemyBoard(String cellPos, {required bool isHit}) {
    final parsed = _convertStringToRowCol(cellPos);
    if (parsed == null) return;
    final row = parsed[0];
    final col = parsed[1];

    controller.enemyBoardMarkers[row][col] = isHit ? 'my_hit' : 'my_miss';
    controller.enemyBoardMarkers.refresh();
  }

  /// "A1" -> (0,0)
  /// "C5" -> (2,4)
  List<int>? _convertStringToRowCol(String pos) {
    if (pos.length < 2) return null;
    // 첫 문자: A~J
    final rowChar = pos[0].toUpperCase();
    final colStr = pos.substring(1);

    final rowIndex = rowChar.codeUnitAt(0) - 'A'.codeUnitAt(0);
    final colIndex = int.tryParse(colStr) ?? -1;
    if (rowIndex < 0 || rowIndex > 9) return null; // 범위체크 (A~J)
    if (colIndex < 1 || colIndex > 10) return null; // 1~10

    return [rowIndex, colIndex - 1]; // 0-based
  }

  /// (0,0) -> "A1"
  String _convertRowColToString(int row, int col) {
    final rowChar = String.fromCharCode('A'.codeUnitAt(0) + row);
    final colStr = (col + 1).toString();
    return '$rowChar$colStr';
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
              // (1) 내 보드
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

              // (2) 적 보드
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

              // (3) 공격하기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TODO : 남은 시간 표시
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
                  // 공격 버튼
                  Obx(() {
                    bool canAttack =
                        (controller.selectedAttackCell.value != null) &&
                            (GameState().isMyTurn == true) &&
                            (!GameState().isGameOver);

                    return SizedBox(
                      height: 0.06.sh,
                      width: 0.30.sw,
                      child: ElevatedButton(
                        onPressed: canAttack ? _onAttackButtonPressed : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
