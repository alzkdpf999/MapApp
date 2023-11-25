import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:map/entity/user.dart';
import 'package:map/utilties/loginUntil/loginManager.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin {
  final loginManager _socialLogin;
  bool isLogined = false; //처음에 로그인 안 되어 있음
  GoogleSignInAuthentication? googleAuth;
  User? user; // 유저 정보 받기
  UserEntity? userEntity; // 다른 소셜과 이름 맞추기 위한 유저

  GoogleLogin(this._socialLogin);

  Future login() async {
    log("구글 클래스 부분");
    isLogined = await _socialLogin.login();
    log("구글 로그인 확인${isLogined}");
    // user = (await FirebaseAuth.instance.currentUser) as User;
    // userEntity = UserEntity(name: user?.displayName, email: user?.email, imgUrl: user?.photoURL);
    await setUser();
    log("구글 유저 정보${user?.email}");
  }

  Future logout() async {
    await _socialLogin.logout(); //로그아웃 실행
    isLogined = false; //로그인되어 있는지를 저장하는 변수 false값 저장
    user = null; //user 객체 null
  }

  Future setUser() async {
    user = (await FirebaseAuth.instance.currentUser) as User;
    userEntity = UserEntity(
        name: user?.displayName,
        email: user?.email,
        imgUrl: user?.photoURL,
        platForm: "google");
  }
}
