import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 토큰 저장 관리 클래스
class TokenStorage {
  TokenStorage._();

  // 보안 저장소
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // 토큰 저장 키
  static const String _accessTokenKey = 'access_token';

  // 1. 토큰 저장
  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  // 2. 토큰 조회
  static Future<String?> getToken() async {
    return await _storage.read(
      key: _accessTokenKey,
    );
  }

  // 3. 토큰 삭제
  static Future<void> deleteToken() async {
    await _storage.delete(
      key: _accessTokenKey,
    );
  }
}
