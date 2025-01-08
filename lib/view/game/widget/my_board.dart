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

  /// 내 보드 위 마커(enemy_hit, enemy_miss 등) 이미지 경로를 반환
  String _getMarkerImagePath(String marker) {
    switch (marker) {
      case 'enemy_hit':
        return 'assets/markers/enemy_hit.png';
      case 'enemy_miss':
        return 'assets/markers/enemy_miss_2.png';
      default:
        return ''; // 비어 있음
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
                            style: const TextStyle(
                                fontFamily: 'Sejong',
                                fontWeight: FontWeight.bold),
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
                            style: const TextStyle(
                                fontFamily: 'Sejong',
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      } else {
                        // 실제 데이터 셀 (배경만 표시, 마커는 별도)
                        return Container(
                          alignment: Alignment.center,
                          height: cellSize,
                          color: AppColors.boardColor,
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

            // DeployBoardView와 동일한 방식으로 left, top, width, height를 계산
            // (행/열 레이블이 한 칸씩 있으므로, +1 칸 * cellSize)
            final leftPos = (u.startCol! + 1) * cellSize;
            final topPos = (u.startRow! + 1) * cellSize;

            final w = (u.isHorizontal ? u.width : u.height) * cellSize +
                ((u.isHorizontal ? u.width : u.height) - 1) * borderWidth;
            final h = (u.isHorizontal ? u.height : u.width) * cellSize +
                ((u.isHorizontal ? u.height : u.width) - 1) * borderWidth;

            return Positioned(
              left: leftPos,
              top: topPos,
              width: w,
              height: h,
              // 회전 여부, 배치 여부에 따라 이미 set된 imagePath 사용
              child: Image.asset(
                u.imagePath,
                fit: BoxFit.contain,
              ),
            );
          }),

          // -------------------------
          // (3) 마커 오버레이
          // -------------------------
          ...List.generate(10, (rowIndex) {
            return List.generate(10, (colIndex) {
              final marker = controller.myBoardMarkers[rowIndex][colIndex];
              final markerPath = _getMarkerImagePath(marker);
              if (markerPath.isEmpty) return Container();

              final leftPos = (colIndex + 1) * cellSize;
              final topPos = (rowIndex + 1) * cellSize;

              return Positioned(
                left: leftPos,
                top: topPos,
                width: cellSize,
                height: cellSize,
                child: Image.asset(
                  markerPath,
                  fit: BoxFit.cover,
                ),
              );
            });
          }).expand((element) => element).toList(),
        ],
      );
    });
  }
}
