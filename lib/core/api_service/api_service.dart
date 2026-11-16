// API 관련 요청 관리 클래스
import 'package:daily_route/core/model/login/login_response.dart';
import 'package:daily_route/core/model/sign_up/sign_up_response.dart';
import 'package:dio/dio.dart';

class ApiService {
  // dio 객체 생성
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
      },
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
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      print('로그인 상태 코드: ${response.statusCode}');
      print('로그인 모델 변환 시작');

      final result = LoginResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      print('로그인 모델 변환 완료');
      print('로그인 성공 여부: ${result.success}');

      return result;
    } on DioException catch (e) {
      final data = e.response?.data;

      print('로그인 통신 오류 종류: ${e.type}');
      print('로그인 상태 코드: ${e.response?.statusCode}');

      if (data is Map<String, dynamic>) {
        return LoginResponse.fromJson(data);
      }

      rethrow;
    } catch (e, stackTrace) {
      print('로그인 응답 처리 오류 종류: ${e.runtimeType}');
      print('로그인 응답 처리 오류 위치:\n$stackTrace');

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

      print('회원가입 상태 코드: ${response.statusCode}');
      print('회원가입 응답: ${response.data}');

      return SignUpResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        print('회원가입 실패 상태 코드: ${e.response?.statusCode}');
        print('회원가입 실패 응답: $data');

        return SignUpResponse.fromJson(data);
      } else {
        print('회원가입 연결 또는 응답 오류: ${e.type}');
        print('회원가입 오류 메시지: ${e.message}');

        rethrow;
      }
    }
  }
}
