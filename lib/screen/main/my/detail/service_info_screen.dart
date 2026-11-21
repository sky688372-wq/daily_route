import 'package:daily_route/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class ServiceInfoScreen extends StatelessWidget {
  const ServiceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('서비스 소개'),
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 이동을 함께 준비해요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '데일리루트는 서울 장애인콜택시 이용자와 보호자의 이동 준비를 돕기 위해 만드는 DB 수행평가 프로젝트예요.',
                    style: TextStyle(
                      height: 1.7,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '이동 계획에 필요한 정보를 한곳에',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '출발지·목적지와 이동 일정을 바탕으로 과거 평균 대기시간, 차량 운행시간, 날씨를 함께 확인하는 것을 목표로 해요.',
                    style: TextStyle(
                      height: 1.7,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '현재 개발 중인 기능',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '지도와 경로 안내, 이동 지원 설정, 자주 가는 장소, 모의 호출과 이용내역은 순차적으로 개발하고 있어요. 화면과 기능은 개발 과정에서 달라질 수 있어요.',
                    style: TextStyle(
                      height: 1.7,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '실제 차량을 호출하지 않아요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '이 프로젝트의 호출은 학습을 위한 모의 기능이에요. 실제 장애인콜택시 접수·예약·배차와 연결되지 않아요.',
                    style: TextStyle(
                      height: 1.7,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
