import 'package:daily_route/core/api_service/api_service.dart';
import 'package:daily_route/core/providers/user_provider.dart';
import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/core/util/app_snackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController(
      text: context.read<UserProvider>().user?.nickname ?? '',
    );
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  // 1. 서버 저장이 성공한 경우에만 앱의 사용자 정보 갱신
  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final result = await ApiService.updateMyInfo(
        nickname: _nicknameCtrl.text,
      );
      if (!mounted) return;
      if (!result.success || result.data == null) {
        AppSnackBar.show(
          context,
          result.message.isEmpty ? '정보를 저장하지 못했어요.' : result.message,
        );
        return;
      }
      context.read<UserProvider>().setUser(result.data!);
      Navigator.pop(context, result.message);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, '저장하지 못했어요. 서버와 네트워크 연결을 확인해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: AppColor.background,
        appBar: AppBar(
          title: const Text('내 정보 수정'),
          backgroundColor: AppColor.background,
          foregroundColor: AppColor.textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  '어떻게 불러드릴까요?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '닉네임은 2~20자로 입력해 주세요.',
                  style: TextStyle(color: AppColor.textSecondary),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nicknameCtrl,
                  enabled: !_isSaving,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    filled: true,
                    fillColor: AppColor.surface,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final length = (value ?? '').trim().runes.length;
                    return length < 2 || length > 20
                        ? '닉네임은 2~20자로 입력해 주세요.'
                        : null;
                  },
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 24),
                const Text(
                  '가입 이메일',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '회원 정보를 확인할 수 없어요.',
                  style: const TextStyle(color: AppColor.textSecondary),
                ),
                const SizedBox(height: 8),
                const Text(
                  '이메일은 이 화면에서 변경할 수 없어요.',
                  style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving || user == null ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.onPrimary,
                    ),
                    child: Text(_isSaving ? '저장 중...' : '저장하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
