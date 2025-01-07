import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';

class EnteringView extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  // TODO : 컨트롤러로 이동
  final ValueNotifier<String> _inputValue = ValueNotifier<String>('');

  EnteringView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO : 컨트롤러로 이동
    _controller.addListener(() {
      _inputValue.value = _controller.text;
    });

    return Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(top: 50.sp),
                child: ValueListenableBuilder<String>(
                  valueListenable: _inputValue,
                  builder: (context, value, child) {
                    return TextField(
                      controller: _controller,
                      style: TextStyle(fontSize: 18.sp, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "방 코드 입력",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                              BorderSide(color: Colors.grey[400]!, width: 2.sp),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                              BorderSide(color: Colors.grey[400]!, width: 2.sp),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.sp, vertical: 10.sp),
                        suffixIcon: IconButton(
                          icon: Icon(
                            value.isEmpty
                                ? Icons.clear_rounded
                                : Icons.arrow_forward_ios_rounded,
                          ),
                          onPressed: () {
                            if (value.isNotEmpty) {
                              Log.info("room_code: $value");
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                  child: ListView(
                      // TODO : (GET) serverUrl/games/를 통해 방 목록을 받아와서 보여주기
                      // TODO : 방 목록에서 room_code만 추출해서 _existingRoom(room_code)으로 보여주기
                      ))
            ],
          ),
        ));
  }

  Widget _existingRoom(String roomCode) {
    return SizedBox(
      width: 0.4.sw,
      height: 0.4.sw,
      child: GestureDetector(
        onTap: () {
          Log.info("Enter room_code: $roomCode");
          // TODO : (GET) serverUrl/invite/join-room를 통해 방에 입장하기
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // 이미지가 겹쳐 나올 수 있도록 설정
          children: [
            // 텍스트 배경 컨테이너
            Positioned(
              bottom: 5, // 이미지와 겹치도록 조정
              child: Container(
                width: 0.35.sw,
                height: 0.2.sw,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.timeWidgetColor,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Text(
                  roomCode,
                  style: TextStyle(
                    fontSize: 20, // 텍스트 크기
                    fontWeight: FontWeight.bold, // 텍스트 굵기
                    color: Colors.black, // 텍스트 색상
                  ),
                ),
              ),
            ),
            // 이미지 컨테이너
            Positioned(
              top: 0,
              child: Image.asset(
                'assets/icons/stackBara.png',
                width: 90.sp,
                height: 90.sp,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
