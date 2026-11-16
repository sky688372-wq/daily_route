import 'package:daily_route/core/secret/app_secret.dart';
import 'package:daily_route/screen/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Android·iOS 카카오맵 SDK 초기화await Kaka
  // todo 나중에 기기 바꿔서 테스트하기
  // oMapsFlutter.init(
  //   //   AppSecret.kakaoMapNativeKey,
  //   // );
  //

  // 2. 기존 앱 실행
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'daily_route',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
