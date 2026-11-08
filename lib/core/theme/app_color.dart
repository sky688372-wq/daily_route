import 'package:flutter/material.dart';

class AppColor {
  AppColor._(); // 인스턴스 만들지 못하도록

  // 1. 브랜드 색상
  static const Color primary = Color(0xFF087F83);
  static const Color secondary = Color(0xFF2F5257);
  static const Color accent = Color(0xFF0A9B9E);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 2. 배경 색상
  static const Color background = Color(0xFFF8FAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color selectedBackground = Color(0xFFF0F9F9);

  // 3. 글자 색상
  static const Color textPrimary = Color(0xFF191F28);
  static const Color textSecondary = Color(0xFF4E5968);
  static const Color textTertiary = Color(0xFF8B95A1);

  // 4. 테두리 및 구분선
  static const Color border = Color(0xFFE5E8EB);
  static const Color divider = Color(0xFFE5E8EB);

  // 5. 버튼 상태
  static const Color buttonPressed = Color(0xFF2F5257);
  static const Color buttonDisabled = Color(0xFFE5E8EB);
  static const Color onButtonDisabled = Color(0xFF8B95A1);

  // 6. 입력창
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE5E8EB);
  static const Color inputFocusedBorder = Color(0xFF087F83);
  static const Color hint = Color(0xFF8B95A1);
  static const Color focusRing = Color(0x33087F83);

  // 7. 상태 색상
  static const Color error = Color(0xFFD9383A);
  static const Color success = Color(0xFF0E8A57);
  static const Color warning = Color(0xFFC86A00);

  // 8. 오류 안내 영역
  static const Color errorBackground = Color(0xFFFFF5F5);
  static const Color errorBorder = Color(0xFFFCDAD7);

  // 9. 그림자 및 모달 배경
  static const Color floatingShadow = Color(0x14191F28);
  static const Color sheetShadow = Color(0x0F191F28);
  static const Color modalShadow = Color(0x29191F28);
  static const Color modalBarrier = Color(0x66191F28);
}
