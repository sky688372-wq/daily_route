import 'package:daily_route/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // 입력 컨트롤러
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
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

      // 배경색
      backgroundColor: AppColor.background,

      // 시작점
      body: SafeArea(
        child: SingleChildScrollView(
          // 가상 키보드 상태의 오버플로우 막기
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 제목
                const Text(
                  '비밀번호 찾기',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // 안내 문구
                const Text(
                  '가입한 이메일 주소를 입력해 주세요.\n비밀번호 재설정 링크를 보내드릴게요.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColor.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // 이메일 입력
                const Text(
                  '이메일',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '이메일 주소를 입력해 주세요',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColor.hint,
                    ),
                    filled: true,
                    fillColor: AppColor.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.inputBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.inputFocusedBorder,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 비밀번호 재설정 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final email = _emailCtrl.text.trim();

                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('이메일 주소를 입력해 주세요.'),
                          ),
                        );
                        return;
                      }

                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('올바른 이메일 주소를 입력해 주세요.'),
                          ),
                        );
                        return;
                      }

                      FocusScope.of(context).unfocus();

                      // todo: 비밀번호 재설정 이메일 발송 API 연결
                      // todo: API 응답에 따라 성공 또는 오류 안내

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호 재설정 기능은 준비 중입니다.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '재설정 링크 받기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 로그인 화면으로 돌아가기
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.textSecondary,
                    ),
                    child: const Text(
                      '로그인으로 돌아가기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
