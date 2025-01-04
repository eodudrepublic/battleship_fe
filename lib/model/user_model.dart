import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

// TODO : 서버 연결할때 저장할 User 정보에 맞춰서 추후 수정
class AppUser {
  final String id;
  final String? nickname;
  final String? profileImageUrl;

  AppUser({
    required this.id,
    this.nickname,
    this.profileImageUrl,
  });

  // Kakao SDK의 User 객체를 AppUser로 변환하는 팩토리 생성자
  factory AppUser.fromKakaoUser(User kakaoUser) {
    return AppUser(
      id: kakaoUser.id.toString(),
      nickname: kakaoUser.kakaoAccount?.profile?.nickname,
      profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
    );
  }
}
