import 'package:battleship_fe/view/game/game_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Battleship',
      // debugShowCheckedModeBanner: false,
      home: GameView(),
    );
  }
}
