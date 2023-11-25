// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:map/provider/locationNotifier.dart';
import 'package:map/provider/loginNotifier.dart';
import 'package:map/provider/pageNotifier.dart';
import 'package:map/provider/placeNotifier.dart';
import 'package:map/utilties/http/http.dart';
import 'package:map/utilties/loginUntil/google/googleLoginManager.dart';
import 'package:map/utilties/loginUntil/google/googleLoign.dart';
import 'package:map/utilties/loginUntil/kakao/kakaoLoginManager.dart';
import 'package:map/utilties/loginUntil/kakao/kakaoLoign.dart';
import 'package:map/utilties/loginUntil/naver/naverLoginManager.dart';
import 'dart:developer';

import 'package:map/utilties/loginUntil/naver/naverLoign.dart';
import 'package:map/utilties/notification/notification.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// 처음 화면
class LoadingScreensWidget extends StatefulWidget {
  const LoadingScreensWidget({super.key});

  static const String pageName = "loadingScreens";

  @override
  State<LoadingScreensWidget> createState() => _LoadingScreensWidgetState();
}

class _LoadingScreensWidgetState extends State<LoadingScreensWidget>
    with SingleTickerProviderStateMixin {
  final Http ht = Http();

  @override
  void initState() {
    _autoLogin();
    FlutterLocalNotification.init();
    super.initState();
  }

  /// 자동 로그인 플랫폼 별로 설정
  _autoLogin() async {
    var pl = Provider.of<LocationNotifier>(context, listen: false);
    // 잠시 꺼둠
    await pl.getPosition();
    pl.setContext(context);
    await pl.initClusterManager(pl.current.latitude, pl.current.longitude);
    const storage = FlutterSecureStorage();
    final platForm = await storage.read(key: "platForm");
    log("${platForm}");
    try {
      switch (platForm) {
        case "kakao":
          await UserApi.instance.accessTokenInfo();
          final kakao = kakaoLogin(KakaoLoginManger());
          await kakao.setUser();
          context.read<PageNotifier>().goToOther("MainView");
          await context
              .read<PlaceNotifier>()
              .setResponsePlace(await ht.myAutoPlaceList());
          context.read<LoginNotifier>().selectForm(kakao);
          break;
        case "google":
          if (FirebaseAuth.instance.currentUser == null) {
            throw Exception();
          }
          final google = GoogleLogin(GoogleLoginManger());
          await google.setUser();
          context.read<PageNotifier>().goToOther("MainView");
          await context
              .read<PlaceNotifier>()
              .setResponsePlace(await ht.myAutoPlaceList());
          context.read<LoginNotifier>().selectForm(google);
          break;
        case "naver":
          var token = await FlutterNaverLogin.currentAccessToken;
          log("asd");
          log("$token");
          if (token.accessToken.isEmpty) {
            throw Exception();
          }
          final naver = naverLogin(NaverLoginManger());
          await naver.setUser();
          context.read<PageNotifier>().goToOther("MainView");
          await context
              .read<PlaceNotifier>()
              .setResponsePlace(await ht.myAutoPlaceList());
          context.read<LoginNotifier>().selectForm(naver);
          break;
        default:
          log("platForm");
          context.read<PageNotifier>().goToOther("loginscreens");
          break;
      }

    } catch (e) {
      await storage.delete(key: "platForm");
      await storage.delete(key: "userId");
      context.read<PageNotifier>().goToOther("loginscreens");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            color: Color(0XFF928faf),
            image:
                DecorationImage(image: AssetImage("assets/images/load.png"))),
      ),
    );
  }
}
