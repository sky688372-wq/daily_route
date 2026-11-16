// 로그인 API 요청 후 응답을 저장하는 모델 클래스
import 'package:daily_route/core/model/login/login_data.dart';

class LoginResponse {
  // 필드
  final bool success;
  final String message;
  final LoginData? data;

  // 기본 생성자
  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  // 팩토리 생성자
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : LoginData.fromJson(
        Map<String, dynamic>.from(json['data']),
      ),
    );
  }
}