import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_colors.dart';
import '../../../common/utils/logger.dart';
import '../../../controller/game/game_controller.dart';

class EnemyBoardView extends StatelessWidget {
  final double cellSize;
  final double borderWidth;
  final GameController controller;

  const EnemyBoardView({
    super.key,
    required this.cellSize,
    required this.borderWidth,
    required this.controller,
  });

  String _getMarkerImagePath(String marker) {
    switch (marker) {
      case 'aim':
        return 'assets/markers/aim.png';
      case 'my_hit':
        return 'assets/markers/my_hit.png';
      case 'my_miss':
        return 'assets/markers/my_miss.png';
      default:
        return ''; // empty
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info("Building EnemyBoardView");
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
                        // 적 보드는 유닛을 표시하지 않음
                        // 사용자가 터치하면 'aim' 마커를 표시하도록 함
                        final marker = controller.enemyBoardMarkers[rowIndex]
                            [colIndex - 1];
                        final markerPath = _getMarkerImagePath(marker);

                        return GestureDetector(
                          onTap: () {
                            // TODO : 내 공격 턴일때만 터치 가능하도록 구현
                            // TODO : 공격을 한 셀은 다시 터치하지 못하도록 구현
                            // 내 공격 턴일 때만 가능하다고 가정
                            Log.info(
                                "Tapped enemy board cell [row=$rowIndex, col=${colIndex - 1}]");
                            controller.selectAttackCell(rowIndex, colIndex - 1);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cellSize,
                            color: AppColors.boardColor,
                            child: markerPath.isNotEmpty
                                ? Image.asset(markerPath, fit: BoxFit.cover)
                                : null,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
