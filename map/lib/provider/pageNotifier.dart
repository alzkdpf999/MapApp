import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:map/screens/loadingScreen/loadingScreen.dart';

/// 페이지 이동
class PageNotifier extends ChangeNotifier{
  String _currentPage = LoadingScreensWidget.pageName;

  String get currentPage => _currentPage;
  set currentPage(String newPage){
    _currentPage = newPage;
    notifyListeners();
  }
  /// 로그인창으로 가기
  void goToLogin() {
    currentPage = LoadingScreensWidget.pageName;
    log("goToLogin");
    notifyListeners();

  }

  ///  페이지 이동
  void goToOther(String pageName){
    currentPage = pageName;
    // DrawerNotifier().currentScreen = MainScreenWidget() ;
    notifyListeners();
  }
}