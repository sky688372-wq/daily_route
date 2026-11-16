// 로그인 성공 시 토큰과 회원 정보를 저장하는 모델 클래스
class LoginData {
  // 필드
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final LoginUser user;

  // 기본 생성자
  LoginData({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  // 팩토리 생성자
  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      user: LoginUser.fromJson(
        Map<String, dynamic>.from(json['user']),
      ),
    );
  }
}

// 로그인한 회원 정보를 저장하는 모델 클래스
class LoginUser {
  // 필드
  final int id;
  final String nickname;
  final String email;

  // 기본 생성자
  LoginUser({
    required this.id,
    required this.nickname,
    required this.email,
  });

  // 팩토리 생성자
  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
    );
  }
}
