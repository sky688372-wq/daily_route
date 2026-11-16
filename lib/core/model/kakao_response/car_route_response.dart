// 카카오모빌리티 자동차 길찾기 API 응답 모델
class CarRouteResponse {
  final String transId;
  final List<CarRoute> routes;

  const CarRouteResponse({
    required this.transId,
    required this.routes,
  });

  factory CarRouteResponse.fromJson(Map<String, dynamic> json) {
    return CarRouteResponse(
      transId: json['trans_id'] as String? ?? '',
      routes: (json['routes'] as List<dynamic>? ?? [])
          .map(
            (item) => CarRoute.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }

  // HTTP 200이어도 실제 길찾기가 실패했을 수 있음
  bool get isSuccess => routes.any((route) => route.resultCode == 0);
}

// 탐색된 자동차 경로 한 개
class CarRoute {
  final int resultCode;
  final String resultMsg;
  final CarRouteSummary? summary;
  final List<CarSection> sections;

  const CarRoute({
    required this.resultCode,
    required this.resultMsg,
    required this.summary,
    required this.sections,
  });

  factory CarRoute.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'];

    return CarRoute(
      resultCode: json['result_code'] as int? ?? -1,
      resultMsg: json['result_msg'] as String? ?? '',
      summary: summaryJson is Map
          ? CarRouteSummary.fromJson(
        Map<String, dynamic>.from(summaryJson),
      )
          : null,
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map(
            (item) => CarSection.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }

  bool get isSuccess => resultCode == 0 && summary != null;
}

// 자동차 경로의 출발지·목적지·총 거리·시간
class CarRouteSummary {
  final CarLocation origin;
  final CarLocation destination;
  final List<CarLocation> waypoints;
  final String priority;
  final CarBound? bound;
  final CarFare? fare;

  final int distance; // 미터
  final int duration; // 초

  const CarRouteSummary({
    required this.origin,
    required this.destination,
    required this.waypoints,
    required this.priority,
    required this.bound,
    required this.fare,
    required this.distance,
    required this.duration,
  });

  factory CarRouteSummary.fromJson(Map<String, dynamic> json) {
    final boundJson = json['bound'];
    final fareJson = json['fare'];

    return CarRouteSummary(
      origin: CarLocation.fromJson(
        Map<String, dynamic>.from(json['origin'] as Map),
      ),
      destination: CarLocation.fromJson(
        Map<String, dynamic>.from(json['destination'] as Map),
      ),
      waypoints: (json['waypoints'] as List<dynamic>? ?? [])
          .map(
            (item) => CarLocation.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      priority: json['priority'] as String? ?? '',
      bound: boundJson is Map
          ? CarBound.fromJson(Map<String, dynamic>.from(boundJson))
          : null,
      fare: fareJson is Map
          ? CarFare.fromJson(Map<String, dynamic>.from(fareJson))
          : null,
      distance: json['distance'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
    );
  }
}

// 출발지·목적지·경유지 좌표
class CarLocation {
  final String name;
  final double x; // 경도
  final double y; // 위도

  const CarLocation({
    required this.name,
    required this.x,
    required this.y,
  });

  factory CarLocation.fromJson(Map<String, dynamic> json) {
    return CarLocation(
      name: json['name'] as String? ?? '',
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}

// 경로가 포함되는 지도 영역
class CarBound {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  const CarBound({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  factory CarBound.fromJson(Map<String, dynamic> json) {
    return CarBound(
      minX: (json['min_x'] as num).toDouble(),
      minY: (json['min_y'] as num).toDouble(),
      maxX: (json['max_x'] as num).toDouble(),
      maxY: (json['max_y'] as num).toDouble(),
    );
  }
}

// 카카오 응답의 택시 예상 요금과 통행료
// 장애인콜택시의 실제 요금으로 사용하면 안 됨
class CarFare {
  final int taxi;
  final int toll;

  const CarFare({
    required this.taxi,
    required this.toll,
  });

  factory CarFare.fromJson(Map<String, dynamic> json) {
    return CarFare(
      taxi: json['taxi'] as int? ?? 0,
      toll: json['toll'] as int? ?? 0,
    );
  }
}

// 자동차 경로의 구간
class CarSection {
  final int distance; // 미터
  final int duration; // 초
  final CarBound? bound;
  final List<CarRoad> roads;
  final List<CarGuide> guides;

  const CarSection({
    required this.distance,
    required this.duration,
    required this.bound,
    required this.roads,
    required this.guides,
  });

  factory CarSection.fromJson(Map<String, dynamic> json) {
    final boundJson = json['bound'];

    return CarSection(
      distance: json['distance'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      bound: boundJson is Map
          ? CarBound.fromJson(Map<String, dynamic>.from(boundJson))
          : null,
      roads: (json['roads'] as List<dynamic>? ?? [])
          .map(
            (item) => CarRoad.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      guides: (json['guides'] as List<dynamic>? ?? [])
          .map(
            (item) => CarGuide.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

// 도로 한 구간과 그 구간의 경로 좌표
class CarRoad {
  final String name;
  final int distance; // 미터
  final int duration; // 초
  final double trafficSpeed;
  final int trafficState;

  // 카카오 응답은 [경도, 위도, 경도, 위도, ...] 형식
  final List<CarPoint> points;

  const CarRoad({
    required this.name,
    required this.distance,
    required this.duration,
    required this.trafficSpeed,
    required this.trafficState,
    required this.points,
  });

  factory CarRoad.fromJson(Map<String, dynamic> json) {
    final vertexes = json['vertexes'] as List<dynamic>? ?? [];

    if (vertexes.length.isOdd) {
      throw const FormatException(
        '자동차 경로의 vertexes 좌표 개수가 올바르지 않습니다.',
      );
    }

    final points = <CarPoint>[];

    for (int i = 0; i < vertexes.length; i += 2) {
      if (vertexes[i] is! num || vertexes[i + 1] is! num) {
        throw const FormatException(
          '자동차 경로의 vertexes 좌표값이 숫자가 아닙니다.',
        );
      }

      points.add(
        CarPoint(
          longitude: (vertexes[i] as num).toDouble(),
          latitude: (vertexes[i + 1] as num).toDouble(),
        ),
      );
    }

    return CarRoad(
      name: json['name'] as String? ?? '',
      distance: json['distance'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      trafficSpeed: (json['traffic_speed'] as num?)?.toDouble() ?? 0,
      trafficState: json['traffic_state'] as int? ?? 0,
      points: points,
    );
  }
}

// 자동차 경로선의 좌표 한 점
class CarPoint {
  final double longitude;
  final double latitude;

  const CarPoint({
    required this.longitude,
    required this.latitude,
  });
}

// 출발지·회전·도착지 등의 길 안내
class CarGuide {
  final String name;
  final double x; // 경도
  final double y; // 위도
  final int distance; // 미터
  final int duration; // 초
  final int type;
  final String guidance;
  final int roadIndex;

  const CarGuide({
    required this.name,
    required this.x,
    required this.y,
    required this.distance,
    required this.duration,
    required this.type,
    required this.guidance,
    required this.roadIndex,
  });

  factory CarGuide.fromJson(Map<String, dynamic> json) {
    return CarGuide(
      name: json['name'] as String? ?? '',
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      distance: json['distance'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      guidance: json['guidance'] as String? ?? '',
      roadIndex: json['road_index'] as int? ?? -1,
    );
  }
}
