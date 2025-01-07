import 'package:battleship_fe/controller/game/game_controller.dart';
import 'package:battleship_fe/view/game/game_service_test.dart';
import 'package:flutter/material.dart';
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
          initialRoute: '/test',
          getPages: [
            GetPage(name: '/login', page: () => LoginView()),
            GetPage(name: '/deploy', page: () => DeployView()),
            GetPage(name: '/game', page: () => GameView()),
            GetPage(name: '/test', page: () => GameServiceTest()),
          ],
        );
      },
    );
  }
}
