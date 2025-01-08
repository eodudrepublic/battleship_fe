import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/app_colors.dart';
import '../../../common/utils/logger.dart';

class LoseView extends StatelessWidget {
  const LoseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '패배바라...',
              style: TextStyle(
                  fontFamily: 'Sejong',
                  color: Colors.black,
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30.sp),
            Image.asset(
              'assets/markers/lose.png',
              width: 0.6.sw,
            ),

            SizedBox(height: 0.08.sh),

            /// 홈으로
            SizedBox(
              width: 0.55.sw,
              height: 0.075.sh,
              child: ElevatedButton(
                onPressed: () {
                  Log.info('패배바라 -> 홈으로...');
                  Get.offNamed('/landing');
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
                  '홈으로',
                  style: TextStyle(
                      fontFamily: 'Sejong',
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
