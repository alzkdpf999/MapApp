import 'dart:developer';

import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:map/entity/user.dart';
import 'package:map/utilties/loginUntil/loginManager.dart';

class kakaoLogin {
  final loginManager _socialLogin;
  bool isLogined = false; //처음에 로그인 안 되어 있음
  User? user; //카카오톡에서 사용자 정보를 저장하는 객체 User를 nullable 변수로 선언
  UserEntity? userEntity; // 다른 소셜과 이름 맞추기 위한 유저
  kakaoLogin(this._socialLogin);

  Future login() async {
    log("Kakaologin 클래스 부분");
    isLogined = await _socialLogin.login(); //로그인되어 있는지 확인
    log("로그인 되어 있는지 확인${isLogined}");
    // user = await UserApi.instance.me(); //사용자 정보 받아오기
    // userEntity = UserEntity(name: user?.kakaoAccount?.profile?.nickname, email: user?.kakaoAccount?.email, imgUrl: user?.kakaoAccount?.profile?.profileImageUrl);
    await setUser();

    log("유저 부분 종료");
  }

  Future logout() async {
    await _socialLogin.logout(); //로그아웃 실행
    isLogined = false; //로그인되어 있는지를 저장하는 변수 false값 저장
    log("${isLogined} 카카오 로그아웃 실행");
    user = null; //user 객체 null
  }

  Future setUser() async {
    user = await UserApi.instance.me(); //사용자 정보 받아오기
    userEntity = UserEntity(
        name: user?.kakaoAccount?.profile?.nickname,
        email: user?.kakaoAccount?.email,
        imgUrl: user?.kakaoAccount?.profile?.profileImageUrl,
        platForm: "kakao");
  }
}
