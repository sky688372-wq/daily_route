import 'package:daily_route/core/model/kakao_response/address_search_response.dart';
import 'package:daily_route/core/model/kakao_response/bicycle_route_response.dart';
import 'package:daily_route/core/model/kakao_response/car_route_response.dart';
import 'package:daily_route/core/model/kakao_response/coordinate_to_address_response.dart';
import 'package:daily_route/core/model/kakao_response/place_search_response.dart';
import 'package:daily_route/core/model/kakao_response/transit_route_response.dart';
import 'package:daily_route/core/model/kakao_response/walking_route_response.dart';
import 'package:daily_route/core/secret/app_secret.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// 카카오 API를 관리하는 클래스
class KakaoApiService {
  // 민감 정보는 별도 파일에서 관리
  static const String _restApiKey = AppSecret.kakaoRestApiKey;

  // 카카오 API 요청용 Dio
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  // 1. 주소로 좌표를 변환하는 API
  // 반환 형태: Future<AddressSearchResponse>
  // 검색된 주소 목록과 좌표, 검색 결과 정보를 반환
  static Future<AddressSearchResponse> addressToCoordinate({
    required String address,
  }) async {
    if (address.trim().isEmpty) {
      throw ArgumentError('주소를 입력해 주세요.');
    }

    final response = await _request(
      apiName: '주소 → 좌표 변환',
      url: 'https://dapi.kakao.com/v2/local/search/address.json',
      queryParameters: {'query': address.trim()},
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('주소 검색 응답이 JSON 객체가 아닙니다.');
    }

    return AddressSearchResponse.fromJson(Map<String, dynamic>.from(data));
  }

  // 2. 좌표로 주소를 변환하는 API
  // 반환 형태: Future<CoordinateToAddressResponse>
  // 해당 좌표의 도로명 주소·지번 주소와 검색 결과 개수를 반환
  static Future<CoordinateToAddressResponse> coordinateToAddress({
    required double longitude,
    required double latitude,
  }) async {
    final response = await _request(
      apiName: '좌표 → 주소 변환',
      url: 'https://dapi.kakao.com/v2/local/geo/coord2address.json',
      queryParameters: {'x': longitude, 'y': latitude, 'input_coord': 'WGS84'},
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('좌표 → 주소 응답이 JSON 객체가 아닙니다.');
    }

    return CoordinateToAddressResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // 3. 키워드로 장소를 검색하는 API
  // 반환 형태: Future<PlaceSearchResponse>
  // 검색된 장소 목록과 페이지 정보를 반환
  static Future<PlaceSearchResponse> searchPlace({
    required String keyword,
    double? longitude,
    double? latitude,
  }) async {
    if (keyword.trim().isEmpty) {
      throw ArgumentError('검색어를 입력해 주세요.');
    }

    // 위치 기준 검색을 하려면 경도와 위도가 모두 필요
    if ((longitude == null) != (latitude == null)) {
      throw ArgumentError('경도와 위도를 함께 입력해 주세요.');
    }

    final response = await _request(
      apiName: '장소 검색',
      url: 'https://dapi.kakao.com/v2/local/search/keyword.json',
      queryParameters: {
        'query': keyword.trim(),
        'size': 5,
        if (longitude != null && latitude != null) ...{
          'x': longitude,
          'y': latitude,
          'sort': 'distance',
        },
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('장소 검색 응답이 JSON 객체가 아닙니다.');
    }

    return PlaceSearchResponse.fromJson(Map<String, dynamic>.from(data));
  }

  // 4. 도보 경로를 조회하는 API
  // 반환 형태: Future<WalkingRouteResponse>
  // 탐색 상태, 총 거리·소요시간, 구간·단계별 안내와 경로 좌표를 반환
  static Future<WalkingRouteResponse> getWalkingRoute({
    required double startLongitude,
    required double startLatitude,
    required double endLongitude,
    required double endLatitude,
  }) async {
    final response = await _request(
      apiName: '도보 경로 조회',
      url: 'https://dapi.kakao.com/v2/routing/walk',
      queryParameters: {
        'start_x': startLongitude,
        'start_y': startLatitude,
        'end_x': endLongitude,
        'end_y': endLatitude,
        'input_coord': 'WGS84',
        'output_coord': 'WGS84',
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('도보 경로 응답이 JSON 객체가 아닙니다.');
    }

    return WalkingRouteResponse.fromJson(Map<String, dynamic>.from(data));
  }

  // 5. 자전거 경로를 조회하는 API
  // 반환 형태: Future<BicycleRouteResponse>
  // 탐색 상태, 총 거리·소요시간, 구간·단계별 안내와 경로 좌표를 반환
  static Future<BicycleRouteResponse> getBicycleRoute({
    required double startLongitude,
    required double startLatitude,
    required double endLongitude,
    required double endLatitude,
  }) async {
    final response = await _request(
      apiName: '자전거 경로 조회',
      url: 'https://dapi.kakao.com/v2/routing/bicycle',
      queryParameters: {
        'start_x': startLongitude,
        'start_y': startLatitude,
        'end_x': endLongitude,
        'end_y': endLatitude,
        'input_coord': 'WGS84',
        'output_coord': 'WGS84',
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('자전거 경로 응답이 JSON 객체가 아닙니다.');
    }

    return BicycleRouteResponse.fromJson(Map<String, dynamic>.from(data));
  }

  // 6. 대중교통 경로를 조회하는 API
  // 반환 형태: Future<TransitRouteResponse>
  // 탐색 상태, 경로별 시간·거리·환승·요금·정류장·경로 좌표를 반환
  static Future<TransitRouteResponse> getTransitRoute({
    required double startLongitude,
    required double startLatitude,
    required double endLongitude,
    required double endLatitude,
  }) async {
    final response = await _request(
      apiName: '대중교통 경로 조회',
      url: 'https://dapi.kakao.com/v2/routing/publictraffic',
      queryParameters: {
        'start_x': startLongitude,
        'start_y': startLatitude,
        'end_x': endLongitude,
        'end_y': endLatitude,
        'input_coord': 'WGS84',
        'output_coord': 'WGS84',
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('대중교통 경로 응답이 JSON 객체가 아닙니다.');
    }

    return TransitRouteResponse.fromJson(Map<String, dynamic>.from(data));
  }

  // 7. 자동차 경로를 조회하는 API
  // 카카오모빌리티 자동차 길찾기 API 사용
  // 반환 형태: Future<CarRouteResponse>
  // 길찾기 결과, 자동차 이동 거리·시간, 도로·안내·경로 좌표를 반환
  static Future<CarRouteResponse> getCarRoute({
    required double startLongitude,
    required double startLatitude,
    required double endLongitude,
    required double endLatitude,
  }) async {
    final response = await _request(
      apiName: '자동차 경로 조회',
      url: 'https://apis-navi.kakaomobility.com/v1/directions',
      queryParameters: {
        'origin': '$startLongitude,$startLatitude',
        'destination': '$endLongitude,$endLatitude',
        'priority': 'RECOMMEND',
        'summary': 'false',
        'alternatives': 'false',
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('자동차 경로 응답이 JSON 객체가 아닙니다.');
    }

    return CarRouteResponse.fromJson(Map<String, dynamic>.from(data));
  }

  // 8. 공통 API 요청
  // 반환 형태: Future<Response<dynamic>>
  // 원본 응답을 반환하며, 디버그 모드에서는 상태 코드만 출력
  static Future<Response<dynamic>> _request({
    required String apiName,
    required String url,
    required Map<String, dynamic> queryParameters,
  }) async {
    if (_restApiKey.trim().isEmpty) {
      throw StateError('AppSecret.kakaoRestApiKey에 REST API 키를 입력해 주세요.');
    }

    _log('\n========== $apiName 시작 ==========');

    try {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: {'Authorization': 'KakaoAK ${_restApiKey.trim()}'},
        ),
      );

      _log('[$apiName] HTTP 상태 코드: ${response.statusCode}');

      return response;
    } on DioException catch (e) {
      _log('[$apiName] API 요청 실패');
      _log('[$apiName] 오류 종류: ${e.type.name}');
      _log('[$apiName] HTTP 상태 코드: ${e.response?.statusCode}');

      if (e.response == null) {
        _log('[$apiName] 서버 응답을 받지 못했습니다.');
      }

      // 화면에서 실패를 감지할 수 있도록 예외를 다시 전달
      rethrow;
    } finally {
      _log('========== $apiName 종료 ==========\n');
    }
  }

  // 9. 디버그 모드에서만 안전한 상태 로그 출력
  // 반환 형태: void
  static void _log(String message) {
    if (!kDebugMode) return;

    final key = _restApiKey.trim();
    final safeMessage = key.isEmpty
        ? message
        : message.replaceAll(key, '[API_KEY_HIDDEN]');

    for (final line in safeMessage.split('\n')) {
      debugPrint(line, wrapWidth: 1000);
    }
  }
}
