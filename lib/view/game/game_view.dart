import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../controller/game/game_controller.dart';
import '../../model/unit.dart';

class GameView extends StatelessWidget {
  final double _cellSize = (1.sw - 10.sp) / 11 - 1.sp;
  final double _imageSize = min(
    (0.7.sh - 1.sw) / 4, // 첫 번째 값
    1.sw / 10, // 두 번째 값
  );

  GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.put(GameController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        title: Text('배치하기'),
        actions: [
          IconButton(
            icon: Icon(Icons.rotate_right),
            onPressed: () {
              controller.rotateSelectedUnit();
            },
            tooltip: '유닛 회전',
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              controller.completeDeployment();
            },
            tooltip: '배치 완료',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 게임판
              Obx(() {
                return Stack(
                  children: [
                    // 그리드 배경
                    Container(
                      width: _cellSize * 10 + 2.sp * 11,
                      height: _cellSize * 10 + 2.sp * 11,
                      child: Table(
                        border:
                            TableBorder.all(color: Colors.blue, width: 2.sp),
                        defaultColumnWidth: FixedColumnWidth(_cellSize),
                        children: [
                          // 첫 번째 줄 (헤더)
                          TableRow(
                            children: List.generate(
                              11,
                              (index) => Container(
                                alignment: Alignment.center,
                                height: _cellSize,
                                child: index == 0
                                    ? Text('') // 빈 셀
                                    : Text(
                                        index.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ),
                          // 나머지 줄 (A~J 행)
                          ...List.generate(
                            10,
                            (rowIndex) => TableRow(
                              children: List.generate(
                                11,
                                (colIndex) {
                                  if (colIndex == 0) {
                                    // 첫 번째 열 (행 레이블)
                                    return Container(
                                      alignment: Alignment.center,
                                      height: _cellSize,
                                      child: Text(
                                        String.fromCharCode(
                                            65 + rowIndex), // A~J
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  } else {
                                    // 데이터 셀 - 이미지는 그리드 위에 오버레이로 표시
                                    return GestureDetector(
                                      onTap: () {
                                        if (controller
                                            .isDeploymentComplete.value) {
                                          return;
                                        }

                                        if (controller.selectedUnitType.value !=
                                            null) {
                                          controller.placeUnit(
                                            controller.selectedUnitType.value!,
                                            rowIndex,
                                            colIndex - 1,
                                          );
                                        } else {
                                          // 배치된 유닛 선택 (이동 기능)
                                          String cellValue = controller.grid
                                              .value[rowIndex][colIndex - 1];
                                          // 'cellValue'는 유닛 유형 ID ('u1', 'u2', 'u3')이므로, placedUnits에서 해당 유형의 첫 번째 유닛을 찾습니다.
                                          // 고유 ID가 있으므로, 일치하는 유닛을 찾아 선택합니다.
                                          Unit? unit = controller.placedUnits
                                              .firstWhereOrNull(
                                            (u) =>
                                                u.id.startsWith(cellValue) &&
                                                u.isPlaced,
                                          );
                                          if (unit != null) {
                                            controller.selectPlacedUnit(unit);
                                          }
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: _cellSize,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.blue),
                                          color: controller.grid.value[rowIndex]
                                                      [colIndex - 1] ==
                                                  'empty'
                                              ? Colors.lightBlue[50]
                                              : Colors.grey,
                                        ),
                                        // 이미지는 여기서 렌더링하지 않음
                                        child: null,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 유닛 이미지 오버레이
                    ...controller.placedUnits.map((u) {
                      if (u.startRow == null || u.startCol == null) {
                        return Container();
                      }

                      return Positioned(
                        left: (u.startCol! + 1) *
                            (_cellSize), // 셀 크기와 테두리 고려 + 제목행
                        top: (u.startRow! + 1) *
                            (_cellSize), // 셀 크기와 테두리 고려 + 제목열
                        width: (u.width * _cellSize) + (u.width - 1) * 2.sp,
                        height: (u.height * _cellSize) + (u.height - 1) * 2.sp,
                        child: GestureDetector(
                          onTap: () {
                            if (!controller.isDeploymentComplete.value) {
                              controller.selectPlacedUnit(u);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: controller.selectedUnitType.value == u
                                  ? Border.all(color: Colors.red, width: 3.sp)
                                  : null,
                            ),
                            child: Image.asset(
                              _getUnitImagePath(
                                  u.id.split('_')[0]), // 유닛 유형에 맞는 이미지 경로
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),

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
                                  _getUnitImagePath(unitType.id),
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
    );
  }

  String _getUnitImagePath(String unitTypeId) {
    switch (unitTypeId) {
      case 'u1':
        return 'assets/units/hippo_exist.png';
      case 'u2':
        return 'assets/units/crocodile_exist.png';
      case 'u3':
        return 'assets/units/log_exist.png';
      default:
        return 'assets/units/none.png';
    }
  }
}
