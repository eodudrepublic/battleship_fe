import 'package:get/get.dart';
import '../../model/unit.dart';

class GameController extends GetxController {
  // 10x10 격자를 List<List<String>>으로 정의 (반응형)
  var grid = List.generate(
    10,
    (_) => List<String>.filled(10, 'empty'),
  ).obs;

  // 배치할 유닛 유형 목록 (반응형 리스트)
  final RxList<Unit> unitTypes = <Unit>[
    Unit(id: 'u1', name: '하마', width: 3, height: 2),
    Unit(id: 'u2', name: '악어', width: 4, height: 1),
    Unit(id: 'u3', name: '통나무', width: 2, height: 1),
  ].obs;

  // 실제 배치된 유닛 목록
  var placedUnits = <Unit>[].obs;

  // 각 유닛 유형의 남은 개수
  var unitCounts = {
    'u1': 1,
    'u2': 2,
    'u3': 3,
  }.obs;

  // 각 유닛 유형의 배치 카운터 (고유 ID 생성을 위해)
  var unitCounters = {
    'u1': 0,
    'u2': 0,
    'u3': 0,
  }.obs;

  // 배치 완료 여부
  var isDeploymentComplete = false.obs;

  // 현재 선택된 유닛 유형
  var selectedUnitType = Rxn<Unit>();

  // 현재 선택된 배치된 유닛
  var selectedPlacedUnit = Rxn<Unit>();

  // 유닛 유형 선택 메서드
  void selectUnitType(Unit unitType) {
    if (unitCounts[unitType.id]! <= 0) {
      Get.snackbar('Info', '더 이상 남은 유닛이 없습니다.');
      return;
    }
    selectedUnitType.value = unitType;
    selectedPlacedUnit.value = null; // 배치된 유닛 선택 해제
  }

  // 배치된 유닛 선택 메서드
  void selectPlacedUnit(Unit unit) {
    selectedPlacedUnit.value = unit;
    selectedUnitType.value = null; // 유닛 유형 선택 해제
  }

  // 유닛 회전 메서드
  void rotateSelectedUnit() {
    if (selectedUnitType.value != null) {
      selectedUnitType.value!.isHorizontal =
          !selectedUnitType.value!.isHorizontal;
      unitTypes.refresh(); // 반응형 리스트이므로 refresh() 가능
    }
  }

  // 유닛 배치 메서드
  bool placeUnit(Unit unitType, int row, int col) {
    if (unitCounts[unitType.id]! <= 0) {
      Get.snackbar('Error', '더 이상 남은 유닛이 없습니다.');
      return false;
    }

    bool isHorizontal = unitType.isHorizontal;
    int unitWidth = isHorizontal ? unitType.width : unitType.height;
    int unitHeight = isHorizontal ? unitType.height : unitType.width;

    // 격자 범위 확인 (10x10)
    if (row + unitHeight > 10 || col + unitWidth > 10) {
      Get.snackbar('Error', '유닛이 격자 범위를 벗어납니다.');
      return false;
    }

    // 격자 충돌 확인
    for (int r = row; r < row + unitHeight; r++) {
      for (int c = col; c < col + unitWidth; c++) {
        if (grid.value[r][c] != 'empty') {
          Get.snackbar('Error', '해당 위치에 이미 유닛이 있습니다.');
          return false;
        }
      }
    }

    // 격자에 유닛 배치
    List<String> placedCoordinates = [];
    for (int r = row; r < row + unitHeight; r++) {
      for (int c = col; c < col + unitWidth; c++) {
        grid.value[r][c] = unitType.id;
        placedCoordinates.add('${String.fromCharCode(65 + r)}${c + 1}');
      }
    }

    // 고유 ID 생성 (예: 'u3_1', 'u3_2', ...)
    unitCounters[unitType.id] = unitCounters[unitType.id]! + 1;
    String uniqueId = '${unitType.id}_${unitCounters[unitType.id]}';

    // 새로운 유닛 인스턴스 생성
    Unit placedUnit = Unit(
      id: uniqueId,
      name: unitType.name,
      width: unitType.width,
      height: unitType.height,
      isHorizontal: isHorizontal,
      isPlaced: true,
      startRow: row,
      startCol: col,
      coordinates: placedCoordinates,
    );

    // 배치된 유닛 리스트에 추가
    placedUnits.add(placedUnit);

    // 남은 개수 업데이트
    unitCounts[unitType.id] = unitCounts[unitType.id]! - 1;

    // 상태 업데이트
    grid.refresh();
    placedUnits.refresh();
    unitTypes.refresh(); // 이미지 변경을 위해 추가

    // 선택 해제
    selectedUnitType.value = null;
    selectedPlacedUnit.value = null;

    // 남은 개수가 0인 경우 이미지 변경을 위해 unitTypes를 refresh

    return true;
  }

  // 배치 완료 메서드
  void completeDeployment() {
    // 모든 유닛이 배치되었는지 확인
    bool allPlaced = unitCounts.values.every((count) => count <= 0);
    if (!allPlaced) {
      Get.snackbar('Error', '모든 유닛을 배치하지 않았습니다.');
      return;
    }
    isDeploymentComplete.value = true;
    // 추가적인 로직 (예: 게임 시작 등)을 여기에 추가
  }

  // 유닛 이동 메서드
  void moveUnit(Unit unit, int newRow, int newCol) {
    // 기존 배치된 좌표 초기화
    for (String coord in unit.coordinates) {
      int r = coord.codeUnitAt(0) - 65;
      int c = int.parse(coord.substring(1)) - 1;
      grid.value[r][c] = 'empty';
    }

    // 새로운 배치 시도
    unit.coordinates.clear();
    unit.isPlaced = false;
    unit.startRow = null;
    unit.startCol = null;
    placedUnits.refresh();
    placeUnit(
      unitTypes.firstWhere((u) => u.id == unit.id.split('_')[0]),
      newRow,
      newCol,
    );
  }

  // 배치 초기화 메서드
  void resetPlacement() {
    // 격자 초기화
    grid.value = List.generate(
      10,
      (_) => List<String>.filled(10, 'empty'),
    );

    // 배치된 유닛 초기화
    placedUnits.clear();

    // 유닛 카운터 초기화
    unitCounters.updateAll((key, value) => 0);

    // 유닛 남은 개수 초기화
    unitCounts.updateAll((key, value) {
      switch (key) {
        case 'u1':
          return 1;
        case 'u2':
          return 2;
        case 'u3':
          return 3;
        default:
          return value;
      }
    });

    // 배치 완료 여부 초기화
    isDeploymentComplete.value = false;

    // 선택된 유닛 초기화
    selectedPlacedUnit.value = null;
    selectedUnitType.value = null;

    // 상태 업데이트
    grid.refresh();
    placedUnits.refresh();
    unitTypes.refresh();
  }

  // 선택된 배치된 유닛 설정
  void setSelectedPlacedUnit(Unit? unit) {
    selectedPlacedUnit.value = unit;
  }

  // 선택된 유닛 유형 설정
  void setSelectedUnitType(Unit? unit) {
    selectedUnitType.value = unit;
  }
}
