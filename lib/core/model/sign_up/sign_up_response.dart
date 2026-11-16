// 회원 가입 API 요청 후 응답을 저장하는 모델 클래스
class SignUpResponse {
  // 필드
  final bool success;
  final String message;
  final dynamic data;

  // 기본 생성자
  SignUpResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  // 팩토리 생성자
  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'],
    );
  }
}
