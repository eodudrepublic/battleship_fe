import 'package:battleship_fe/common/app_colors.dart';
import 'package:battleship_fe/view/game/widget/enemy_board.dart';
import 'package:battleship_fe/view/game/widget/my_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/game/game_controller.dart';
import '../../common/utils/logger.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    Log.info("Building GameView");
    final GameController controller = Get.put(GameController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // -------------------------
            // (1) 상단 파란색 컨테이너 (내 보드)
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
            // (2) 하단 빨간색 컨테이너 (적 보드)
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
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}
