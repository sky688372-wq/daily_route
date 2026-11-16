// 카카오 주소 검색 API 응답 모델
class AddressSearchResponse {
  final List<KakaoAddressDocument> documents;
  final AddressSearchMeta meta;

  const AddressSearchResponse({
    required this.documents,
    required this.meta,
  });

  factory AddressSearchResponse.fromJson(Map<String, dynamic> json) {
    return AddressSearchResponse(
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map(
            (item) => KakaoAddressDocument.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      meta: AddressSearchMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map),
      ),
    );
  }
}

// 검색된 주소 한 건
class KakaoAddressDocument {
  final String addressName;
  final String addressType;

  // 주소 검색 결과에서 제공되는 대표 좌표
  // x: 경도, y: 위도
  final String x;
  final String y;

  // 검색 결과에 따라 한쪽이 null일 수 있음
  final KakaoJibunAddress? address;
  final KakaoRoadAddress? roadAddress;

  const KakaoAddressDocument({
    required this.addressName,
    required this.addressType,
    required this.x,
    required this.y,
    required this.address,
    required this.roadAddress,
  });

  factory KakaoAddressDocument.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'];
    final roadAddressJson = json['road_address'];

    return KakaoAddressDocument(
      addressName: json['address_name'] as String? ?? '',
      addressType: json['address_type'] as String? ?? '',
      x: json['x'] as String? ?? '',
      y: json['y'] as String? ?? '',
      address: addressJson is Map
          ? KakaoJibunAddress.fromJson(
        Map<String, dynamic>.from(addressJson),
      )
          : null,
      roadAddress: roadAddressJson is Map
          ? KakaoRoadAddress.fromJson(
        Map<String, dynamic>.from(roadAddressJson),
      )
          : null,
    );
  }

  double? get longitude => double.tryParse(x);
  double? get latitude => double.tryParse(y);
}

// 지번 주소 정보
class KakaoJibunAddress {
  final String addressName;
  final String bCode;
  final String hCode;
  final String mainAddressNo;
  final String mountainYn;
  final String region1DepthName;
  final String region2DepthName;
  final String region3DepthHName;
  final String region3DepthName;
  final String subAddressNo;
  final String x;
  final String y;

  const KakaoJibunAddress({
    required this.addressName,
    required this.bCode,
    required this.hCode,
    required this.mainAddressNo,
    required this.mountainYn,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthHName,
    required this.region3DepthName,
    required this.subAddressNo,
    required this.x,
    required this.y,
  });

  factory KakaoJibunAddress.fromJson(Map<String, dynamic> json) {
    return KakaoJibunAddress(
      addressName: json['address_name'] as String? ?? '',
      bCode: json['b_code'] as String? ?? '',
      hCode: json['h_code'] as String? ?? '',
      mainAddressNo: json['main_address_no'] as String? ?? '',
      mountainYn: json['mountain_yn'] as String? ?? '',
      region1DepthName: json['region_1depth_name'] as String? ?? '',
      region2DepthName: json['region_2depth_name'] as String? ?? '',
      region3DepthHName: json['region_3depth_h_name'] as String? ?? '',
      region3DepthName: json['region_3depth_name'] as String? ?? '',
      subAddressNo: json['sub_address_no'] as String? ?? '',
      x: json['x'] as String? ?? '',
      y: json['y'] as String? ?? '',
    );
  }
}

// 도로명 주소 정보
class KakaoRoadAddress {
  final String addressName;
  final String buildingName;
  final String mainBuildingNo;
  final String region1DepthName;
  final String region2DepthName;
  final String region3DepthName;
  final String roadName;
  final String subBuildingNo;
  final String undergroundYn;
  final String x;
  final String y;
  final String zoneNo;

  const KakaoRoadAddress({
    required this.addressName,
    required this.buildingName,
    required this.mainBuildingNo,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.roadName,
    required this.subBuildingNo,
    required this.undergroundYn,
    required this.x,
    required this.y,
    required this.zoneNo,
  });

  factory KakaoRoadAddress.fromJson(Map<String, dynamic> json) {
    return KakaoRoadAddress(
      addressName: json['address_name'] as String? ?? '',
      buildingName: json['building_name'] as String? ?? '',
      mainBuildingNo: json['main_building_no'] as String? ?? '',
      region1DepthName: json['region_1depth_name'] as String? ?? '',
      region2DepthName: json['region_2depth_name'] as String? ?? '',
      region3DepthName: json['region_3depth_name'] as String? ?? '',
      roadName: json['road_name'] as String? ?? '',
      subBuildingNo: json['sub_building_no'] as String? ?? '',
      undergroundYn: json['underground_yn'] as String? ?? '',
      x: json['x'] as String? ?? '',
      y: json['y'] as String? ?? '',
      zoneNo: json['zone_no'] as String? ?? '',
    );
  }
}

// 검색 결과와 페이지 정보
class AddressSearchMeta {
  final bool isEnd;
  final int pageableCount;
  final int totalCount;

  const AddressSearchMeta({
    required this.isEnd,
    required this.pageableCount,
    required this.totalCount,
  });

  factory AddressSearchMeta.fromJson(Map<String, dynamic> json) {
    return AddressSearchMeta(
      isEnd: json['is_end'] as bool? ?? true,
      pageableCount: json['pageable_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}
