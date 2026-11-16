import 'dart:async';
import 'dart:convert';

import 'package:daily_route/core/theme/app_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<dynamic>? _cameraMoveEndSubscription;

  // 1. 지도가 생성되면 상태와 지도 이동 결과를 확인
  void _onMapCreated(KakaoMapController controller) {
    debugPrint('========== 카카오맵 생성 완료 ==========');
    debugPrint(
      '[카카오맵] 초기 지도 설정: '
          '${jsonEncode({
        'latitude': 37.5665,
        'longitude': 126.9780,
        'level': 15,
      })}',
    );

    _cameraMoveEndSubscription =
        controller.onCameraMoveEndStream.listen((event) {
          // 지도 중심을 이동한 뒤 좌표가 어떤 형태로 전달되는지 확인
          debugPrint(
            '[카카오맵] 카메라 이동 완료: '
                '${jsonEncode({
              'latitude': event.latitude,
              'longitude': event.longitude,
            })}',
          );
        });
  }

  // 2. 화면이 종료되면 지도 이벤트 구독 해제
  @override
  void dispose() {
    _cameraMoveEndSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: KakaoMap(
        onMapCreated: _onMapCreated,
        initialPosition: const LatLng(
          latitude: 37.5665,
          longitude: 126.9780,
        ),
        initialLevel: 15,
      ),
    );
  }
}
