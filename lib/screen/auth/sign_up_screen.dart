import 'package:daily_route/core/api_service/api_service.dart';
import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/core/util/app_snackBar.dart';
import 'package:daily_route/screen/auth/login_screen.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 입력 컨트롤러들
  final TextEditingController _nicknameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  // 비밀번호 보임, 안보임 상태 변수
  // 처음에는 안 보이도록
  bool _isPasswordShow = false;
  bool _isPasswordConfirmShow = false;

  // 회원가입 요청 중 여부
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  // 회원가입 요청
  Future<void> _trySignUp() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final nickname = _nicknameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final passwordConfirm = _passwordConfirm.text;

    // 1. 입력값 검사
    if (nickname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordConfirm.isEmpty) {
      AppSnackBar.show(context, '모든 항목을 입력해 주세요.');
      return;
    }

    if (nickname.runes.length < 2 || nickname.runes.length > 20) {
      AppSnackBar.show(context, '닉네임은 2~20자로 입력해 주세요.');
      return;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      AppSnackBar.show(context, '올바른 이메일 주소를 입력해 주세요.');
      return;
    }

    if (password.runes.length < 8 || password.runes.length > 64) {
      AppSnackBar.show(context, '비밀번호는 8~64자로 입력해 주세요.');
      return;
    }

    if (password != passwordConfirm) {
      AppSnackBar.show(context, '비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. 회원가입 API 요청
      final result = await ApiService.trySignUp(
        nickname: nickname,
        email: email,
        password: password,
      );

      if (!mounted) return;

      // 3. 응답 결과 처리
      AppSnackBar.show(context, result.message);

      if (result.success) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      AppSnackBar.show(
        context,
        '요청을 처리하지 못했습니다. 서버와 네트워크 연결을 확인해 주세요.',
      );
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

                // 1. 상단 회원가입 문구
                const Text(
                  '데일리루트와 함께\n편안한 이동을 시작해요!',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 36),

                // 2. 닉네임 입력 텍스트 필드
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '닉네임',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),

                TextField(
                  controller: _nicknameCtrl,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColor.textSecondary,
                    ),
                    hintText: '닉네임을 입력해 주세요',
                    hintStyle: const TextStyle(
                      color: AppColor.hint,
                    ),
                    filled: true,
                    fillColor: AppColor.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColor.inputBorder,
                      ),
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

                // 3. 이메일 입력 텍스트 필드
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
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                    hintStyle: const TextStyle(
                      color: AppColor.hint,
                    ),
                    filled: true,
                    fillColor: AppColor.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColor.inputBorder,
                      ),
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

                // 4. 비밀번호 입력 텍스트 필드
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
                  controller: _passwordCtrl,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  obscureText: !_isPasswordShow,
                  autocorrect: false,
                  enableSuggestions: false,
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
                      tooltip:
                      _isPasswordShow ? '비밀번호 숨기기' : '비밀번호 표시',
                      onPressed: () {
                        setState(() {
                          _isPasswordShow = !_isPasswordShow;
                        });
                      },
                      icon: Icon(
                        _isPasswordShow
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    hintText: '비밀번호를 입력해 주세요',
                    hintStyle: const TextStyle(
                      color: AppColor.hint,
                    ),
                    filled: true,
                    fillColor: AppColor.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColor.inputBorder,
                      ),
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

                // 5. 비밀번호 확인 텍스트 필드
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '비밀번호 확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),

                TextField(
                  controller: _passwordConfirm,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  obscureText: !_isPasswordConfirmShow,
                  autocorrect: false,
                  enableSuggestions: false,
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
                      tooltip: _isPasswordConfirmShow
                          ? '비밀번호 숨기기'
                          : '비밀번호 표시',
                      onPressed: () {
                        setState(() {
                          _isPasswordConfirmShow =
                          !_isPasswordConfirmShow;
                        });
                      },
                      icon: Icon(
                        _isPasswordConfirmShow
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    hintText: '비밀번호를 한 번 더 입력해 주세요',
                    hintStyle: const TextStyle(
                      color: AppColor.hint,
                    ),
                    filled: true,
                    fillColor: AppColor.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColor.inputBorder,
                      ),
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

                const SizedBox(height: 36),

                // 6. 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _trySignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.inputFocusedBorder,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(
                      _isLoading ? '가입 중...' : '회원가입',
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
