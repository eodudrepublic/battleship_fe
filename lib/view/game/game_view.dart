import 'package:battleship_fe/view/game/widget/enemy_board.dart';
import 'package:battleship_fe/view/game/widget/my_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/game/game_controller.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    print("Log.debug: Building GameView");
    final GameController controller = Get.put(GameController());

    return Scaffold(
      backgroundColor: const Color(0xFFE0F0F0),
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
              color: Colors.blue[100],
              child: Container(
                height: 0.35.sh - 40.sp,
                width: 0.35.sh - 40.sp,
                color: Colors.blue,
                child: MyBoardView(
                  cellSize: ((0.35.sh - 40.sp) - 11) / 11, // 대략적 계산 (테이블+테두리)
                  borderWidth: 1,
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
              color: Colors.red[100],
              child: EnemyBoardView(
                cellSize: ((1.sw - 10.sp) - 11) / 11, // 역시 대략적 계산
                borderWidth: 1,
                controller: controller,
              ),
            ),
            SizedBox(height: 10.sp),

            // -------------------------
            // (3) 공격 버튼
            // -------------------------
            Obx(() {
              bool canAttack = (controller.selectedAttackCell.value != null);
              return ElevatedButton(
                onPressed: canAttack
                    ? () {
                        print(
                            "Log.debug: Attempting to attack selected cell...");
                        controller.attackSelectedCell();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text("공격하기"),
              );
            }),
            SizedBox(height: 10.sp),
          ],
        ),
      ),
    );
  }
}
