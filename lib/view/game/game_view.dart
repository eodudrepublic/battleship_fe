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

  @override
  void initState() {
    super.initState();

    // ===== 배치 끝나고 넘어온 시점이라 가정 =====
    // 선공이면 -> 공격 타이머 바로 시작
    if (GameState().isMyTurn == true && !GameState().isGameOver) {
      controller.startTurnTimer();
    }
    // 후공이면 -> 수비 폴링 타이머 바로 시작
    else if (!GameState().isGameOver) {
      controller.startDefenderCheckTimer();
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

              // (3) 공격하기 버튼 + 남은 시간
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 남은 턴 시간 표시
                  Obx(() {
                    int minutes = controller.remainingTurnSeconds.value ~/ 60;
                    int seconds = controller.remainingTurnSeconds.value % 60;
                    String formattedTime =
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                    return Container(
                      height: 0.06.sh,
                      width: 0.30.sw,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.timeWidgetColor,
                        borderRadius: BorderRadius.circular(10.sp),
                      ),
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                            fontFamily: 'Sejong',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
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
                            fontFamily: 'Sejong',
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

  /// 공격 버튼 눌렀을 때
  void _onAttackButtonPressed() async {
    if (GameState().isMyTurn == false || GameState().isGameOver) return;

    final selectedCell = controller.selectedAttackCell.value;
    if (selectedCell == null) return;

    final row = selectedCell[0];
    final col = selectedCell[1];
    final cellPos = _convertRowColToString(row, col);

    final result = await _gameService.performAttack(
      GameState().roomCode!,
      AppUser().id!,
      GameState().opponentId!,
      cellPos,
    );

    final damageStatus = result["damage_status"];
    final gameStatus = result["game_status"];

    // Enemy보드에 표시
    if (damageStatus == "damaged") {
      _markEnemyBoard(cellPos, isHit: true);
    } else if (damageStatus == "missed") {
      _markEnemyBoard(cellPos, isHit: false);
    }

    // 게임이 끝났는지 체크
    if (gameStatus == "completed") {
      GameState().endGame();
      Get.snackbar("승리", "게임에서 승리하였습니다!");
      Log.info('승리 : 마지막 공격이 적중했습니다!');
      Get.offNamed("/win");
    } else {
      // 공격 끝 -> 턴 종료
      await _gameService.endTurn(GameState().roomCode!);
      controller.toggleTurn();
    }
  }

  /// 적 보드에 히트/미스 표시
  void _markEnemyBoard(String cellPos, {required bool isHit}) {
    final parsed = controller.convertStringToRowCol(cellPos);
    if (parsed == null) return;
    final row = parsed[0];
    final col = parsed[1];

    controller.enemyBoardMarkers[row][col] = isHit ? 'my_hit' : 'my_miss';
    controller.enemyBoardMarkers.refresh();
  }

  /// (row,col) -> "A1"
  String _convertRowColToString(int row, int col) {
    final rowChar = String.fromCharCode('A'.codeUnitAt(0) + row);
    final colStr = (col + 1).toString();
    return '$rowChar$colStr';
  }
}
