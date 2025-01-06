import 'package:battleship_fe/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/game/game_controller.dart';
import '../../../model/unit.dart';

typedef OnUnitTapCallback = void Function(Unit? unit);

class DeployBoardView extends StatelessWidget {
  final double cellSize;
  final double borderWidth;
  final GameController controller;
  final OnUnitTapCallback onUnitTap;

  const DeployBoardView({
    super.key,
    required this.cellSize,
    required this.borderWidth,
    required this.controller,
    required this.onUnitTap,
  });

  String _getUnitImagePath(String unitTypeId) {
    switch (unitTypeId) {
      case 'u1':
        return 'assets/units/hippo_ride.png';
      case 'u2':
        return 'assets/units/crocodile_ride.png';
      case 'u3':
        return 'assets/units/log_ride.png';
      default:
        return 'assets/units/none.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          // 그리드 배경
          Table(
            border: TableBorder.all(color: Colors.blue, width: borderWidth),
            defaultColumnWidth: FixedColumnWidth(cellSize),
            children: [
              // 첫 번째 줄 (헤더)
              TableRow(
                children: List.generate(
                  11,
                  (index) => Container(
                    alignment: Alignment.center,
                    height: cellSize,
                    color: AppColors.boardColor,
                    child: index == 0
                        ? Text('') // 빈 셀
                        : Text(
                            index.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                          height: cellSize,
                          color: AppColors.boardColor,
                          child: Text(
                            String.fromCharCode(65 + rowIndex), // A~J
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      } else {
                        // 데이터 셀 - 이미지는 그리드 위에 오버레이로 표시
                        return GestureDetector(
                          onTap: () {
                            if (controller.isDeploymentComplete.value) return;

                            if (controller.unitCounts['u1']! > 0 ||
                                controller.unitCounts['u2']! > 0 ||
                                controller.unitCounts['u3']! > 0) {
                              // 유닛 유형이 선택된 경우 배치 시도
                              if (controller.selectedUnitType.value != null) {
                                bool success = controller.placeUnit(
                                  controller.selectedUnitType.value!,
                                  rowIndex,
                                  colIndex - 1,
                                );

                                if (success) {
                                  onUnitTap(null); // 유닛 배치 후 선택 해제
                                }
                              }
                            } else {
                              // 배치된 유닛 선택 (이동 기능)
                              String cellValue =
                                  controller.grid.value[rowIndex][colIndex - 1];
                              Unit? unit =
                                  controller.placedUnits.firstWhereOrNull(
                                (u) => u.id.startsWith(cellValue) && u.isPlaced,
                              );
                              if (unit != null) {
                                onUnitTap(unit);
                              }
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: controller.grid.value[rowIndex]
                                          [colIndex - 1] ==
                                      'empty'
                                  ? AppColors.boardColor
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
          // 배치된 유닛 이미지 오버레이
          ...controller.placedUnits.map((u) {
            if (u.startRow == null || u.startCol == null) {
              return Container();
            }

            return Positioned(
              left: (u.startCol! + 1) * (cellSize), // 셀 크기와 테두리 고려 + 제목행
              top: (u.startRow! + 1) * (cellSize), // 셀 크기와 테두리 고려 + 제목열
              width: (u.isHorizontal ? u.width : u.height) * cellSize +
                  ((u.isHorizontal ? u.width : u.height) - 1) * borderWidth,
              height: (u.isHorizontal ? u.height : u.width) * cellSize +
                  ((u.isHorizontal ? u.height : u.width) - 1) * borderWidth,
              child: GestureDetector(
                onTap: () {
                  if (controller.isDeploymentComplete.value) return;
                  onUnitTap(u);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: controller.selectedPlacedUnit.value == u
                        ? Border.all(color: Colors.red, width: 2.sp)
                        : null,
                  ),
                  child: Image.asset(
                    _getUnitImagePath(u.id.split('_')[0]), // 유닛 유형에 맞는 이미지 경로
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}
