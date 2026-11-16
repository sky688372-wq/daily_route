import 'package:daily_route/core/api_service/api_service.dart';
import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/core/util/app_snackBar.dart';
import 'package:daily_route/core/util/token_storage.dart';
import 'package:daily_route/screen/auth/forgot_password_screen.dart';
import 'package:daily_route/screen/main/main_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 입력 컨트롤러
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  // 비밀번호 숨김 여부
  bool _obscurePassword = true;

  // 로그인 요청 중 여부
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // 로그인 요청
  Future<void> _tryLogin() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    // 1. 입력값 검사
    if (email.isEmpty || password.isEmpty) {
      AppSnackBar.show(context, '이메일과 비밀번호를 입력해 주세요.');
      return;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      AppSnackBar.show(context, '올바른 이메일 주소를 입력해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. 로그인 API 요청
      final result = await ApiService.tryLogin(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // 3. 로그인 실패 안내
      if (!result.success) {
        AppSnackBar.show(context, result.message);
        return;
      }

      // 4. 토큰 정보 확인
      final loginData = result.data;

      if (loginData == null || loginData.accessToken.isEmpty) {
        AppSnackBar.show(context, '로그인 정보를 확인할 수 없습니다.');
        return;
      }

      // 5. 토큰 저장
      try {
        await TokenStorage.saveToken(loginData.accessToken);
      } catch (e) {
        if (!mounted) return;

        AppSnackBar.show(context, '로그인 정보를 저장하지 못했습니다. 다시 시도해 주세요.');
        return;
      }

      if (!mounted) return;

      AppSnackBar.show(context, result.message);

      // 6. 홈 화면 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackBar.show(context, '요청을 처리하지 못했습니다. 서버와 네트워크 연결을 확인해 주세요.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 뒤로 가기용 앱바
      appBar: AppBar(
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      backgroundColor: AppColor.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. 로그인 환영 문구
                const Text(
                  '다시 만나서 반가워요!\n오늘은 어디로 가볼까요?',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 36),

                // 2. 이메일 입력 텍스트 필드
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '이메일',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),

                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  controller: _emailCtrl,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.alternate_email_outlined,
                      color: AppColor.textSecondary,
                    ),
                    hintText: '이메일을 입력해 주세요',
                    hintStyle: const TextStyle(color: AppColor.hint),
                    filled: true,
                    fillColor: AppColor.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColor.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColor.inputFocusedBorder,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. 비밀번호 입력 텍스트 필드
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '비밀번호',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),

                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: (_) {
                    _tryLogin();
                  },
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword ? '비밀번호 표시' : '비밀번호 숨기기',
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    hintText: '비밀번호를 입력해 주세요',
                    hintStyle: const TextStyle(color: AppColor.hint),
                    filled: true,
                    fillColor: AppColor.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColor.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColor.inputFocusedBorder,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 4. 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _tryLogin,
                    child: Text(
                      _isLoading ? '로그인 중...' : '로그인',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. 비밀번호 찾기 화면 이동
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.primary,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
