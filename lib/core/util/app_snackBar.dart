import 'package:daily_route/core/theme/app_color.dart';
import 'package:flutter/material.dart';

// 공통 스낵바 관리 클래스
class AppSnackBar {
  AppSnackBar._();

  // 안내 메시지 표시
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    // 기존 스낵바를 닫고 새 메시지 표시
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColor.accent,
        behavior: SnackBarBehavior.floating,
        content: Text(
            message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}
