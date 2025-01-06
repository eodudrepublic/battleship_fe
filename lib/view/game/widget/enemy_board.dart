import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // ==================================================
  // [Refactored] 마커 이미지 경로 함수 + 주석 및 print 구문 추가
  // ==================================================
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
    print("Log.debug: Building EnemyBoardView");
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
                            // 내 공격 턴일 때만 가능하다고 가정
                            print(
                                "Log.debug: Tapped enemy board cell [row=$rowIndex, col=${colIndex - 1}]");
                            controller.selectAttackCell(rowIndex, colIndex - 1);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cellSize,
                            color: Colors.lightBlue[50],
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
