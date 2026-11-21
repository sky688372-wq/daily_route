import 'package:daily_route/core/providers/user_provider.dart';
import 'package:daily_route/screen/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// todo: ARM64 실기기에서 카카오맵을 테스트한 뒤 SDK 초기화 복구
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
