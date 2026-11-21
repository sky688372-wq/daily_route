import 'package:daily_route/core/api_service/api_service.dart';
import 'package:daily_route/screen/main/my/detail/edit_profile_screen.dart';
import 'package:daily_route/screen/main/my/detail/change_password_screen.dart';
import 'package:daily_route/screen/main/my/detail/service_info_screen.dart';
import 'package:daily_route/screen/main/my/detail/data_guide_screen.dart';
import 'package:daily_route/screen/main/my/detail/faq_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:daily_route/core/providers/user_provider.dart';
import 'package:daily_route/core/theme/app_color.dart';
import 'package:daily_route/core/util/app_snackBar.dart';
import 'package:daily_route/core/util/token_storage.dart';
import 'package:daily_route/screen/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// 1. 외부 링크 설정: 사용할 주소를 따옴표 안에 입력
const String developerPortfolioUrl = ''; // todo 넣기
const String githubProjectUrl = 'https://github.com/sky688372-wq/daily_route';
const String techBlogUrl = 'https://velog.io/@han090213/posts';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoggingOut = false;

  String _versionLabel = '앱 버전 확인 중...';
  bool _isRefreshing = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshProfile();
    });
  }

  // 2. 설치된 앱의 버전과 최신 회원 정보 확인
  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(
        () => _versionLabel = '버전 ${info.version} (${info.buildNumber})',
      );
    } catch (_) {
      if (mounted) setState(() => _versionLabel = '앱 버전을 확인하지 못했어요');
    }
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing || _isLoggingOut) return;
    final previousUser = context.read<UserProvider>().user;
    setState(() => _isRefreshing = true);
    try {
      final result = await ApiService.getMyInfo();
      if (!mounted || _isLoggingOut) return;
      if (result.success && result.data != null) {
        // 조회 중 닉네임을 수정했다면 이전 응답으로 덮어쓰지 않음
        if (identical(context.read<UserProvider>().user, previousUser)) {
          context.read<UserProvider>().setUser(result.data!);
        }
        setState(() => _profileError = null);
      } else {
        setState(
          () => _profileError = result.message.isEmpty
              ? '회원 정보를 새로 불러오지 못했어요.'
              : result.message,
        );
      }
    } catch (_) {
      if (mounted && !_isLoggingOut) {
        setState(
          () => _profileError = '회원 정보를 새로 불러오지 못했어요. 아래로 당겨 다시 시도해 주세요.',
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // 3. 외부 링크 열기
  Future<void> _openExternalLink(String url) async {
    final address = url.trim();

    if (address.isEmpty) {
      AppSnackBar.show(context, '링크를 준비 중이에요.');
      return;
    }

    final uri = Uri.tryParse(address);

    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      AppSnackBar.show(context, '링크 주소를 확인해 주세요.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        AppSnackBar.show(context, '링크를 열지 못했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, '링크를 열지 못했습니다.');
    }
  }

  // 4. 로그아웃 확인 후 저장된 로그인 정보 삭제
  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColor.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColor.error,
                size: 26,
              ),
              SizedBox(width: 9),
              Flexible(
                child: Text(
                  '정말 로그아웃할까요?',
                  style: TextStyle(
                    color: AppColor.error,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            '로그아웃하면 자동 로그인이 해제돼요.\n다시 이용하려면 로그인해 주세요.',
            style: TextStyle(color: AppColor.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(color: AppColor.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColor.error),
              child: const Text(
                '로그아웃',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // 저장된 로그인 토큰 삭제
      await TokenStorage.deleteToken();

      if (!mounted) return;

      // 앱 메모리의 사용자 정보 삭제
      context.read<UserProvider>().clearUser();

      // 이전 화면으로 돌아갈 수 없도록 웰컴 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, '로그아웃하지 못했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: AppColor.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              // 5. 화면 제목
              const Text(
                '내 정보',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                '데일리루트와 함께하는 나의 이동',
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
              ),
              const SizedBox(height: 24),

              // 6. 프로필 카드
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColor.primary, AppColor.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColor.floatingShadow,
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'MY PROFILE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 21),
                    Text(
                      user == null ? '회원 정보 확인 전' : '${user.nickname}님',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ?? '로그인 후 정보를 확인할 수 있어요',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '오늘의 이동도 편안하게 준비해요',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 29),

              if (_profileError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _profileError!,
                    style: const TextStyle(color: AppColor.error, height: 1.5),
                  ),
                ),

              // 7. 계정 관리
              const Text(
                '계정 관리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: AppColor.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColor.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F5F4),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: AppColor.primary,
                        ),
                      ),
                      title: const Text(
                        '내 정보 수정',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('닉네임 등 계정 정보 변경'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () async {
                        final message = await Navigator.of(context)
                            .push<String>(
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                        if (!context.mounted) return;
                        if (message != null && message.isNotEmpty) {
                          AppSnackBar.show(context, message);
                        }
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 74,
                      color: AppColor.divider,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEBFA),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF7063AF),
                        ),
                      ),
                      title: const Text(
                        '비밀번호 변경',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('계정 비밀번호 관리'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () async {
                        final message = await Navigator.of(context)
                            .push<String>(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                        if (!context.mounted) return;
                        if (message != null && message.isNotEmpty) {
                          AppSnackBar.show(context, message);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 27),

              // 8. 데일리루트 알아보기
              const Text(
                '데일리루트 알아보기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: AppColor.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColor.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3FE),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF4285BC),
                        ),
                      ),
                      title: const Text(
                        '서비스 소개',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('데일리루트가 제공하는 기능'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () async {
                        final message = await Navigator.of(context)
                            .push<String>(
                              MaterialPageRoute(
                                builder: (context) => const ServiceInfoScreen(),
                              ),
                            );
                        if (!context.mounted) return;
                        if (message != null && message.isNotEmpty) {
                          AppSnackBar.show(context, message);
                        }
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 74,
                      color: AppColor.divider,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F5EC),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.dataset_outlined,
                          color: Color(0xFF3D9460),
                        ),
                      ),
                      title: const Text(
                        '데이터 출처 및 이용 안내',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('데이터와 예상 시간에 관한 안내'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () async {
                        final message = await Navigator.of(context)
                            .push<String>(
                              MaterialPageRoute(
                                builder: (context) => const DataGuideScreen(),
                              ),
                            );
                        if (!context.mounted) return;
                        if (message != null && message.isNotEmpty) {
                          AppSnackBar.show(context, message);
                        }
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 74,
                      color: AppColor.divider,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2E3),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Color(0xFFD58A31),
                        ),
                      ),
                      title: const Text(
                        '자주 묻는 질문',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('앱 이용에 관한 도움말'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () async {
                        final message = await Navigator.of(context)
                            .push<String>(
                              MaterialPageRoute(
                                builder: (context) => const FaqScreen(),
                              ),
                            );
                        if (!context.mounted) return;
                        if (message != null && message.isNotEmpty) {
                          AppSnackBar.show(context, message);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 27),

              // 9. 만든 사람
              const Text(
                '만든 사람',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: AppColor.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColor.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCECF2),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.language_outlined,
                          color: Color(0xFFCB648B),
                        ),
                      ),
                      title: const Text(
                        '개발자 포트폴리오',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('개발자의 작업 살펴보기'),
                      trailing: const Icon(
                        Icons.open_in_new,
                        size: 19,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () => _openExternalLink(developerPortfolioUrl),
                    ),
                    const Divider(
                      height: 1,
                      indent: 74,
                      color: AppColor.divider,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0F5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.code, color: Color(0xFF586477)),
                      ),
                      title: const Text(
                        'GitHub 프로젝트',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('프로젝트 코드 확인하기'),
                      trailing: const Icon(
                        Icons.open_in_new,
                        size: 19,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () => _openExternalLink(githubProjectUrl),
                    ),
                    const Divider(
                      height: 1,
                      indent: 74,
                      color: AppColor.divider,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E8),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.edit_note_outlined,
                          color: Color(0xFFC77746),
                        ),
                      ),
                      title: const Text(
                        '기술 블로그',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('개발 기록 살펴보기'),
                      trailing: const Icon(
                        Icons.open_in_new,
                        size: 19,
                        color: AppColor.textTertiary,
                      ),
                      onTap: () => _openExternalLink(techBlogUrl),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),

              Center(
                child: Text(
                  _versionLabel,
                  style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
                ),
              ),
              const SizedBox(height: 18),

              // 10. 로그아웃 버튼
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isLoggingOut ? null : _logout,
                  icon: const Icon(Icons.logout, size: 19),
                  label: Text(
                    _isLoggingOut ? '로그아웃 중...' : '로그아웃',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.error,
                    backgroundColor: AppColor.errorBackground,
                    side: const BorderSide(color: AppColor.errorBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
