
import 'dart:developer';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:map/utilties/loginUntil/loginManager.dart';

class NaverLoginManger implements loginManager {
  Future<bool> login() async {
   try{
     await FlutterNaverLogin.logIn();
     log("로그인 시작");
     return true;
   }catch(error){
     log("로그인 에러 발생${error}");
     return false;
   }
  }

  @override
  Future<bool> logout() async {
    try {
      await FlutterNaverLogin.logOut();
    return true;
    } catch (error) {
      return false;
    }
  }
}
