// import 'dart:js';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:map/provider/locationNotifier.dart';
import 'package:map/provider/loginNotifier.dart';
import 'package:map/provider/pageNotifier.dart';
import 'package:map/provider/placeNotifier.dart';
import 'package:map/screens/loadingScreen/loadingScreen.dart';
import 'package:map/screens/loginScreen/loginScreens.dart';
import 'package:map/screens/mainScreens/mainScreen.dart';

import 'package:map/utilties/http/http.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  KakaoSdk.init(nativeAppKey: dotenv.env["KakaoApikey"]);

  // runApp(
  //   DevicePreview(builder: (context) =>  MyApp(),)
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // String currentPage = loginscreens.pageName;
  DateTime? currentBackPressTime;
  @override
  void initState(){

  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginNotifier>(
            create: (_) => LoginNotifier(loginData: null)),
        ChangeNotifierProvider(create: (_) => PageNotifier()),
        ChangeNotifierProvider(create: (_) => LocationNotifier()),
        ChangeNotifierProvider(create: (_) => PlaceNotifier()),
      ],
      child: MaterialApp(
          localizationsDelegates: const[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: const[
            Locale("ko","KR")
          ],
          locale: const Locale("ko"),
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.black,
            drawerTheme: const DrawerThemeData(backgroundColor: Color(0xff474747)),
            dividerTheme: const DividerThemeData(color:  Color(0xff474747)),
            appBarTheme: const AppBarTheme(
              shadowColor: Colors.white,
              backgroundColor: Colors.black,
    ),
          ),
          builder: DevicePreview.appBuilder,
          home: Scaffold(
            body: WillPopScope(onWillPop: onWillPop ,
              child: Consumer<PageNotifier>(
                builder: (context, pageNotifier, child) {
                  return Navigator(
                    pages: [
                      const MaterialPage(
                          key: ValueKey(LoadingScreensWidget.pageName),
                          child: LoadingScreensWidget()),
                              //MapSample()),
                      if (pageNotifier.currentPage == MainScreen.pageName)
                        MainScreen(),
                      if (pageNotifier.currentPage == LoginScreen.pageName)
                        LoginScreen()
                    ],
                    onPopPage: (route, result) {
                      if (!route.didPop(result)) {
                        return false;
                      }
                      return true;

                    },
                  );
                },
              ),
            ),
          )),
    );
  }
  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();

    if (currentBackPressTime == null ||
        currentTime.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = currentTime;
      Fluttertoast.showToast(
          msg: "'뒤로' 버튼을 한번 더 누르시면 종료됩니다.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xff03021E),
          fontSize: 16,
          toastLength: Toast.LENGTH_SHORT);
      return false;
    }
      return true;
  }
}
