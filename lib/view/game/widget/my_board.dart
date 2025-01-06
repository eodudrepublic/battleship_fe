import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_colors.dart';
import '../../../common/utils/logger.dart';
import '../../../controller/game/game_controller.dart';

class MyBoardView extends StatelessWidget {
  final double cellSize;
  final double borderWidth;
  final GameController controller;

  const MyBoardView({
    super.key,
    required this.cellSize,
    required this.borderWidth,
    required this.controller,
  });

  // TODO : 현재 배치된 이미지 위치가 살짝 이상함 -> 수정 필요
  /// 배치된 유닛(hippo, crocodile, log) 이미지 경로를 반환
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

  /// 내 보드 위 마커(enemy_hit, enemy_miss 등) 이미지 경로를 반환
  String _getMarkerImagePath(String marker) {
    switch (marker) {
      case 'enemy_hit':
        return 'assets/markers/enemy_hit.png';
      case 'enemy_miss':
        return 'assets/markers/enemy_miss_2.png';
      default:
        return ''; // empty
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info("Building MyBoardView");
    return Obx(() {
      return Stack(
        children: [
          // -------------------------
          // (1) 테이블 (10x10) + 좌표 헤더
          // -------------------------
          Table(
            border: TableBorder.all(color: Colors.blue, width: borderWidth),
            defaultColumnWidth: FixedColumnWidth(cellSize),
            children: [
              // 헤더 (열 번호)
              TableRow(
                children: List.generate(
                  11,
                  (index) => Container(
                    alignment: Alignment.center,
                    height: cellSize,
                    color: AppColors.boardColor,
                    child: index == 0
                        ? const Text('')
                        : Text(
                            index.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              // A~J 행
              ...List.generate(
                10,
                (rowIndex) => TableRow(
                  children: List.generate(
                    11,
                    (colIndex) {
                      if (colIndex == 0) {
                        // 행 레이블 (A, B, C...)
                        return Container(
                          alignment: Alignment.center,
                          height: cellSize,
                          color: AppColors.boardColor,
                          child: Text(
                            String.fromCharCode(65 + rowIndex),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      } else {
                        // 실제 데이터 셀 (enemy_hit/miss 마커 표시)
                        final marker =
                            controller.myBoardMarkers[rowIndex][colIndex - 1];
                        final markerPath = _getMarkerImagePath(marker);

                        return Container(
                          alignment: Alignment.center,
                          height: cellSize,
                          color: AppColors.boardColor,
                          child: markerPath.isNotEmpty
                              ? Image.asset(markerPath, fit: BoxFit.cover)
                              : null,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // -------------------------
          // (2) 배치된 유닛 이미지 오버레이
          // -------------------------
          ...controller.placedUnits.map((u) {
            if (u.startRow == null || u.startCol == null) {
              return Container();
            }
            // 유닛이 시작되는 위치에 맞춰 Positioned로 렌더링
            return Positioned(
              left: (u.startCol! + 1) * cellSize +
                  (u.startCol!) * borderWidth, // 테두리 고려
              top: (u.startRow! + 1) * cellSize + (u.startRow!) * borderWidth,
              width: (u.isHorizontal ? u.width : u.height) * cellSize +
                  ((u.isHorizontal ? u.width : u.height) - 1) * borderWidth,
              height: (u.isHorizontal ? u.height : u.width) * cellSize +
                  ((u.isHorizontal ? u.height : u.width) - 1) * borderWidth,
              child: Image.asset(
                _getUnitImagePath(u.id.split('_')[0]),
                fit: BoxFit.contain,
              ),
            );
          }),
        ],
      );
    });
  }
}
