import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:battleship_fe/common/app_colors.dart';
import '../../controller/login/user_controller.dart';
import '../../service/kakao_login_api.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // KakaoLoginApi 인스턴스를 생성
    final KakaoLoginApi kakaoLoginApi = KakaoLoginApi();

    // UserController를 의존성 주입
    final UserController userController =
        Get.put(UserController(kakaoLoginApi: kakaoLoginApi));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter with Kakao login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _profile(userController),
            _nickName(userController),
            _loginButton(userController),
            _logoutButton(userController),
          ],
        ),
      ),
    );
  }

  // 프로필 이미지 위젯
  Widget _profile(UserController controller) {
    return Obx(() {
      if (controller.user.value?.profileImageUrl != null) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
                NetworkImage(controller.user.value!.profileImageUrl!),
          ),
        );
      } else {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
        );
      }
    });
  }

  // 닉네임 위젯
  Widget _nickName(UserController controller) {
    return Obx(() {
      if (controller.user.value?.nickname != null) {
        return Text(
          controller.user.value!.nickname!,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      } else {
        return const Text(
          "로그인이 필요합니다",
          style: TextStyle(fontSize: 18),
        );
      }
    });
  }

  // 로그인 버튼 위젯
  Widget _loginButton(UserController controller) {
    return Obx(() {
      if (controller.user.value == null) {
        return ElevatedButton(
          onPressed: () {
            controller.kakaoLogin();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kakaotalkYellow,
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12), // 테두리 곡률 설정 : 12 픽셀(Pixel)
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/kakao_icon.png',
                width: 30.sp,
                height: 30.sp,
              ),
              SizedBox(width: 10.sp),
              Text(
                '카카오 로그인',
                style:
                    TextStyle(color: AppColors.kakaotalkLabel, fontSize: 25.sp),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink(); // 이미 로그인한 경우 버튼 숨김
      }
    });
  }

  // 로그아웃 버튼 위젯
  Widget _logoutButton(UserController controller) {
    return Obx(() {
      if (controller.user.value != null) {
        return ElevatedButton(
          onPressed: () {
            controller.kakaoLogout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // 로그아웃 버튼 색상
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      } else {
        return const SizedBox.shrink(); // 로그아웃 버튼 숨김
      }
    });
  }
}
