import 'package:daily_route/core/model/login/login_data.dart';

// 내 정보 조회·수정 API의 응답 모델
class UserResponse {
  final bool success;
  final String message;
  final LoginUser? data;

  UserResponse({required this.success, required this.message, this.data});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : LoginUser.fromJson(Map<String, dynamic>.from(json['data'])),
    );
  }
}
