import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../model/game_state.dart';
import '../../model/unit.dart';
import '../../service/game_service.dart';

class GameController extends GetxController {
  // ======================================
  // 기존 필드 (배치 로직에서 사용)
  // ======================================
  var grid = List.generate(
    10,
    (_) => List<String>.filled(10, 'empty'),
  ).obs;

  var placedUnits = <Unit>[].obs;

  var unitCounters = {
    'u1': 0,
    'u2': 0,
    'u3': 0,
  }.obs;

  var unitCounts = {
    'u1': 1,
    'u2': 2,
    'u3': 3,
  }.obs;

  var isDeploymentComplete = false.obs;

  var selectedUnitType = Rxn<Unit>();
  var selectedPlacedUnit = Rxn<Unit>();

  // ======================================
  // [배치(Deploy)] 관련 필드
  // ======================================
  // (기존 필드: unitCounters, unitCounts, placedUnits, etc.)

  // ======================================
  // [게임 진행(Game)] 관련 필드
  // ======================================
  // (기존 필드: myBoardMarkers, enemyBoardMarkers, etc.)

  // ======================================
  // [게임 보드(Game Board)] 관련 필드
  // ======================================
  /// 내 보드에 표시될 마커 (상대의 공격 결과)
  /// 'enemy_hit' -> 'assets/markers/enemy_hit.png'
  /// 'enemy_miss' -> 'assets/markers/enemy_miss_2.png'
  var myBoardMarkers = List.generate(
    10,
    (_) => List<String>.filled(10, 'empty'),
  ).obs;

  /// 적 보드에 표시될 마커 (내 공격 관련)
  /// 'aim' -> 'assets/markers/aim.png'
  /// 'my_hit' -> 'assets/markers/my_hit.png'
  /// 'my_miss' -> 'assets/markers/my_miss.png'
  var enemyBoardMarkers = List.generate(
    10,
    (_) => List<String>.filled(10, 'empty'),
  ).obs;

  /// 현재 내가 공격하려고 선택한 좌표 (row, col)
  var selectedAttackCell = Rxn<List<int>>();

  // ======================================
  // [타이머 관련 필드]
  // ======================================
  /// 배치 타이머 (기존)
  RxInt remainingDeploymentSeconds = 60.obs;
  Timer? _deploymentTimer;

  /// 턴 타이머 (공격 및 수비 턴용)
  RxInt remainingTurnSeconds = 100.obs;
  Timer? _turnTimer;

  /// 수비자 폴링 타이머
  Timer? _defenderCheckTimer;

  /// 게임 서비스
  final GameService _gameService = GameService();

  @override
  void onInit() {
    super.onInit();
    startDeploymentTimer();
  }

  // ======================================
  // [배치 카운트다운 타이머 관련 메서드]
  // ======================================
  void startDeploymentTimer() {
    _deploymentTimer?.cancel();
    _deploymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingDeploymentSeconds.value > 0) {
        remainingDeploymentSeconds.value--;
      } else {
        timer.cancel();
        showDeploymentTimeUpSnackbar();
      }
    });
  }

  /// 배치 시간이 다 되었을 때 Snackbar 표시 (기존)
  void showDeploymentTimeUpSnackbar() {
    Get.snackbar(
      "알림", // 제목
      "배치 시간이 완료되었습니다. 배치를 완료해주세요!", // 메시지
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// 배치 타이머 초기화
  void resetDeploymentTimer() {
    _deploymentTimer?.cancel();
    remainingDeploymentSeconds.value = 60;
  }

  // ======================================
  // [턴 타이머 관련 메서드]
  // ======================================
  void startTurnTimer() {
    // 기존 턴 타이머가 있으면 정지
    _turnTimer?.cancel();
    remainingTurnSeconds.value = 100; // 초기값

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTurnSeconds.value > 0) {
        remainingTurnSeconds.value--;
      } else {
        timer.cancel();
        showTurnTimeUpSnackbar();
        handleTurnTimeout();
      }
    });
  }

  /// 턴 타이머 중지
  void stopTurnTimer() {
    _turnTimer?.cancel();
  }

  void showTurnTimeUpSnackbar() {
    Get.snackbar(
      "알림", // 제목
      "턴 시간이 종료되었습니다!", // 메시지
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// 턴 시간 초과 시 처리 로직
  Future<void> handleTurnTimeout() async {
    // 턴 종료를 서버에 알림
    if (GameState().roomCode != null) {
      await _gameService.endTurn(GameState().roomCode!);
    }
    // 턴 토글
    toggleTurn();
  }

  // ======================================
  // [수비 폴링 타이머] - 5초 간격으로 체크
  // ======================================
  void startDefenderCheckTimer() {
    // 혹시 기존에 실행 중이면 취소
    _defenderCheckTimer?.cancel();

    _defenderCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      // 만약 이미 게임이 끝났거나, 내가 공격자면 더 이상 체크 필요 없음
      if (GameState().isGameOver || GameState().isMyTurn == true) {
        timer.cancel();
        return;
      }

      if (GameState().roomCode != null) {
        final result = await _gameService.checkDamageStatusAsDefender(
          GameState().roomCode!,
        );

        final damageStatus = result["damage_status"];
        final attackPos = result["attack_position"] ?? "";
        final gameStatus = result["game_status"];

        if (damageStatus == "damaged" || damageStatus == "missed") {
          // 공격 좌표 문자열("A1" 등)을 row,col로 변환
          final parsed = convertStringToRowCol(attackPos);
          if (parsed != null) {
            final row = parsed[0];
            final col = parsed[1];
            // 내 보드에 히트/미스 표시
            enemyAttacksCell(row, col);
          }

          // 게임 끝났는지 여부
          if (gameStatus == "completed") {
            GameState().endGame();
            Get.snackbar("패배", "상대의 마지막 공격이 적중했습니다!");
            Log.wtf('패배 : 상대의 마지막 공격이 적중했습니다!');
            Get.offNamed("/lose");
          } else {
            // 공격 끝 -> 턴 종료
            if (GameState().roomCode != null) {
              await _gameService.endTurn(GameState().roomCode!);
            }
            // 공격/수비 교대
            toggleTurn();
          }
          timer.cancel(); // 이번 수비 턴은 끝났으니 타이머 종료
        }
      }
    });
  }

  /// (수비 폴링 중지)
  void stopDefenderCheckTimer() {
    _defenderCheckTimer?.cancel();
  }

  // ======================================
  // [턴 토글] - 공격자 ↔ 수비자 전환
  // ======================================
  void toggleTurn() {
    // 1) GameState의 isMyTurn 토글
    GameState().toggleTurn();

    // 2) 기존 타이머들 정지
    stopTurnTimer();
    stopDefenderCheckTimer();

    // 3) 게임 종료가 아니라면 새 턴 타이머 세팅
    if (!GameState().isGameOver) {
      if (GameState().isMyTurn == true) {
        // 내가 공격자가 됨
        startTurnTimer();
      } else {
        // 내가 수비자가 됨
        startDefenderCheckTimer();
      }
    }
  }

  // ======================================
  // [배치(Deploy)] 관련 메서드
  // ======================================

  /// 유닛 유형을 선택하는 메서드
  /// 배치 가능한 유닛 수가 0개 이상이어야 선택 가능
  void selectUnitType(Unit unitType) {
    Log.info("Try to select unit type: ${unitType.id}");
    if (unitCounts[unitType.id]! <= 0) {
      Log.warning("Cannot select ${unitType.id}, no more units left.");
      return;
    }
    selectedUnitType.value = unitType;
    selectedPlacedUnit.value = null;
    Log.info("Selected unit type: ${unitType.id}");
  }

  /// 이미 배치된 유닛을 선택하는 메서드
  void selectPlacedUnit(Unit unit) {
    Log.info("Selecting placed unit with uniqueId: ${unit.id}");
    selectedPlacedUnit.value = unit;
    selectedUnitType.value = null;
    Log.info("Selected placed unit: ${unit.id}");
  }

  /// 유닛을 보드에 배치하는 메서드
  bool placeUnit(Unit unitType, int row, int col) {
    Log.info("Attempting to place unit ${unitType.id} at row=$row, col=$col");
    if (unitCounts[unitType.id]! <= 0) {
      Log.warning("No more ${unitType.id} units left to place.");
      return false;
    }

    bool isHorizontal = unitType.isHorizontal;
    int unitWidth = isHorizontal ? unitType.width : unitType.height;
    int unitHeight = isHorizontal ? unitType.height : unitType.width;

    if (row + unitHeight > 10 || col + unitWidth > 10) {
      Log.warning("Cannot place ${unitType.id} out of board range.");
      return false;
    }

    // 격자 충돌 확인
    for (int r = row; r < row + unitHeight; r++) {
      for (int c = col; c < col + unitWidth; c++) {
        if (grid[r][c] != 'empty') {
          Log.warning("Collision detected at row=$r, col=$c");
          return false;
        }
      }
    }

    // 배치
    List<String> placedCoordinates = [];
    for (int r = row; r < row + unitHeight; r++) {
      for (int c = col; c < col + unitWidth; c++) {
        grid[r][c] = unitType.id;
        placedCoordinates.add('${String.fromCharCode(65 + r)}${c + 1}');
      }
    }

    // 유닛 고유 ID
    unitCounters[unitType.id] = unitCounters[unitType.id]! + 1;
    String uniqueId = '${unitType.id}_${unitCounters[unitType.id]}';

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

    unitType.isPlaced = true; // 이제 'exist' 이미지가 될 조건

    placedUnits.add(placedUnit);
    unitCounts[unitType.id] = unitCounts[unitType.id]! - 1;

    grid.refresh();
    placedUnits.refresh();

    // 선택 해제
    selectedUnitType.value = null;
    selectedPlacedUnit.value = null;

    Log.info("Placed unit $uniqueId at row=$row, col=$col");
    return true;
  }

  /// 이미 배치된 유닛을 이동(재배치)하는 메서드
  void moveUnit(Unit unit, int newRow, int newCol) {
    Log.info("Moving unit ${unit.id} to row=$newRow, col=$newCol");
    // 기존 좌표 초기화
    for (String coord in unit.coordinates) {
      int r = coord.codeUnitAt(0) - 65;
      int c = int.parse(coord.substring(1)) - 1;
      grid[r][c] = 'empty';
    }

    // 재배치
    unit.coordinates.clear();
    unit.isPlaced = false;
    unit.startRow = null;
    unit.startCol = null;
    placedUnits.refresh();

    // 원본 unitType (u1, u2, u3 등) 찾아서 placeUnit
    placeUnit(
      unitTypes.firstWhere((u) => u.id == unit.id.split('_')[0]),
      newRow,
      newCol,
    );
  }

  /// 선택된(배치 전) 유닛의 방향을 회전하는 메서드
  void rotateSelectedUnit() {
    if (selectedUnitType.value != null) {
      Log.info("Rotating unit ${selectedUnitType.value!.id}");

      // 기존 코드 대신 toggleOrientation() 호출
      selectedUnitType.value!.toggleOrientation();

      // 나머지 로그
      Log.info(
        "Rotated unit ${selectedUnitType.value!.id} -> "
        "isHorizontal: ${selectedUnitType.value!.isHorizontal}",
      );
    }
  }

  /// 배치된 유닛을 제거하는 메서드
  void removePlacedUnit(Unit unit) {
    Log.info("Removing placed unit ${unit.id} from the board...");

    // 1) 기존 좌표 초기화
    for (String coord in unit.coordinates) {
      int r = coord.codeUnitAt(0) - 65;
      int c = int.parse(coord.substring(1)) - 1;
      grid[r][c] = 'empty';
    }

    // 2) placedUnits 목록에서 제거
    placedUnits.remove(unit);

    // 3) unitCounts 복원(배치 취소됐으므로 1개 증가)
    final originalTypeId = unit.id.split('_')[0];
    unitCounts[originalTypeId] = unitCounts[originalTypeId]! + 1;

    // 4) 상태 갱신
    grid.refresh();
    placedUnits.refresh();

    Log.info(
        "Unit ${unit.id} removed. unitCounts[$originalTypeId] = ${unitCounts[originalTypeId]}");
  }

  /// 배치가 모두 완료되었는지 확인 후 완료 상태로 설정
  void completeDeployment() {
    bool allPlaced = unitCounts.values.every((count) => count <= 0);
    if (!allPlaced) {
      Log.warning("Log.warn: Not all units have been placed yet.");
      return;
    }
    isDeploymentComplete.value = true;
    Log.info("Deployment complete!");
  }

  /// 모든 배치와 보드를 리셋하는 메서드
  void resetPlacement() {
    Log.info("Resetting placement...");
    grid.value = List.generate(
      10,
      (_) => List<String>.filled(10, 'empty'),
    );
    placedUnits.clear();
    unitCounters.updateAll((key, value) => 0);
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
    isDeploymentComplete.value = false;
    selectedPlacedUnit.value = null;
    selectedUnitType.value = null;

    // 마커도 초기화
    myBoardMarkers.value = List.generate(
      10,
      (_) => List<String>.filled(10, 'empty'),
    );
    enemyBoardMarkers.value = List.generate(
      10,
      (_) => List<String>.filled(10, 'empty'),
    );
    selectedAttackCell.value = null;

    grid.refresh();
    placedUnits.refresh();
    myBoardMarkers.refresh();
    enemyBoardMarkers.refresh();

    Log.info("All placements and markers have been reset.");
  }

  // ======================================
  // [게임(Game)] 관련 메서드
  // ======================================

  /// 상대가 내 보드를 공격했을 때 호출하는 메서드
  /// row, col 좌표에 유닛이 있다면 'enemy_hit', 없으면 'enemy_miss'
  void enemyAttacksCell(int row, int col) {
    Log.info("Enemy attacks cell [row=$row, col=$col]");
    final cellValue = grid[row][col];
    if (cellValue != 'empty') {
      myBoardMarkers[row][col] = 'enemy_hit';
      Log.info("Enemy hit my unit at row=$row, col=$col");
    } else {
      myBoardMarkers[row][col] = 'enemy_miss';
      Log.info("Enemy missed at row=$row, col=$col");
    }
    myBoardMarkers.refresh();
  }

  /// 내가 적 보드를 공격하기 위해 좌표를 선택
  void selectAttackCell(int row, int col) {
    Log.info("Selecting attack cell [row=$row, col=$col] on enemy board.");
    // 기존 'aim' 마커 제거
    if (selectedAttackCell.value != null) {
      final oldRow = selectedAttackCell.value![0];
      final oldCol = selectedAttackCell.value![1];
      if (enemyBoardMarkers[oldRow][oldCol] == 'aim') {
        enemyBoardMarkers[oldRow][oldCol] = 'empty';
      }
    }

    // 새 'aim' 표시
    enemyBoardMarkers[row][col] = 'aim';
    selectedAttackCell.value = [row, col];
    enemyBoardMarkers.refresh();

    Log.info("Marked 'aim' at enemy board [row=$row, col=$col]");
  }

  /// 실제 공격(버튼 눌렀을 때)을 수행하는 메서드
  void attackSelectedCell() {
    if (selectedAttackCell.value == null) {
      Log.warning("No cell selected to attack.");
      return;
    }

    final row = selectedAttackCell.value![0];
    final col = selectedAttackCell.value![1];

    bool isHit = _checkEnemyUnitHit(row, col);

    if (isHit) {
      enemyBoardMarkers[row][col] = 'my_hit';
      Log.info("I hit the enemy at row=$row, col=$col!");
    } else {
      enemyBoardMarkers[row][col] = 'my_miss';
      Log.info("I missed the enemy at row=$row, col=$col.");
    }

    // 공격 좌표 로그 출력
    Log.info("공격한 좌표는 ${String.fromCharCode(65 + row)}${col + 1}");

    // 공격 후 선택 해제
    selectedAttackCell.value = null;
    enemyBoardMarkers.refresh();
  }

  /// 임의의 로직으로 히트/미스를 판단하는 예시 함수
  bool _checkEnemyUnitHit(int row, int col) {
    // 예) row가 짝수면 hit, 홀수면 miss 로 가정
    Log.info("Checking if enemy unit is hit at row=$row, col=$col");
    return (row % 2 == 0);
  }

  // ======================================
  // [좌표 변환 유틸] - (row,col) <-> "A1"
  // ======================================
  List<int>? convertStringToRowCol(String pos) {
    if (pos.length < 2) return null;
    final rowChar = pos[0].toUpperCase();
    final colStr = pos.substring(1);

    final rowIndex = rowChar.codeUnitAt(0) - 'A'.codeUnitAt(0);
    final colIndex = int.tryParse(colStr) ?? -1;
    if (rowIndex < 0 || rowIndex > 9) return null;
    if (colIndex < 1 || colIndex > 10) return null;

    return [rowIndex, colIndex - 1];
  }

  @override
  void onClose() {
    _deploymentTimer?.cancel();
    _turnTimer?.cancel();
    _defenderCheckTimer?.cancel();
    super.onClose();
  }

  // ======================================
  // [배치할 유닛 유형] 리스트
  // ======================================
  final RxList<Unit> unitTypes = <Unit>[
    Unit(id: 'u1', name: '하마', width: 3, height: 2),
    Unit(id: 'u2', name: '악어', width: 4, height: 1),
    Unit(id: 'u3', name: '통나무', width: 2, height: 1),
  ].obs;
}
