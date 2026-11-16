// 카카오 좌표 → 주소 변환 API 응답 모델
class CoordinateToAddressResponse {
  final CoordinateToAddressMeta meta;
  final List<CoordinateAddressDocument> documents;

  const CoordinateToAddressResponse({
    required this.meta,
    required this.documents,
  });

  factory CoordinateToAddressResponse.fromJson(Map<String, dynamic> json) {
    return CoordinateToAddressResponse(
      meta: CoordinateToAddressMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map),
      ),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map(
            (item) => CoordinateAddressDocument.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

// 검색된 주소의 개수
class CoordinateToAddressMeta {
  final int totalCount;

  const CoordinateToAddressMeta({
    required this.totalCount,
  });

  factory CoordinateToAddressMeta.fromJson(Map<String, dynamic> json) {
    return CoordinateToAddressMeta(
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}

// 좌표에 해당하는 주소 한 건
class CoordinateAddressDocument {
  // 도로명 주소와 지번 주소가 각각 없을 수 있음
  final CoordinateRoadAddress? roadAddress;
  final CoordinateJibunAddress? address;

  const CoordinateAddressDocument({
    required this.roadAddress,
    required this.address,
  });

  factory CoordinateAddressDocument.fromJson(Map<String, dynamic> json) {
    final roadAddressJson = json['road_address'];
    final addressJson = json['address'];

    return CoordinateAddressDocument(
      roadAddress: roadAddressJson is Map
          ? CoordinateRoadAddress.fromJson(
        Map<String, dynamic>.from(roadAddressJson),
      )
          : null,
      address: addressJson is Map
          ? CoordinateJibunAddress.fromJson(
        Map<String, dynamic>.from(addressJson),
      )
          : null,
    );
  }

  // 화면에 표시할 때 도로명 주소를 우선 사용
  String get displayAddress {
    final roadName = roadAddress?.addressName ?? '';

    if (roadName.isNotEmpty) {
      return roadName;
    }

    return address?.addressName ?? '';
  }
}

// 도로명 주소
class CoordinateRoadAddress {
  final String addressName;
  final String region1DepthName;
  final String region2DepthName;
  final String region3DepthName;
  final String roadName;
  final String undergroundYn;
  final String mainBuildingNo;
  final String subBuildingNo;
  final String buildingName;
  final String zoneNo;

  const CoordinateRoadAddress({
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.roadName,
    required this.undergroundYn,
    required this.mainBuildingNo,
    required this.subBuildingNo,
    required this.buildingName,
    required this.zoneNo,
  });

  factory CoordinateRoadAddress.fromJson(Map<String, dynamic> json) {
    return CoordinateRoadAddress(
      addressName: json['address_name'] as String? ?? '',
      region1DepthName: json['region_1depth_name'] as String? ?? '',
      region2DepthName: json['region_2depth_name'] as String? ?? '',
      region3DepthName: json['region_3depth_name'] as String? ?? '',
      roadName: json['road_name'] as String? ?? '',
      undergroundYn: json['underground_yn'] as String? ?? '',
      mainBuildingNo: json['main_building_no'] as String? ?? '',
      subBuildingNo: json['sub_building_no'] as String? ?? '',
      buildingName: json['building_name'] as String? ?? '',
      zoneNo: json['zone_no'] as String? ?? '',
    );
  }
}

// 지번 주소
class CoordinateJibunAddress {
  final String addressName;
  final String region1DepthName;
  final String region2DepthName;
  final String region3DepthName;
  final String mountainYn;
  final String mainAddressNo;
  final String subAddressNo;
  final String zipCode;

  const CoordinateJibunAddress({
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.mountainYn,
    required this.mainAddressNo,
    required this.subAddressNo,
    required this.zipCode,
  });

  factory CoordinateJibunAddress.fromJson(Map<String, dynamic> json) {
    return CoordinateJibunAddress(
      addressName: json['address_name'] as String? ?? '',
      region1DepthName: json['region_1depth_name'] as String? ?? '',
      region2DepthName: json['region_2depth_name'] as String? ?? '',
      region3DepthName: json['region_3depth_name'] as String? ?? '',
      mountainYn: json['mountain_yn'] as String? ?? '',
      mainAddressNo: json['main_address_no'] as String? ?? '',
      subAddressNo: json['sub_address_no'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
    );
  }
}
