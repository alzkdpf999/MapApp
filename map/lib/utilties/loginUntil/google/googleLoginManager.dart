
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:map/utilties/loginUntil/loginManager.dart';
import 'package:google_sign_in/google_sign_in.dart';
class GoogleLoginManger implements loginManager {
  GoogleSignInAccount? _googleSignInAccount;
  GoogleSignInAuthentication? _googleAuth;

  @override
  Future<bool> login() async {
    try {
      //구글 로그인 시도
      await Firebase.initializeApp();
      log("Manager 부분 ");
      _googleSignInAccount = await GoogleSignIn().signIn(); // 구글 로그인
      _googleAuth = await _googleSignInAccount?.authentication;
      OAuthCredential credential = await GoogleAuthProvider.credential(
        accessToken: _googleAuth?.accessToken,
        idToken: _googleAuth?.idToken
      );
      await  FirebaseAuth.instance.signInWithCredential(credential);
      return true; //성공하면 true

    } catch (error) {
      //error 발견하면
      log("구글 에러${error}");
      return false; //return false
    }
  }



  @override
  Future<bool> logout() async {
    try {
      await GoogleSignIn().signOut();
      return true;
    } catch (error) {
      return false;
    }
  }




}