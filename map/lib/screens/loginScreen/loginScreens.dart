// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
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

import 'package:map/utilties/loginUntil/naver/naverLoign.dart';
import 'package:provider/provider.dart';
/// 로그인 클릭 화면
class LoginScreen extends Page {
  static const String pageName = "loginscreens";

  @override
  Route createRoute(BuildContext context) {
    // TODO: implement createRoute
    return MaterialPageRoute(
        settings: this, builder: (context) => const LoginScreenWidget());
  }
}

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget>
    with SingleTickerProviderStateMixin {
  final Http ht = Http();

  @override
  void initState() {
    super.initState();
  }

  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              color: Color(0XFF928faf),
              image: DecorationImage(
                  opacity: 0.6, image: AssetImage("assets/images/load.png"))),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInkWell(
                  "assets/images/kakao_login_medium_narrow1.png", "kakao"),
              _buildInkWell(
                  "assets/images/android_light_sq_SI2x1.png", "google"),
              _buildInkWell("assets/images/btnG_official1.png", "naver")
            ],
          ),
        ),
      ),
    );
  }

  InkWell _buildInkWell(String imgPath, String loginPlatform) {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        // height:MediaQuery.of(context).size.width *  ,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            imgPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
      onTap: () async {
        var placeNotifier = Provider.of<PlaceNotifier>(context, listen: false);

        switch (loginPlatform) {
          case "kakao":
            final kakao = kakaoLogin(KakaoLoginManger());
            await kakao.login();
            if (kakao.isLogined) {
              context.read<LoginNotifier>().selectForm(kakao);
              await storage.write(key: "platForm", value: "kakao");
              await placeNotifier.setResponsePlace(
                  await ht.myLoginPlaceList(kakao.userEntity!));
              context.read<PageNotifier>().goToOther("MainView");
              await Provider.of<LocationNotifier>(context, listen: false).resetPlace();
            }
            break;
          case "naver":
            final naver = naverLogin(NaverLoginManger());
            await naver.login();
            if (naver.isLogined) {
              context.read<LoginNotifier>().selectForm(naver);

              await storage.write(key: "platForm", value: "naver");

              await placeNotifier.setResponsePlace(
                  await ht.myLoginPlaceList(naver.userEntity!));
              context.read<PageNotifier>().goToOther("MainView");
              await Provider.of<LocationNotifier>(context, listen: false).resetPlace();
            }
            break;
          case "google":
            final google = GoogleLogin(GoogleLoginManger());
            await google.login();
            if (google.isLogined) {
              context.read<LoginNotifier>().selectForm(google);

              await storage.write(key: "platForm", value: "google");

              await placeNotifier.setResponsePlace(
                  await ht.myLoginPlaceList(google.userEntity!));
              context.read<PageNotifier>().goToOther("MainView");
              await Provider.of<LocationNotifier>(context, listen: false).resetPlace();
            }
            break;
          default:
            break;
        }
      },
    );
  }
}
