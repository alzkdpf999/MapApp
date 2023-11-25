import 'package:flutter/cupertino.dart';

/// 로그인 정보들 공유
class LoginNotifier extends ChangeNotifier {
  dynamic loginData;

  LoginNotifier({required this.loginData});

  dynamic get getLoginData => loginData;
  void selectForm(dynamic setloginData) {
    loginData = setloginData;
    notifyListeners();
  }

}
