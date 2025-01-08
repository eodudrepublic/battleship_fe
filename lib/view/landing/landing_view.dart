import 'package:battleship_fe/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../model/game_state.dart';
import '../../model/user_model.dart';
import '../../service/game_service.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  Future<void> _createSoloGame() async {
    try {
      final myUserId = AppUser().id ?? 0;
      final gameService = GameService();

      // 1) 솔로게임 생성 API 호출
      final result = await gameService.createSoloGame(myUserId);
      // 예: { "is_matched": true, "room_code": "28285450", "opponent": 0, "is_first": false }

      if (result["room_code"] != null) {
        final roomCode = result["room_code"] as String;
        final isFirst = result["is_first"] as bool;
        final opponentId = result["opponent"] as int;

        // 2) GameState 세팅 (isSoloGame = true)
        GameState().setGameState(
          isFirstPlayer: isFirst,
          opponentId: opponentId,
          roomCode: roomCode,
          solo: true, // 솔로게임
        );
        Log.info("솔로게임 생성 성공: $result");

        // 3) 바로 배치 화면으로 이동
        //    (상대방 대기할 필요 없이, 솔로이므로 곧바로 DeployView)
        Get.offNamed('/deploy');
      } else {
        Log.error("솔로게임 생성 실패 or 알 수 없는 응답: $result");
      }
    } catch (e) {
      Log.error("솔로게임 생성 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/icons/branding.png',
                width: 0.6.sw,
              ),
              Image.asset(
                'assets/icons/battlebara_moving.gif',
                width: 0.8.sw,
                height: 0.8.sw,
              ),

              /// 혼자바라
              SizedBox(
                width: 0.55.sw,
                height: 0.075.sh,
                child: ElevatedButton(
                  onPressed: () {
                    Log.info('혼자바라');
                    _createSoloGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.timeWidgetColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // 테두리 곡률 설정 : 12 픽셀(Pixel)
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '혼자바라',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 20.sp,
              ),

              /// 게임 생성
              SizedBox(
                width: 0.55.sw,
                height: 0.075.sh,
                child: ElevatedButton(
                  onPressed: () {
                    Log.info('게임 생성하기');
                    Get.toNamed('/waiting');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.timeWidgetColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // 테두리 곡률 설정 : 12 픽셀(Pixel)
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '게임 생성하기',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 20.sp,
              ),

              /// 게임 참여
              SizedBox(
                width: 0.55.sw,
                height: 0.075.sh,
                child: ElevatedButton(
                  onPressed: () {
                    Log.info('게임 참여하기');
                    Get.toNamed('/entering');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.timeWidgetColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // 테두리 곡률 설정 : 12 픽셀(Pixel)
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '게임 참여하기',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
