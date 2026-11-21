import 'package:daily_route/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const questions = {
      '이 앱으로 실제 택시를 부를 수 있나요?':
          '아니요. DB 수행평가를 위한 프로젝트로 실제 접수·예약·배차와 연결되지 않아요. 호출 기능은 모의 방식으로 개발하고 있어요.',
      '안내된 대기시간에 차량이 도착하나요?':
          '과거 평균 대기시간은 이동 계획을 위한 참고값이에요. 실제 대기·배차시간과 다를 수 있고 도착 시각을 보장하지 않아요.',
      '차고지에 표시된 차량을 이용할 수 있나요?': '차고지 위치는 실시간 차량 위치나 배차 가능 여부를 의미하지 않아요.',
      '어떤 정보를 변경할 수 있나요?':
          '내 정보 수정에서 닉네임을, 비밀번호 변경에서 비밀번호를 바꿀 수 있어요. 이메일 변경은 제공하지 않아요.',
      '비밀번호를 잊어버렸어요.':
          '현재 비밀번호를 알고 있다면 비밀번호 변경 메뉴를 이용해 주세요. 이메일을 통한 비밀번호 재설정 기능은 아직 준비 중이에요.',
      '앱을 다시 켜면 자동으로 로그인되나요?':
          '앱 재시작 시 로그인 정보를 복구하는 기능은 아직 연결되지 않았어요. 현재는 시작 화면에서 로그인해 주세요.',
      '정보를 저장하지 못했다는 안내가 나와요.':
          '네트워크와 로컬 서버 실행 상태를 확인하고 다시 시도해 주세요. 로그인이 만료되었다면 로그아웃한 뒤 다시 로그인해 주세요.',
    };
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('자주 묻는 질문'),
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '궁금한 내용을 확인해 보세요.',
              style: TextStyle(color: AppColor.textSecondary),
            ),
            const SizedBox(height: 20),
            for (final entry in questions.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColor.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColor.border),
                  ),
                  child: ExpansionTile(
                    key: PageStorageKey(entry.key),
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.value,
                        style: const TextStyle(
                          height: 1.7,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
