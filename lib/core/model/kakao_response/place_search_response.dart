// 카카오 장소 검색 API 응답 모델
class PlaceSearchResponse {
  final List<KakaoPlace> documents;
  final PlaceSearchMeta meta;

  const PlaceSearchResponse({
    required this.documents,
    required this.meta,
  });

  factory PlaceSearchResponse.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResponse(
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map(
            (item) => KakaoPlace.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      meta: PlaceSearchMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map),
      ),
    );
  }
}

// 검색된 장소 한 개
class KakaoPlace {
  final String id;
  final String placeName;
  final String categoryName;
  final String categoryGroupCode;
  final String categoryGroupName;
  final String phone;
  final String addressName;
  final String roadAddressName;
  final String placeUrl;

  // 카카오 응답에서는 좌표와 거리가 문자열로 전달됨
  final String x;
  final String y;
  final String distance;

  const KakaoPlace({
    required this.id,
    required this.placeName,
    required this.categoryName,
    required this.categoryGroupCode,
    required this.categoryGroupName,
    required this.phone,
    required this.addressName,
    required this.roadAddressName,
    required this.placeUrl,
    required this.x,
    required this.y,
    required this.distance,
  });

  factory KakaoPlace.fromJson(Map<String, dynamic> json) {
    return KakaoPlace(
      id: json['id'] as String? ?? '',
      placeName: json['place_name'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      categoryGroupCode: json['category_group_code'] as String? ?? '',
      categoryGroupName: json['category_group_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressName: json['address_name'] as String? ?? '',
      roadAddressName: json['road_address_name'] as String? ?? '',
      placeUrl: json['place_url'] as String? ?? '',
      x: json['x'] as String? ?? '',
      y: json['y'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
    );
  }

  // 1. x는 경도
  double? get longitude => double.tryParse(x);

  // 2. y는 위도
  double? get latitude => double.tryParse(y);

  // 3. 검색 기준 좌표를 전달하지 않으면 distance가 빈 문자열일 수 있음
  // 값이 있다면 단위는 미터
  int? get distanceInMeters => int.tryParse(distance);

  // 4. 도로명 주소가 없는 장소는 지번 주소 사용
  String get displayAddress {
    return roadAddressName.isNotEmpty
        ? roadAddressName
        : addressName;
  }
}

// 검색 결과와 페이지 정보
class PlaceSearchMeta {
  final bool isEnd;
  final int pageableCount;
  final int totalCount;

  // 검색어에 대한 지역 분석 정보가 없으면 null일 수 있음
  final PlaceSearchSameName? sameName;

  const PlaceSearchMeta({
    required this.isEnd,
    required this.pageableCount,
    required this.totalCount,
    required this.sameName,
  });

  factory PlaceSearchMeta.fromJson(Map<String, dynamic> json) {
    final sameNameJson = json['same_name'];

    return PlaceSearchMeta(
      isEnd: json['is_end'] as bool? ?? true,
      pageableCount: json['pageable_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
      sameName: sameNameJson is Map
          ? PlaceSearchSameName.fromJson(
        Map<String, dynamic>.from(sameNameJson),
      )
          : null,
    );
  }
}

// 검색어의 지역·키워드 분석 정보
class PlaceSearchSameName {
  final String keyword;
  final List<String> region;
  final String selectedRegion;

  const PlaceSearchSameName({
    required this.keyword,
    required this.region,
    required this.selectedRegion,
  });

  factory PlaceSearchSameName.fromJson(Map<String, dynamic> json) {
    return PlaceSearchSameName(
      keyword: json['keyword'] as String? ?? '',
      region: (json['region'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      selectedRegion: json['selected_region'] as String? ?? '',
    );
  }
}
