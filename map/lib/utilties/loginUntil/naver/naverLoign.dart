import 'dart:developer';

import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:map/entity/user.dart';

import 'package:map/utilties/loginUntil/loginManager.dart';

class naverLogin {
  final loginManager _socialLogin;
  bool isLogined = false; //처음에 로그인 안 되어 있음
  NaverAccountResult?
      user; //네이버 사용자 정보를 저장하는  NaverAccountResult nullable 변수로 선언
  UserEntity? userEntity; // 다른 소셜과 이름 맞추기 위한 유저

  naverLogin(this._socialLogin);

  Future login() async {
    isLogined = await _socialLogin.login(); //로그인되어 있는지 확인
    await setUser();
  }

  Future logout() async {
    await _socialLogin.logout(); //로그아웃 실행
    isLogined = false; //로그인되어 있는지를 저장하는 변수 false값 저장
    user = null; //NaverLoginResult 객체 null
  }

  // 자동 로그인으로 인한 유저 정보 저장
  Future setUser() async {
    user = await FlutterNaverLogin.currentAccount(); //사용자 정보 받아오기
    userEntity = UserEntity(
        name: user?.name,
        email: user?.email,
        imgUrl: user?.profileImage,
        platForm: "naver");
  }
}
