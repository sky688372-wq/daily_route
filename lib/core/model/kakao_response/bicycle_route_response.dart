import 'package:daily_route/core/model/kakao_response/walking_route_response.dart';

// 카카오 자전거 경로 API 응답 모델
class BicycleRouteResponse {
  // HTTP 200이어도 status가 OK가 아니면 경로가 없을 수 있음
  final String status;
  final WalkingRoute? route;

  const BicycleRouteResponse({
    required this.status,
    required this.route,
  });

  factory BicycleRouteResponse.fromJson(Map<String, dynamic> json) {
    final routeJson = json['route'];

    return BicycleRouteResponse(
      status: json['status'] as String? ?? '',
      // 자전거 경로의 route 구조가 도보 경로와 같아 기존 모델 재사용
      route: routeJson is Map
          ? WalkingRoute.fromJson(
        Map<String, dynamic>.from(routeJson),
      )
          : null,
    );
  }

  bool get isSuccess => status == 'OK' && route != null;
}
