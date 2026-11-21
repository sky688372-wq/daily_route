import 'package:daily_route/core/providers/current_location_controller.dart';
import 'package:daily_route/screen/main/home/home_trip_controller.dart';
import 'package:provider/provider.dart';
import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/screen/main/home/home_screen.dart';
import 'package:daily_route/screen/main/call/call_screen.dart';
import 'package:daily_route/screen/main/my/my_screen.dart';
import 'package:daily_route/screen/main/widgets/main_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭 인덱스
  int _currentIndex = 0;
  final _trip = HomeTripController();
  final _location = CurrentLocationController();

  @override
  void dispose() {
    _trip.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _trip),
        ChangeNotifierProvider.value(value: _location),
      ],
      child: Scaffold(
        backgroundColor: AppColor.background,
        extendBody: _currentIndex == 0,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // 1. 홈 화면
            HomeScreen(onPrepareCall: () => setState(() => _currentIndex = 1)),

            // 2. 호출 화면 (호출 준비·이용내역)
            const CallScreen(),

            // 3. 내 정보 화면
            const MyScreen(),
          ],
        ),

        // 4. 캡슐 모양의 플로팅 바텀 네비게이션 바
        bottomNavigationBar: MainBottomNavigationBar(
          translucent: _currentIndex == 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}
