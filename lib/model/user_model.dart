import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../common/utils/logger.dart';

class AppUser {
  final int id;
  final String? nickname;
  final String? profileImageUrl;

  AppUser({
    required this.id,
    this.nickname,
    this.profileImageUrl,
  });

  // Kakao SDK의 User 객체를 AppUser로 변환하는 팩토리 생성자
  factory AppUser.fromKakaoUser(User kakaoUser) {
    Log.info("Kakao Socail Login :\n"
        "user_id : ${kakaoUser.id}\n"
        "nickname : ${kakaoUser.kakaoAccount?.profile?.nickname}\n"
        "profileImageUrl : ${kakaoUser.kakaoAccount?.profile?.profileImageUrl}");
    return AppUser(
      id: kakaoUser.id,
      nickname: kakaoUser.kakaoAccount?.profile?.nickname,
      profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
    );
  }
}
