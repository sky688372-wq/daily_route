import 'package:daily_route/core/providers/current_location_controller.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:daily_route/core/kakao_map/map_sdk_initializer.dart';
import 'package:daily_route/core/model/kakao_response/place_search_response.dart';
import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/screen/main/home/home_map_overlay.dart';
import 'package:daily_route/screen/main/home/home_trip_controller.dart';
import 'package:daily_route/screen/main/home/place_search_screen.dart';
import 'package:daily_route/screen/main/home/widgets/trip_search_card.dart';
import 'package:daily_route/screen/main/home/widgets/trip_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onPrepareCall});
  final VoidCallback? onPrepareCall;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeTripController _trip;
  late final CurrentLocationController _location;
  Object? _lastPosition;
  bool _initialLocation = true;
  final _overlay = HomeMapOverlay();
  Timer? _readyTimer;
  Timer? _gestureTimer;
  bool _mapReady = false;
  bool _mapDelayed = false;
  int _mapGeneration = 0;
  Object? _lastOrigin;
  Object? _lastDestination;
  Object? _lastRoute;

  @override
  void initState() {
    super.initState();
    _trip = context.read<HomeTripController>();
    _location = context.read<CurrentLocationController>();
    _trip.addListener(_tripChanged);
    _location.addListener(_locationChanged);
    if (MapSdkInitializer.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_location.locate());
      });
    }
    _overlay.addListener(_overlayChanged);
    if (MapSdkInitializer.isInitialized) _startReadyTimer();
  }

  void _locationChanged() {
    if (!mounted) return;
    setState(() {});
    final position = _location.position;
    if (position == null || identical(position, _lastPosition)) return;
    _lastPosition = position;
    final center =
        _initialLocation && _trip.origin == null && _trip.destination == null;
    _initialLocation = false;
    if (_trip.origin == null && _location.place != null) {
      _trip.selectPlace(_location.place!, isOrigin: true);
    }
    if (_mapReady) {
      unawaited(
        _overlay.showCurrentLocation(
          position.latitude,
          position.longitude,
          center: center,
        ),
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_location.position == null) await _location.locate();
    if (!mounted || _location.place == null) return;
    _trip.selectPlace(_location.place!, isOrigin: true);
    final p = _location.position!;
    if (_mapReady) {
      unawaited(
        _overlay.showCurrentLocation(p.latitude, p.longitude, center: true),
      );
    }
  }

  void _overlayChanged() {
    if (mounted) setState(() {});
  }

  void _tripChanged() {
    if (!mounted) return;
    setState(() {});
    if (!identical(_lastOrigin, _trip.origin) ||
        !identical(_lastDestination, _trip.destination) ||
        !identical(_lastRoute, _trip.route)) {
      _lastOrigin = _trip.origin;
      _lastDestination = _trip.destination;
      _lastRoute = _trip.route;
      _syncMap();
    }
  }

  void _syncMap() {
    if (!_mapReady) return;
    unawaited(
      _overlay.update(
        origin: _trip.origin,
        destination: _trip.destination,
        route: _trip.route,
        viewportSize: MediaQuery.sizeOf(context),
        topPadding: MediaQuery.viewPaddingOf(context).top + 215,
        bottomPadding:
            MediaQuery.paddingOf(context).bottom + (_trip.canSearch ? 190 : 24),
      ),
    );
  }

  void _startReadyTimer() {
    _readyTimer?.cancel();
    _readyTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && !_mapReady) setState(() => _mapDelayed = true);
    });
  }

  void _onMapCreated(KakaoMapController controller) {
    _readyTimer?.cancel();
    if (!mounted) return;
    _overlay.attach(controller, MediaQuery.devicePixelRatioOf(context));
    setState(() {
      _mapReady = true;
      _mapDelayed = false;
    });
    _syncMap();
    final position = _location.position;
    if (position != null) {
      unawaited(
        _overlay.showCurrentLocation(position.latitude, position.longitude),
      );
    }
  }

  void _reloadMap() {
    _overlay.detach();
    setState(() {
      _mapReady = false;
      _mapDelayed = false;
      _mapGeneration++;
    });
    _startReadyTimer();
  }

  Future<void> _selectPlace(bool isOrigin) async {
    final place = await Navigator.of(context).push<KakaoPlace>(
      MaterialPageRoute(
        builder: (_) =>
            PlaceSearchScreen(title: isOrigin ? '출발지 검색' : '목적지 검색'),
      ),
    );
    if (!mounted || place == null) return;
    _trip.selectPlace(place, isOrigin: isOrigin);
  }

  void _onPointerUp(PointerEvent _) {
    _gestureTimer?.cancel();
    _gestureTimer = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_overlay.project()),
    );
  }

  @override
  void dispose() {
    _readyTimer?.cancel();
    _gestureTimer?.cancel();
    _trip.removeListener(_tripChanged);
    _overlay.removeListener(_overlayChanged);
    _location.removeListener(_locationChanged);
    _overlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (MapSdkInitializer.isInitialized)
          Listener(
            onPointerDown: (_) {
              _gestureTimer?.cancel();
              _overlay.hideWhileMoving();
            },
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerUp,
            child: KakaoMap(
              key: ValueKey(_mapGeneration),
              onMapCreated: _onMapCreated,
              initialPosition: const LatLng(
                latitude: 37.5665,
                longitude: 126.9780,
              ),
              initialLevel: 15,
              logo: Logo(
                alignment: LogoAlignment.bottomLeft,
                offset: Offset(16, -(bottom + (_trip.canSearch ? 210 : 20))),
              ),
            ),
          )
        else
          ColoredBox(
            color: AppColor.background,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  MapSdkInitializer.unavailableMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    height: 1.6,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        IgnorePointer(
          child: CustomPaint(painter: RouteLinePainter(_overlay.screenPoints)),
        ),
        Positioned(
          top: MediaQuery.viewPaddingOf(context).top + 12,
          left: 16,
          right: 16,
          child: TripSearchCard(
            origin: _trip.origin?.placeName,
            destination: _trip.destination?.placeName,
            onOrigin: () => _selectPlace(true),
            onDestination: () => _selectPlace(false),
            onSwap: _trip.swap,
            onCurrentLocation: _useCurrentLocation,
            locating: _location.isLoading,
          ),
        ),
        if (MapSdkInitializer.isInitialized && !_mapReady)
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top + 220,
            left: 20,
            right: 20,
            child: Material(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _mapDelayed
                          ? '지도를 불러오지 못했어요. 인터넷 연결과 지도 인증 설정을 확인해 주세요.'
                          : '지도를 불러오고 있어요.',
                      textAlign: TextAlign.center,
                    ),
                    if (_mapDelayed)
                      TextButton(
                        onPressed: _reloadMap,
                        child: const Text('다시 시도'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: bottom + (_trip.canSearch ? 260 : 30),
          child: Material(
            color: AppColor.surface,
            elevation: 2,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: '내 위치로 이동',
              onPressed: _location.isLoading
                  ? null
                  : () async {
                      await _location.locate();
                      final p = _location.position;
                      if (mounted && p != null && _mapReady) {
                        unawaited(
                          _overlay.showCurrentLocation(
                            p.latitude,
                            p.longitude,
                            center: true,
                          ),
                        );
                      }
                    },
              icon: Icon(
                Icons.my_location,
                color: _location.position == null
                    ? AppColor.textSecondary
                    : AppColor.primary,
              ),
            ),
          ),
        ),
        if (_location.error != null)
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top + 215,
            left: 20,
            right: 20,
            child: Material(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _location.error!,
                  style: const TextStyle(fontSize: 12, color: AppColor.error),
                ),
              ),
            ),
          ),
        if (_trip.canSearch)
          Positioned(
            bottom: bottom + 12,
            left: 16,
            right: 16,
            child: TripSummaryCard(
              trip: _trip,
              mapError: _overlay.error,
              onPrepareCall: widget.onPrepareCall,
            ),
          ),
      ],
    );
  }
}
