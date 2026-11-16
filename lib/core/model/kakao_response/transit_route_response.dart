// 카카오 대중교통 경로 API 응답 모델
class TransitRouteResponse {
  // HTTP 200이어도 status가 OK가 아닐 수 있음
  final String status;
  final TransitSearchProperties? properties;

  // 경로 탐색에 실패하면 routes가 없을 수 있음
  final List<TransitRoute> routes;

  const TransitRouteResponse({
    required this.status,
    required this.properties,
    required this.routes,
  });

  factory TransitRouteResponse.fromJson(Map<String, dynamic> json) {
    final propertiesJson = json['properties'];

    return TransitRouteResponse(
      status: json['status'] as String? ?? '',
      properties: propertiesJson is Map
          ? TransitSearchProperties.fromJson(
        Map<String, dynamic>.from(propertiesJson),
      )
          : null,
      routes: (json['routes'] as List<dynamic>? ?? [])
          .map(
            (item) => TransitRoute.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }

  bool get isSuccess => status == 'OK' && routes.isNotEmpty;
}

// 검색된 경로의 개수와 카카오맵 링크
class TransitSearchProperties {
  final int total;
  final int bus;
  final int subway;
  final int busAndSubway;
  final String landingUrl;

  const TransitSearchProperties({
    required this.total,
    required this.bus,
    required this.subway,
    required this.busAndSubway,
    required this.landingUrl,
  });

  factory TransitSearchProperties.fromJson(Map<String, dynamic> json) {
    return TransitSearchProperties(
      total: json['total'] as int? ?? 0,
      bus: json['bus'] as int? ?? 0,
      subway: json['subway'] as int? ?? 0,
      busAndSubway: json['busAndSubway'] as int? ?? 0,

      // 이 API 응답은 URL의 대문자가 포함된 landingURL 사용
      landingUrl: json['landingURL'] as String? ?? '',
    );
  }
}

// 대중교통 경로 한 개
class TransitRoute {
  final TransitRouteProperties properties;
  final List<TransitStep> steps;

  const TransitRoute({
    required this.properties,
    required this.steps,
  });

  factory TransitRoute.fromJson(Map<String, dynamic> json) {
    return TransitRoute(
      properties: TransitRouteProperties.fromJson(
        Map<String, dynamic>.from(json['properties'] as Map),
      ),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map(
            (item) => TransitStep.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

// 경로 한 개의 이동수단·거리·시간·환승·요금
class TransitRouteProperties {
  final String type;
  final int totalDistance; // 미터
  final int totalTime; // 초
  final int transfers;
  final TransitFare? fare;

  const TransitRouteProperties({
    required this.type,
    required this.totalDistance,
    required this.totalTime,
    required this.transfers,
    required this.fare,
  });

  factory TransitRouteProperties.fromJson(Map<String, dynamic> json) {
    final fareJson = json['fare'];

    return TransitRouteProperties(
      type: json['type'] as String? ?? '',
      totalDistance: json['totalDistance'] as int? ?? 0,
      totalTime: json['totalTime'] as int? ?? 0,
      transfers: json['transfers'] as int? ?? 0,
      fare: fareJson is Map
          ? TransitFare.fromJson(Map<String, dynamic>.from(fareJson))
          : null,
    );
  }
}

// 요금은 단일 금액 또는 최소·최대 금액으로 올 수 있음
class TransitFare {
  final int? value;
  final int? min;
  final int? max;

  const TransitFare({
    required this.value,
    required this.min,
    required this.max,
  });

  factory TransitFare.fromJson(Map<String, dynamic> json) {
    return TransitFare(
      value: json['value'] as int?,
      min: json['min'] as int?,
      max: json['max'] as int?,
    );
  }
}

// 버스·지하철·도보 등 개별 이동 단계
class TransitStep {
  final TransitStepProperties properties;
  final TransitStepPath? path;

  const TransitStep({
    required this.properties,
    required this.path,
  });

  factory TransitStep.fromJson(Map<String, dynamic> json) {
    final pathJson = json['path'];

    return TransitStep(
      properties: TransitStepProperties.fromJson(
        Map<String, dynamic>.from(json['properties'] as Map),
      ),
      path: pathJson is Map
          ? TransitStepPath.fromJson(
        Map<String, dynamic>.from(pathJson),
      )
          : null,
    );
  }
}

// 단계별 안내와 정류장·교통수단 목록
class TransitStepProperties {
  final String guidance;
  final String type;
  final int distance; // 미터
  final int time; // 초
  final List<TransitStop> stops;
  final List<TransitVehicle> vehicles;

  const TransitStepProperties({
    required this.guidance,
    required this.type,
    required this.distance,
    required this.time,
    required this.stops,
    required this.vehicles,
  });

  factory TransitStepProperties.fromJson(Map<String, dynamic> json) {
    return TransitStepProperties(
      guidance: json['guidance'] as String? ?? '',
      type: json['type'] as String? ?? '',
      distance: json['distance'] as int? ?? 0,
      time: json['time'] as int? ?? 0,
      stops: (json['stops'] as List<dynamic>? ?? [])
          .map(
            (item) => TransitStop.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      vehicles: (json['vehicles'] as List<dynamic>? ?? [])
          .map(
            (item) => TransitVehicle.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

// 정류장 한 개
class TransitStop {
  final String name;

  const TransitStop({
    required this.name,
  });

  factory TransitStop.fromJson(Map<String, dynamic> json) {
    return TransitStop(
      name: json['name'] as String? ?? '',
    );
  }
}

// 버스·지하철 등 교통수단 한 개
class TransitVehicle {
  final String name;
  final String type;

  const TransitVehicle({
    required this.name,
    required this.type,
  });

  factory TransitVehicle.fromJson(Map<String, dynamic> json) {
    return TransitVehicle(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

// 지도에 단계별 경로선을 그릴 때 사용할 좌표
class TransitStepPath {
  final List<TransitPoint> points;

  const TransitStepPath({
    required this.points,
  });

  factory TransitStepPath.fromJson(Map<String, dynamic> json) {
    return TransitStepPath(
      points: (json['points'] as List<dynamic>? ?? [])
          .map(
            (item) => TransitPoint.fromJson(item as List<dynamic>),
      )
          .toList(),
    );
  }
}

// 각 좌표는 [경도, 위도] 순서
class TransitPoint {
  final double longitude;
  final double latitude;

  const TransitPoint({
    required this.longitude,
    required this.latitude,
  });

  factory TransitPoint.fromJson(List<dynamic> json) {
    if (json.length < 2 || json[0] is! num || json[1] is! num) {
      throw const FormatException('대중교통 경로 좌표가 올바르지 않습니다.');
    }

    return TransitPoint(
      longitude: (json[0] as num).toDouble(),
      latitude: (json[1] as num).toDouble(),
    );
  }
}
