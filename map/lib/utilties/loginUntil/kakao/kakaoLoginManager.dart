
import 'dart:developer';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:map/utilties/loginUntil/loginManager.dart';

class KakaoLoginManger implements loginManager {
  Future<bool> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled(); //카카오톡 설치 확인
      if (isInstalled) {
        //설치되어 있다면
        try {
          //카카오톡 로그인 시도
          await UserApi.instance.loginWithKakaoTalk(); // 카카오톡 로그인
          return true; //성공하면 true
          log("Manager 부분 설치되어 있음");
        } catch (error) {
          //error 발견하면
          return false; //return false
        }
      } else {
        log("Manager 부분  설치 안됨");
        //카카오톡 설치되어 있지 않다면
        try {
          //카카오톡 계정으로 로그인 시도
          await UserApi.instance.loginWithKakaoAccount(); //카카오톡 계정 로그인
          return true; //성공하면 true
        } catch (error) {
          //error 발견하면
          log(" Manager 부분  에러 메세지${error}");
          return false; //return false
        }
      }
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await UserApi.instance.logout();
      return true;
    } catch (error) {
      return false;
    }
  }
}
