import 'package:battleship_fe/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(
              width: 0.55.sw,
              height: 0.07.sh,
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
            SizedBox(
              width: 0.55.sw,
              height: 0.07.sh,
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
    );
  }
}
