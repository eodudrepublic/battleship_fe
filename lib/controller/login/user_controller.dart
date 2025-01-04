import 'package:get/get.dart';
import '../../model/user_model.dart';
import '../../service/kakao_login_api.dart';

class UserController extends GetxController {
  // Rx<AppUser?>은 반응형으로 사용자 정보를 저장합니다.
  var user = Rxn<AppUser>();
  final KakaoLoginApi kakaoLoginApi;

  UserController({required this.kakaoLoginApi});

  // 카카오 로그인 메서드
  Future<void> kakaoLogin() async {
    var kakaoUser = await kakaoLoginApi.signWithKakao();
    if (kakaoUser != null) {
      user.value = AppUser.fromKakaoUser(kakaoUser);
      Get.snackbar('성공', '카카오 로그인이 성공했습니다.');
    } else {
      Get.snackbar('실패', '카카오 로그인이 취소되었거나 실패했습니다.');
    }
  }

  // 로그아웃 메서드 (선택 사항)
  Future<void> kakaoLogout() async {
    try {
      await kakaoLoginApi.logout();
      user.value = null;
      Get.snackbar('성공', '로그아웃에 성공했습니다.');
    } catch (error) {
      Get.snackbar('실패', '로그아웃에 실패했습니다.');
    }
  }
}
