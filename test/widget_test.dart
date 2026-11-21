import 'package:daily_route/core/providers/current_location_controller.dart';
import 'package:daily_route/screen/main/home/home_trip_controller.dart';
import 'package:daily_route/core/model/kakao_response/place_search_response.dart';
import 'package:daily_route/screen/main/call/call_screen.dart';
import 'package:daily_route/core/model/login/login_data.dart';
import 'package:daily_route/core/providers/user_provider.dart';
import 'package:daily_route/screen/main/my/detail/change_password_screen.dart';
import 'package:daily_route/screen/main/my/detail/edit_profile_screen.dart';
import 'package:daily_route/screen/main/my/detail/faq_screen.dart';
import 'package:daily_route/screen/main/my/my_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserProvider userProvider;
  late bool deletedToken;
  setUp(() {
    deletedToken = false;
    userProvider = UserProvider()
      ..setUser(LoginUser(id: 1, nickname: '테스트회원', email: 'test@example.com'));
    PackageInfo.setMockInitialValues(
      appName: 'daily_route',
      packageName: 'test.daily_route',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            if (call.method == 'delete') deletedToken = true;
            return null;
          },
        );
  });
  Future<void> show(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: userProvider,
        child: MaterialApp(home: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('프로필에서 정보 수정 화면으로 이동한다', (tester) async {
    await show(tester, const MyScreen());
    expect(find.text('테스트회원님'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    await tester.tap(find.text('내 정보 수정'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('테스트회원'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('잘못된 닉네임은 저장하지 않는다', (tester) async {
    await show(tester, const EditProfileScreen());
    await tester.enterText(find.byType(TextFormField), '가');
    await tester.tap(find.text('저장하기'));
    await tester.pumpAndSettle();
    expect(find.text('닉네임은 2~20자로 입력해 주세요.'), findsNWidgets(2));
    expect(userProvider.user!.nickname, '테스트회원');
  });
  testWidgets('비밀번호 확인이 다르면 전송하지 않는다', (tester) async {
    await show(tester, const ChangePasswordScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'initial-password');
    await tester.enterText(fields.at(1), 'changed-password');
    await tester.enterText(fields.at(2), 'different-password');
    await tester.ensureVisible(find.text('비밀번호 변경하기'));
    await tester.tap(find.text('비밀번호 변경하기'));
    await tester.pumpAndSettle();
    expect(find.text('새 비밀번호가 일치하지 않아요.'), findsOneWidget);
  });
  testWidgets('FAQ에서 모의 호출 안내를 펼친다', (tester) async {
    await show(tester, const FaqScreen());
    await tester.tap(find.text('이 앱으로 실제 택시를 부를 수 있나요?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('실제 접수·예약·배차와 연결되지 않아요.'), findsOneWidget);
  });
  testWidgets('로그아웃을 확인했을 때만 로그인 정보를 삭제한다', (tester) async {
    await show(tester, const MyScreen());
    await tester.scrollUntilVisible(find.text('로그아웃'), 400);
    expect(find.text('버전 1.0.0 (1)'), findsOneWidget);
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(userProvider.hasUser, isTrue);
    expect(deletedToken, isFalse);
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '로그아웃'));
    await tester.pumpAndSettle();
    expect(userProvider.hasUser, isFalse);
    expect(deletedToken, isTrue);
    expect(find.byType(MyScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('호출 준비에서 공유된 출발지·목적지를 표시하고 이용내역으로 이동한다', (tester) async {
    final trip = HomeTripController();
    trip.selectPlace(
      KakaoPlace.fromJson({
        'id': 'one',
        'place_name': '공유 출발지',
        'x': '126.97',
        'y': '37.56',
      }),
      isOrigin: true,
    );
    trip.selectPlace(
      KakaoPlace.fromJson({
        'id': 'two',
        'place_name': '공유 목적지',
        'x': '126.98',
        'y': '37.57',
      }),
      isOrigin: false,
    );
    await show(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: trip),
          ChangeNotifierProvider(create: (_) => CurrentLocationController()),
        ],
        child: const CallScreen(),
      ),
    );
    expect(find.text('공유 출발지'), findsOneWidget);
    expect(find.text('공유 목적지'), findsOneWidget);
    expect(find.text('학습용 모의 호출이에요. 실제 차량은 배차되지 않아요.'), findsOneWidget);
    await tester.tap(find.text('이용내역'));
    await tester.pumpAndSettle();
    expect(find.text('내 이용내역'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    trip.dispose();
  });
}
