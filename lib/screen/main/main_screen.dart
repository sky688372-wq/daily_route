import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/screen/main/home/home_screen.dart';
import 'package:daily_route/screen/main/my/my_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭 인덱스
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            // 1. 홈 화면
            HomeScreen(),

            // 2. 호출 화면
            // todo: 호출 화면 구현 후 교체
            Center(child: Text('호출 화면')),

            // 3. 이용내역 화면
            // todo: 이용내역 화면 구현 후 교체
            Center(child: Text('이용내역 화면')),

            // 4. 내 정보 화면
            MyScreen()
          ],
        ),
      ),

      // 5. 바텀 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColor.background,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          // 홈
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),

          // 호출
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi_outlined),
            activeIcon: Icon(Icons.local_taxi),
            label: '호출',
          ),

          // 이용내역
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: '이용내역',
          ),

          // 내 정보
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}
