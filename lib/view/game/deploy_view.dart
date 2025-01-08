import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../controller/game/game_controller.dart';
import '../../model/game_state.dart';
import '../../model/unit.dart';
import '../../model/user_model.dart';
import '../../service/game_service.dart';
import 'widget/deploy_board.dart';

class DeployView extends StatelessWidget {
  final double _cellSize = (1.sw - 10.sp) / 11 - 1.sp;
  final double _borderWidth = 2.sp;
  final double _imageSize = min(
    (0.7.sh - 1.sw) / 4, // 첫 번째 값
    1.sw / 10, // 두 번째 값
  );

  DeployView({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.find<GameController>();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 배치 완료 / 배치 시간 안내
              Container(
                height: 0.22.sh,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("배치하기",
                        style: TextStyle(
                            fontSize: 35.sp, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TODO : 남은 배치시간 받아서 표시하도록 (서버 연결 필요)
                          Container(
                            height: 0.06.sh,
                            width: 0.30.sw,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.timeWidgetColor,
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                            child: Text(
                              "00:57",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 10.sp),
                          GestureDetector(
                            onTap: () async {
                              // 1) 아직 배치가 안 끝났다면 배치 완료 시도
                              if (!controller.isDeploymentComplete.value) {
                                controller.completeDeployment();
                              }

                              // 2) 배치가 모두 완료되었다면 좌표 출력 후 게임 화면으로 이동
                              if (controller.isDeploymentComplete.value) {
                                // 모든 배치된 유닛의 좌표를 수집
                                List<String> allCoordinates = [];
                                for (var unit in controller.placedUnits) {
                                  allCoordinates.addAll(unit.coordinates);
                                }

                                // 좌표들을 콘솔에 출력
                                Log.info(
                                    "배치된 유닛의 좌표들: ${allCoordinates.join(', ')}");
                                // 서버에 보드 전송
                                final myId = AppUser().id ?? 0;
                                final gameService = GameService();
                                final rCode = GameState().roomCode ?? '';

                                await gameService.sendBoard(
                                    rCode, myId, allCoordinates);

                                // 게임 화면으로 이동
                                Get.offNamed('/game');
                              }
                            },
                            child: Container(
                              height: 0.06.sh,
                              width: 0.30.sw,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.attackButtonColor,
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: Text(
                                "배치 완료",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              /// 게임판
              DeployBoardView(
                cellSize: _cellSize,
                borderWidth: _borderWidth,
                controller: controller, // 통합된 컨트롤러 전달
                onUnitTap: (Unit? unit) {
                  if (unit == null) {
                    // 1) 유닛 배치 후 선택 해제
                    controller.selectedUnitType.value = null;
                  } else {
                    // -------------------------------
                    // 1) '배치 중 유닛' 선택이 있었다면 먼저 해제
                    if (controller.selectedUnitType.value != null) {
                      controller.selectedUnitType.value = null;
                    }

                    // 2) 이미 배치된 유닛 선택
                    controller.selectPlacedUnit(unit);

                    // ========================================
                    // [신규] 선택된 배치 유닛을 즉시 '배치 취소'하는 기능 추가
                    // ========================================
                    controller.removePlacedUnit(unit);

                    // 필요 시: 선택된 placedUnit도 해제
                    // (이미 removePlacedUnit으로 placedUnits에서 제거하므로,
                    //  이후에 selectPlacedUnit의 효과가 무의미할 수 있어, 추가 해제)
                    controller.selectedPlacedUnit.value = null;
                  }
                },
              ),

              /// 배치할 유닛 목록
              // TODO : 각 유닛별 영역 사이즈 조정 (필요시)
              Obx(() {
                return Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: controller.unitTypes.map((unitType) {
                      int remaining = controller.unitCounts[unitType.id] ?? 0;
                      bool isNone = remaining <= 0;
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
                                // TODO : unitType에 따라 _getUnitImagePath로 이미지 경로 설정
                                child: Image.asset(
                                  unitType.imagePath,
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
                              GestureDetector(
                                onTap: () {
                                  if (!controller.isDeploymentComplete.value) {
                                    // 1) 만약 '현재 선택된 유닛'이 이 unitType이라면, rotateSelectedUnit() 호출
                                    if (controller.selectedUnitType.value?.id ==
                                        unitType.id) {
                                      // 여기서 GameController.rotateSelectedUnit()은
                                      //   selectedUnitType.value!.toggleOrientation()을 호출
                                      controller.rotateSelectedUnit();
                                    } else {
                                      // 2) 선택되지 않은 상태라면,
                                      //    이 unitType 객체에 대해 직접 toggleOrientation() 메서드 호출
                                      unitType.toggleOrientation();

                                      // UI 갱신
                                      controller.unitTypes.refresh();
                                    }
                                  }
                                },
                                child: SvgPicture.asset(
                                  'assets/icons/turn.svg',
                                  height: 22.sp,
                                  width: 22.sp,
                                ),
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
      // TODO : 배치 초기화 -> 나중에 쓸거니까 일단 주석처리 (이 코드는 삭제하지 말것)
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // 배치 초기화 버튼
      //     controller.resetPlacement();
      //   },
      //   tooltip: '배치 초기화',
      //   child: Icon(Icons.refresh),
      // ),
    );
  }

  String _getUnitImagePath(String unitTypeId, bool isNone) {
    // 1) GameController에서 unitTypes 목록을 찾고, orientation을 확인
    final GameController controller = Get.find<GameController>();
    final Unit? foundUnit =
        controller.unitTypes.firstWhereOrNull((u) => u.id == unitTypeId);

    // 2) 가로/세로 방향을 얻기 (기본값: true)
    bool isHorizontal = foundUnit?.isHorizontal ?? true;

    // 3) baseName 결정 (none / exist)
    String baseName;
    switch (unitTypeId) {
      case 'u1':
        baseName = isNone ? 'hippo_none' : 'hippo_exist';
        break;
      case 'u2':
        baseName = isNone ? 'crocodile_none' : 'crocodile_exist';
        break;
      case 'u3':
        baseName = isNone ? 'log_none' : 'log_exist';
        break;
      default:
        return 'assets/units/none.png';
    }

    // 4) 만약 세로 배치(isHorizontal = false)라면, '_rotate' 붙이기
    if (!isHorizontal) {
      baseName = '${baseName}_rotate';
    }

    // 5) 최종 경로 반환
    return 'assets/units/$baseName.png';
  }
}
