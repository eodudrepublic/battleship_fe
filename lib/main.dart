import 'package:battleship_fe/controller/game/game_controller.dart';
import 'package:battleship_fe/view/game/entering_view.dart';
import 'package:battleship_fe/view/game/test/game_service_test.dart';
import 'package:battleship_fe/view/game/test/lose_view.dart';
import 'package:battleship_fe/view/game/waiting_view.dart';
import 'package:battleship_fe/view/game/win_view.dart';
import 'package:battleship_fe/view/landing/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'common/key.dart';
import 'common/utils/logger.dart';
import 'package:battleship_fe/view/login/login_view.dart';
import 'package:battleship_fe/view/game/deploy_view.dart';
import 'package:battleship_fe/view/game/game_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 세로 모드로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  KakaoSdk.init(nativeAppKey: myNativeAppKey);

  Log.wtf("KakaoSdk initialized : ${await KakaoSdk.origin} -> 이게 왜 키 해쉬예요 ㅅㅂ");

  Get.put(GameController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(410, 920),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Battleship',
          // debugShowCheckedModeBanner: false,
          initialRoute: '/win',
          getPages: [
            /// 로그인
            GetPage(name: '/login', page: () => LoginView()),

            /// 메인화면
            GetPage(name: '/landing', page: () => LandingView()),

            /// 대기화면
            GetPage(name: '/waiting', page: () => WaitingView()),

            /// 게임 방 목록 화면
            GetPage(name: '/entering', page: () => EnteringView()),

            /// 유닛 배치
            GetPage(name: '/deploy', page: () => DeployView()),

            /// 게임화면
            GetPage(name: '/game', page: () => GameView()),

            /// 승리화면
            GetPage(name: '/win', page: () => WinView()),

            /// 패배화면
            GetPage(name: '/lose', page: () => LoseView()),

            // 게임 서비스 테스트
            GetPage(name: '/test', page: () => GameServiceTest()),
          ],
        );
      },
    );
  }
}
