import 'package:battleship_fe/view/game/widget/grid_view_widget.dart';
import 'package:battleship_fe/view/game/widget/ship_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/game/game_controller.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.put(GameController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Battleship 배치'),
        actions: [
          // TODO : 함선 회전 버튼
          IconButton(
            icon: Icon(Icons.rotate_right),
            onPressed: () {
              controller.rotateSelectedShip();
            },
            tooltip: '함선 회전',
          ),
        ],
      ),
      body: Column(
        children: [
          // 격자 표시
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                return GridViewWidget(
                  grid: controller.grid.value,
                  onCellTap: (row, col) {
                    if (controller.selectedShip.value != null) {
                      controller.placeShip(
                          controller.selectedShip.value!, row, col);
                    }
                  },
                );
              }),
            ),
          ),
          Divider(),
          // 함선 목록 표시
          Expanded(
            flex: 2,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                children: controller.ships.map((ship) {
                  return ShipWidget(
                    ship: ship,
                    isSelected: controller.selectedShip.value?.id == ship.id,
                    onTap: () {
                      controller.selectShip(ship);
                    },
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}
