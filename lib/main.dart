import 'package:daily_route/core/kakao_map/map_sdk_initializer.dart';
import 'package:daily_route/core/providers/user_provider.dart';
import 'package:daily_route/screen/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 지도 SDK 준비가 끝난 뒤 앱 시작. 미지원 기기는 홈에서 안내 표시
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MapSdkInitializer.initialize();
  runApp(
    ChangeNotifierProvider(create: (_) => UserProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'daily_route',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WelcomeScreen(),
    );
  }
}
