import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';

class WaitingView extends StatelessWidget {
  // TODO : LandingView에서 넘어올때 서버로 '/invite/create' POST 요청을 보내서 room_code를 받아와야 함
  final String? roomCode;
  const WaitingView({super.key, this.roomCode = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "상대를 기다리는 중",
                style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text("방코드: $roomCode",
                  style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(
                height: 5.sp,
              ),
              Image.asset(
                'assets/icons/loading.gif',
                width: 0.8.sw,
                height: 0.8.sw,
              ),
              SizedBox(
                height: 20.sp,
              ),
              SizedBox(
                width: 0.55.sw,
                height: 0.07.sh,
                child: ElevatedButton(
                  onPressed: () {
                    Log.info('방 코드 복사하기');
                    // TODO : 클립보드에 roomCode를 복사하는 기능 추가
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
                    '방 코드 복사하기',
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
                    Log.info('방 만들기 취소 -> Get.back()');
                    Get.back();
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
                    '취소하기',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
