import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/screen/auth/login_screen.dart';
import 'package:daily_route/screen/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
          
                // 1. 이미지
                // todo: 나중에 더 좋은 이미지를 구하면 교체하기
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/welcome_journey.png',
                    fit: BoxFit.contain,
                  ),
                ),
          
                const SizedBox(height: 16),
          
                // 2. 앱 로고와 이름
                Image.asset('assets/logo/app_symbol.png', width: 88, height: 88),
          
                const Text(
                  '데일리루트',
                  style: TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          
                const SizedBox(height: 8),
          
                const Text(
                  '나에게 맞는 이동, 더 편안한 일상',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColor.textSecondary, fontSize: 16),
                ),
          
                const SizedBox(height: 50),
          
                // 3. 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '로그인',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
          
                const SizedBox(height: 12),
          
                // 4. 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColor.surface,
                      foregroundColor: AppColor.primary,
                      side: const BorderSide(color: AppColor.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
          
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
