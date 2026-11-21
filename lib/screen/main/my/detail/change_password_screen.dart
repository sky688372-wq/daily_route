import 'package:daily_route/core/api_service/api_service.dart';
import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/core/util/app_snackBar.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isSaving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // 1. 현재 비밀번호 확인은 서버에서 처리
  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final result = await ApiService.changePassword(
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
      );
      if (!mounted) return;
      if (!result.success) {
        AppSnackBar.show(
          context,
          result.message.isEmpty ? '비밀번호를 변경하지 못했어요.' : result.message,
        );
        return;
      }
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
      Navigator.pop(context, result.message);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, '변경하지 못했어요. 서버와 네트워크 연결을 확인해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: AppColor.background,
        appBar: AppBar(
          title: const Text('비밀번호 변경'),
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
                  '새 비밀번호를 설정해요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '현재 비밀번호를 확인한 뒤 변경할 수 있어요.\n다음 로그인부터 새 비밀번호를 사용해 주세요.',
                  style: TextStyle(height: 1.6, color: AppColor.textSecondary),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _currentCtrl,
                  enabled: !_isSaving,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '현재 비밀번호',
                    filled: true,
                    fillColor: AppColor.surface,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? '현재 비밀번호를 입력해 주세요.'
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _newCtrl,
                  enabled: !_isSaving,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '새 비밀번호',
                    helperText: '8~64자로 입력해 주세요.',
                    filled: true,
                    fillColor: AppColor.surface,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final length = (value ?? '').runes.length;
                    if (length < 8 || length > 64) {
                      return '새 비밀번호는 8~64자로 입력해 주세요.';
                    }
                    if (value == _currentCtrl.text) {
                      return '현재 비밀번호와 다르게 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmCtrl,
                  enabled: !_isSaving,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: '새 비밀번호 확인',
                    filled: true,
                    fillColor: AppColor.surface,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value != _newCtrl.text || (value ?? '').isEmpty
                      ? '새 비밀번호가 일치하지 않아요.'
                      : null,
                  onFieldSubmitted: (_) => _save(),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('비밀번호 표시'),
                  value: !_obscure,
                  activeColor: AppColor.primary,
                  onChanged: _isSaving
                      ? null
                      : (value) => setState(() => _obscure = !(value ?? false)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.onPrimary,
                    ),
                    child: Text(_isSaving ? '변경 중...' : '비밀번호 변경하기'),
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
