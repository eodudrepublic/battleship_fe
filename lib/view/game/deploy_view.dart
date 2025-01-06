import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../controller/game/game_controller.dart';
import '../../model/unit.dart';
import 'widget/game_board_view.dart';

class DeployView extends StatelessWidget {
  final double _cellSize = (1.sw - 10.sp) / 11 - 1.sp;
  final double _borderWidth = 2.sp;
  final double _imageSize = min(
    (0.7.sh - 1.sw) / 4, // 첫 번째 값
    1.sw / 10, // 두 번째 값
  );

  DeployView({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.put(GameController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        title: Text('배치하기'),
        actions: [
          // TODO : 아직 구현되지 않은 기능
          // TODO 1 : 유닛 회전 -> 회전한 이미지 저장 -> 유닛 회전하면 회전한 이미지가 들어오도록
          // TODO 2 : 배치 완료 -> 배치 완료하면 게임 페이지로 넘어가도록
          // IconButton(
          //   icon: Icon(Icons.rotate_right),
          //   onPressed: () {
          //     controller.rotateSelectedUnit();
          //   },
          //   tooltip: '유닛 회전',
          // ),
          // IconButton(
          //   icon: Icon(Icons.check),
          //   onPressed: () {
          //     controller.completeDeployment();
          //   },
          //   tooltip: '배치 완료',
          // ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 게임판
              DeployBoardView(
                cellSize: _cellSize,
                borderWidth: _borderWidth,
                controller: controller, // 통합된 컨트롤러 전달
                onUnitTap: (Unit? unit) {
                  if (unit == null) {
                    // 유닛 배치 후 선택 해제
                    controller.selectedUnitType.value = null;
                  } else {
                    // 유닛 선택 시 이동 처리
                    controller.selectPlacedUnit(unit);
                    // 추가적인 이동 로직을 여기에 구현할 수 있습니다.
                    // 예: 새로운 위치로 드래그 앤 드롭
                  }
                },
              ),

              /// 배치할 유닛 목록
              Obx(() {
                return Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: controller.unitTypes.map((unitType) {
                      int remaining = controller.unitCounts[unitType.id] ?? 0;
                      bool isNone = remaining <= 0;
                      return GestureDetector(
                        onTap: () {
                          if (remaining > 0 &&
                              !controller.isDeploymentComplete.value) {
                            controller.selectUnitType(unitType);
                          }
                        },
                        child: Opacity(
                          opacity: remaining > 0 &&
                                  !controller.isDeploymentComplete.value
                              ? 1.0
                              : 0.5,
                          child: Column(
                            children: [
                              Container(
                                height: _imageSize * 3,
                                width: _imageSize * 3,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  _getUnitImagePath(unitType.id, isNone),
                                  height: _imageSize * 2,
                                  width: _imageSize * 3,
                                ),
                              ),
                              SizedBox(height: 5.sp),
                              Text(
                                unitType.name,
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '(${unitType.width} x ${unitType.height})',
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '남은 개수: $remaining',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6.sp),
                              SvgPicture.asset(
                                'assets/icons/turn.svg',
                                height: 22.sp,
                                width: 22.sp,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      // TODO : 배치 초기화 -> 나중에 쓸거니까 일단 주석처리
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // 배치 초기화 버튼
      //     controller.resetPlacement();
      //   },
      //   tooltip: '배치 초기화',
      //   child: Icon(Icons.refresh),
      // ),
    );
  }

  String _getUnitImagePath(String unitTypeId, bool isNone) {
    switch (unitTypeId) {
      case 'u1':
        return isNone
            ? 'assets/units/hippo_none.png'
            : 'assets/units/hippo_exist.png';
      case 'u2':
        return isNone
            ? 'assets/units/crocodile_none.png'
            : 'assets/units/crocodile_exist.png';
      case 'u3':
        return isNone
            ? 'assets/units/log_none.png'
            : 'assets/units/log_exist.png';
      default:
        return 'assets/units/none.png';
    }
  }
}
