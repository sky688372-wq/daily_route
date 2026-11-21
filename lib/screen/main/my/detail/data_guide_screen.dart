import 'package:daily_route/core/theme/app_color.dart';
import 'package:flutter/material.dart';

// todo: 실제 연동 데이터셋의 기관·원문 링크·기준일과 날씨 제공 기관 확정
class DataGuideScreen extends StatelessWidget {
  const DataGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('데이터 출처 및 이용 안내'),
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
                    '과거 평균 대기시간',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '서울 장애인콜택시 관련 공공데이터를 활용할 예정이에요. 과거 평균값은 이동 계획을 위한 참고 정보이며 실시간 대기시간이나 배차 보장이 아니에요.',
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
                    '지도·장소·자동차 경로',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '카카오맵과 카카오 로컬 API, 카카오모빌리티 자동차 길찾기 API를 활용하는 코드를 준비하고 있어요. 제공되는 운행시간은 실제 교통 상황에 따라 달라질 수 있어요.',
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
                    '차고지 위치',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '차고지의 위치와 기본 정보를 안내할 예정이에요. 차고지 위치가 현재 차량 위치나 이용 가능한 차량 수를 뜻하지는 않아요.',
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
                    '날씨',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '날씨 정보는 아직 연동 전이에요. 연동 후에도 예보 제공 범위를 벗어난 일정은 날씨를 확인할 수 없고, 예보는 바뀔 수 있어요.',
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
                    '출처 확인과 갱신',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '공공데이터의 정확한 데이터셋명, 제공 기관, 원문 링크, 기준일과 날씨 제공 기관은 실제 연동 시 확인하여 추가할 예정이에요. 현재 앱에서 실시간 제공을 보장하지 않아요.',
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
