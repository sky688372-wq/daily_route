import 'package:daily_route/core/model/login/login_data.dart';
import 'package:flutter/foundation.dart';

// 로그인한 회원 정보의 앱 내 상태 관리
class UserProvider extends ChangeNotifier {
  LoginUser? _user; // 로그인한 유저의 정보 저장

  // 1. 현재 회원 정보
  // 반환 형태: LoginUser? (로그인 전에는 null)
  LoginUser? get user => _user;

  // 2. 회원 정보가 저장되어 있는지 확인
  // 반환 형태: bool
  bool get hasUser => _user != null;

  // 3. 로그인 응답에서 받은 회원 정보 저장
  // 반환 형태: void
  void setUser(LoginUser user) {
    _user = user;
    notifyListeners();
  }

  // 4. 로그아웃 시 회원 정보 삭제
  // 반환 형태: void
  void clearUser() {
    if (_user == null) return;

    _user = null;
    notifyListeners();
  }
}
