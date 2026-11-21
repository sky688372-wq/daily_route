// API 관련 요청 관리 클래스
import 'package:daily_route/core/model/login/login_response.dart';
import 'package:daily_route/core/model/sign_up/sign_up_response.dart';
import 'package:daily_route/core/model/user/user_response.dart';
import 'package:daily_route/core/util/token_storage.dart';
import 'package:dio/dio.dart';

class ApiService {
  // dio 객체 생성
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // 1. 로그인 요청 API
  static Future<LoginResponse> tryLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      final result = LoginResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      return result;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return LoginResponse.fromJson(data);
      }

      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // 2. 회원 가입 요청 API
  static Future<SignUpResponse> trySignUp({
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/signup',
        data: {
          'nickname': nickname.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      return SignUpResponse.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return SignUpResponse.fromJson(data);
      } else {
        rethrow;
      }
    }
  }

  // 3. 로그인한 사용자 조회
  // 반환 형태: Future<UserResponse> (data: LoginUser?)
  static Future<UserResponse> getMyInfo() async {
    return UserResponse.fromJson(await _userRequest('/api/users/me'));
  }

  // 4. 닉네임 수정
  // 반환 형태: Future<UserResponse> (data: 변경된 LoginUser?)
  static Future<UserResponse> updateMyInfo({required String nickname}) async {
    return UserResponse.fromJson(
      await _userRequest('/api/users/me', data: {'nickname': nickname.trim()}),
    );
  }

  // 5. 비밀번호 변경
  // 반환 형태: Future<SignUpResponse> (성공 여부와 안내, data: null)
  static Future<SignUpResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return SignUpResponse.fromJson(
      await _userRequest(
        '/api/users/me/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      ),
    );
  }

  // 6. 본인 정보 API 요청: 매 요청마다 보안 저장소에서 인증 정보 조회
  // 반환 형태: Future<Map<String, dynamic>>
  static Future<Map<String, dynamic>> _userRequest(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': '다시 로그인해 주세요.', 'data': null};
    }

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        options: Options(
          method: data == null ? 'GET' : 'PATCH',
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': '로그인이 만료되었어요. 로그아웃한 뒤 다시 로그인해 주세요.',
          'data': null,
        };
      }
      final body = e.response?.data;
      if (body is Map<String, dynamic>) return body;
      rethrow;
    }
  }
}
