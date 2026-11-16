// 카카오 도보 경로 API 응답 모델
class WalkingRouteResponse {
  // HTTP 200이어도 status가 OK가 아니면 경로가 없을 수 있음
  final String status;
  final WalkingRoute? route;

  const WalkingRouteResponse({
    required this.status,
    required this.route,
  });

  factory WalkingRouteResponse.fromJson(Map<String, dynamic> json) {
    final routeJson = json['route'];

    return WalkingRouteResponse(
      status: json['status'] as String? ?? '',
      route: routeJson is Map
          ? WalkingRoute.fromJson(
        Map<String, dynamic>.from(routeJson),
      )
          : null,
    );
  }

  bool get isSuccess => status == 'OK' && route != null;
}

// 전체 도보 경로
class WalkingRoute {
  final WalkingRouteProperties properties;
  final List<WalkingLeg> legs;

  const WalkingRoute({
    required this.properties,
    required this.legs,
  });

  factory WalkingRoute.fromJson(Map<String, dynamic> json) {
    return WalkingRoute(
      properties: WalkingRouteProperties.fromJson(
        Map<String, dynamic>.from(json['properties'] as Map),
      ),
      legs: (json['legs'] as List<dynamic>? ?? [])
          .map(
            (item) => WalkingLeg.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

// 전체 경로의 거리·시간·카카오맵 링크
class WalkingRouteProperties {
  // 거리: 미터, 시간: 초
  final int totalDistance;
  final int totalTime;
  final String landingUrl;

  const WalkingRouteProperties({
    required this.totalDistance,
    required this.totalTime,
    required this.landingUrl,
  });

  factory WalkingRouteProperties.fromJson(Map<String, dynamic> json) {
    return WalkingRouteProperties(
      totalDistance: json['totalDistance'] as int? ?? 0,
      totalTime: json['totalTime'] as int? ?? 0,
      landingUrl: json['landingUrl'] as String? ?? '',
    );
  }
}

// 경로의 구간
class WalkingLeg {
  final WalkingLegProperties properties;
  final List<WalkingStep> steps;

  const WalkingLeg({
    required this.properties,
    required this.steps,
  });

  factory WalkingLeg.fromJson(Map<String, dynamic> json) {
    return WalkingLeg(
      properties: WalkingLegProperties.fromJson(
        Map<String, dynamic>.from(json['properties'] as Map),
      ),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map(
            (item) => WalkingStep.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

// 구간별 거리·시간
class WalkingLegProperties {
  // 거리: 미터, 시간: 초
  final int distance;
  final int time;

  const WalkingLegProperties({
    required this.distance,
    required this.time,
  });

  factory WalkingLegProperties.fromJson(Map<String, dynamic> json) {
    return WalkingLegProperties(
      distance: json['distance'] as int? ?? 0,
      time: json['time'] as int? ?? 0,
    );
  }
}

// 경로의 개별 이동 단계
class WalkingStep {
  final WalkingStepProperties properties;
  final WalkingStepPath path;

  const WalkingStep({
    required this.properties,
    required this.path,
  });

  factory WalkingStep.fromJson(Map<String, dynamic> json) {
    return WalkingStep(
      properties: WalkingStepProperties.fromJson(
        Map<String, dynamic>.from(json['properties'] as Map),
      ),
      path: WalkingStepPath.fromJson(
        Map<String, dynamic>.from(json['path'] as Map),
      ),
    );
  }
}

// 개별 이동 단계의 안내·거리·시간·시작 좌표
class WalkingStepProperties {
  // 거리: 미터, 시간: 초
  final int distance;
  final String guidance;
  final int time;

  // x: 경도, y: 위도
  final double x;
  final double y;

  const WalkingStepProperties({
    required this.distance,
    required this.guidance,
    required this.time,
    required this.x,
    required this.y,
  });

  factory WalkingStepProperties.fromJson(Map<String, dynamic> json) {
    return WalkingStepProperties(
      distance: json['distance'] as int? ?? 0,
      guidance: json['guidance'] as String? ?? '',
      time: json['time'] as int? ?? 0,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}

// 지도에 경로선을 그릴 때 사용할 좌표 목록
class WalkingStepPath {
  // 각 좌표는 [경도, 위도] 순서
  final List<WalkingPoint> points;

  const WalkingStepPath({
    required this.points,
  });

  factory WalkingStepPath.fromJson(Map<String, dynamic> json) {
    return WalkingStepPath(
      points: (json['points'] as List<dynamic>? ?? [])
          .map(
            (item) => WalkingPoint.fromJson(item as List<dynamic>),
      )
          .toList(),
    );
  }
}

// 경로선의 좌표 한 점
class WalkingPoint {
  final double longitude;
  final double latitude;

  const WalkingPoint({
    required this.longitude,
    required this.latitude,
  });

  factory WalkingPoint.fromJson(List<dynamic> json) {
    if (json.length < 2) {
      throw const FormatException('도보 경로 좌표가 올바르지 않습니다.');
    }

    return WalkingPoint(
      longitude: (json[0] as num).toDouble(),
      latitude: (json[1] as num).toDouble(),
    );
  }
}
