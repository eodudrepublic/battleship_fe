import 'package:get/get.dart';
import '../../model/ship.dart';

class GameController extends GetxController {
  // 15x15 격자를 List<List<String>>으로 정의 (반응형)
  var grid = List.generate(
    15,
    (_) => List<String>.filled(15, 'empty'),
  ).obs;

  // 배치할 함선 목록
  var ships = <Ship>[
    // 1x2 크기의 함선 5개
    Ship(id: 's1', name: 'Destroyer 1', size: 2),
    Ship(id: 's2', name: 'Destroyer 2', size: 2),
    Ship(id: 's3', name: 'Destroyer 3', size: 2),
    Ship(id: 's4', name: 'Destroyer 4', size: 2),
    Ship(id: 's5', name: 'Destroyer 5', size: 2),

    // 1x3 크기의 함선 3개
    Ship(id: 's6', name: 'Submarine 1', size: 3),
    Ship(id: 's7', name: 'Submarine 2', size: 3),
    Ship(id: 's8', name: 'Submarine 3', size: 3),

    // 1x5 크기의 함선 2개
    Ship(id: 's9', name: 'Carrier 1', size: 5),
    Ship(id: 's10', name: 'Carrier 2', size: 5),
  ].obs;

  // 현재 선택된 함선
  var selectedShip = Rxn<Ship>();

  // 함선을 격자에 배치하는 메서드
  void placeShip(Ship ship, int row, int col) {
    bool isHorizontal = ship.isHorizontal;

    // 격자의 범위 확인
    if (isHorizontal) {
      if (col + ship.size > 15) {
        // 범위 초과
        Get.snackbar('Error', '함선이 격자 범위를 벗어납니다.');
        return;
      }
      for (int i = 0; i < ship.size; i++) {
        if (grid.value[row][col + i] != 'empty') {
          // 이미 다른 함선이 있는 경우
          Get.snackbar('Error', '해당 위치에 이미 함선이 있습니다.');
          return;
        }
      }
      // 격자에 함선 배치
      for (int i = 0; i < ship.size; i++) {
        grid.value[row][col + i] = ship.id;
        ship.coordinates.add('${String.fromCharCode(65 + row)}${col + i + 1}');
      }
    } else {
      if (row + ship.size > 15) {
        // 범위 초과
        Get.snackbar('Error', '함선이 격자 범위를 벗어납니다.');
        return;
      }
      for (int i = 0; i < ship.size; i++) {
        if (grid.value[row + i][col] != 'empty') {
          // 이미 다른 함선이 있는 경우
          Get.snackbar('Error', '해당 위치에 이미 함선이 있습니다.');
          return;
        }
      }
      // 격자에 함선 배치
      for (int i = 0; i < ship.size; i++) {
        grid.value[row + i][col] = ship.id;
        ship.coordinates.add('${String.fromCharCode(65 + row + i)}${col + 1}');
      }
    }

    ship.isPlaced = true;
    ships.refresh();
    grid.refresh(); // grid 변경 사항을 반영
    selectedShip.value = null; // 선택 해제
  }

  // 함선 선택 메서드
  void selectShip(Ship ship) {
    if (ship.isPlaced) {
      Get.snackbar('Info', '이미 배치된 함선입니다.');
      return;
    }
    selectedShip.value = ship;
  }

  // 함선 회전 메서드
  void rotateSelectedShip() {
    if (selectedShip.value != null) {
      selectedShip.value!.isHorizontal = !selectedShip.value!.isHorizontal;
      ships.refresh();
    }
  }
}
