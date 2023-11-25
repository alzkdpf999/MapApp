// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:map/customIcon/my_flutter_app_icons.dart';
import 'package:map/provider/locationNotifier.dart';
import 'package:map/provider/placeNotifier.dart';
import 'package:map/screens/mainScreens/mainDrawer.dart';
import 'package:map/screens/subWiget/actionButton.dart';
import 'package:map/screens/subWiget/childButtons.dart';
import 'package:map/utilties/http/http.dart';
import 'package:map/utilties/locationUntil/locationUtil.dart';
import 'package:map/utilties/locationUntil/locationWidgetUtil.dart';
import 'package:map/utilties/notification/notification.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 어플 메인 뷰
/// 구글 지도 로그아웃
/// 유저의 정보 보기
class MainScreen extends Page {
  static const pageName = "MainView";

  @override
  Route createRoute(BuildContext context) {
    // TODO: implement createRoute
    return MaterialPageRoute(
        settings: this, builder: (context) => const MainScreenWidget());
  }
}

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({super.key});

  @override
  State<MainScreenWidget> createState() => _MainScreenState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

class _MainScreenState extends State<MainScreenWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ActionButtonState> _actionButtonStateKey = GlobalKey();
  final LocationUtil locationUtil = LocationUtil();
  final LocationWidgetUtil locationWidgetUtil = LocationWidgetUtil();
  final Http ht = Http();

  //locationUtil.controller;

  String _searchOption = "주변 검색";
  bool _searchClick = false;
  final Mode _mode = Mode.overlay;
  String? _mapStyle;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _loadMap();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        log("디테치합니다");
        // await ht.myPlaceSave(Provider.of<PlaceNotifier>(context, listen: false)
        //     .requestPlaceList);
        Provider.of<LocationNotifier>(context, listen: false).streamCancle();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    log('디스포즈합니다.');
    super.dispose();
  }
 /// 맵 스타일 불러오기
  Future _loadMap() async {
    _mapStyle = await rootBundle.loadString("assets/style/map.json");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Theme(
            data: ThemeData.dark(),
            child: locationWidgetUtil.buildDropdownButtonHideUnderline(
                (String? value) {
              setState(
                () {
                  _searchOption = value!;
                  if (_searchOption == "장소 검색") {
                    Provider.of<LocationNotifier>(context,listen: false).setType("");
                    _searchClick = false;
                  } else {
                    _searchClick = false;
                  }
                },
              );
            }, _searchOption),
          ),
          centerTitle: true,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  setState(() {
                    _searchClick = true;
                  });
                  await _searchButton();
                },
                icon: const Icon(Icons.search)),
          ],
        ),
        resizeToAvoidBottomInset: false,
        drawer: ViewDrawer(globalKey: _scaffoldKey, http: ht),
        body:
            Consumer<LocationNotifier>(builder: (context, locationNotifier, _) {
          return Stack(children: [
            // 잠시 꺼둠
            GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(locationNotifier.current.latitude,
                        locationNotifier.current.longitude),
                    zoom: 16),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  controller.setMapStyle(_mapStyle);

                  if (!locationNotifier.controller.isCompleted) {
                    locationNotifier.setController(controller);
                  }
                  locationNotifier.clusterManagerF!.setMapId(controller.mapId);
                  locationNotifier.clusterManagerC!.setMapId(controller.mapId);
                  locationNotifier.clusterManagerB!.setMapId(controller.mapId);
                },
                mapToolbarEnabled: false,
                onCameraMove: (position) {
                  switch (locationNotifier.type) {
                    case "restaurant":
                      locationNotifier.clusterManagerF!.onCameraMove(position);
                      break;
                    case "cafe":
                      locationNotifier.clusterManagerC!.onCameraMove(position);
                      break;
                    case "bar":
                      locationNotifier.clusterManagerB!.onCameraMove(position);
                      break;
                  }
                },
                onCameraIdle: () {
                  switch (locationNotifier.type) {
                    case "restaurant":
                      locationNotifier.clusterManagerF!.updateMap();
                      break;
                    case "cafe":
                      locationNotifier.clusterManagerC!.updateMap();
                      break;
                    case "bar":
                      locationNotifier.clusterManagerB!.updateMap();
                      break;
                  }
                },
                markers: locationNotifier.markerList!),
            //), // 나중에 지워야함 가로만
            Visibility(
                visible: !locationNotifier.showHide,
                child: locationWidgetUtil.buildNaviContainer(
                    context, "${locationNotifier.distanceCal} km")),
            buildPositioned(locationNotifier, 71, 15, MyFlutterApp.trash_alt,
                "trash", locationNotifier.showHide),
            buildPositioned(locationNotifier, 11, 75, MyFlutterApp.my_location,
                "myLoc", locationNotifier.showHide),
            buildPositioned(locationNotifier, 11, 90, MyFlutterApp.cancel,
                "route", !locationNotifier.showHide),
            locationNotifier.alarmOnOff
                ? buildPositioned(locationNotifier, 11, 15,
                    MyFlutterApp.bell_alt, "alarm", !locationNotifier.showHide)
                : buildPositioned(locationNotifier, 11, 15,
                    MyFlutterApp.bell_off, "alarm", !locationNotifier.showHide),
            ActionButton(
                distance: 60,
                key: _actionButtonStateKey,
                childButtons: [
                  buildChildButton("restaurant"),
                  buildChildButton("cafe"),
                  buildChildButton("bar")
                ]),
          ]);
        }));
  }

  /// 내 위치로 이동, 마커 지우기, 알람, 추적 취소 버튼
  Positioned buildPositioned(LocationNotifier locationNotifier, double pr,
      double pt, IconData icon, String sortOut, bool showHide) {
    return Positioned(
        right: pr,
        top: pt,
        child: Visibility(
          visible: showHide,
          child: GestureDetector(
            onTap: () async {

              if (!showHide) {
                locationNotifier.setType("");
              }
              switch (sortOut) {
                case "trash": //마커 지우기
                  await locationNotifier.clearMark();
                  locationNotifier.setType("");
                  break;
                case "myLoc": // 내 위치로 카메라 이동
                  _searchClick = false;
                  LatLng cur = await locationNotifier.myPosition();
                  await locationNotifier.animatedViewofMap(
                      lat: cur.latitude, lng: cur.longitude, zoom: 16);
                  break;
                case "route": //경로 삭제
                  log("$showHide");
                  locationNotifier.streamCancle();
                  await locationNotifier.showAndHide();
                  await locationNotifier.alarmControl(change: false);
                  break;
                case "alarm": // 알람 삭제, 추가 하는
                  if (!locationNotifier.alarmOnOff) {
                    locationWidgetUtil.requestNotificationPermissions(context);
                  }
                  await locationNotifier.alarmControl();
                  break;
              }
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 0,
                    blurRadius: 4.0,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }

  /// 식당 카페 바 선택 버튼
  ChildButton buildChildButton(String types) {
    String image;
    var pl = Provider.of<LocationNotifier>(context,listen: false);
    switch (types) {
      case "restaurant":
        image = "assets/images/food50.png";
        break;
      case "cafe":
        image = "assets/images/cafe50.png";
        break;
      case "bar":
        image = "assets/images/cocktail50.png";
        break;
      default:
        image = "assets/images/food50.png";
    }

    return ChildButton(
        onPressed: () {

          if (pl.type != types) {
            setState(() {

              var pLN = Provider.of<LocationNotifier>(context, listen: false);
              pLN.setType(types);
              LatLng where = _searchClick
                  ? (pLN.searchLatLng ?? pLN.current)
                  : pLN.current;
              pLN.searchNearPlaceCluster(where);

              _actionButtonStateKey.currentState!.toggle();
            });
          }
        },
        check: pl.type == types,
        image: Image.asset(image, color: Colors.white));
  }

  /// 지도 검색 버튼 클릭시
  Future<void> _searchButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: dotenv.env["GoogleApikey"].toString(),
        mode: _mode,
        language: "ko",
        strictbounds: false,
        types: ["bar", "cafe", "restaurant"],
        decoration: const InputDecoration(
          hintText: "search",
        ),
        components: [
          Component(Component.country, "kor"),
        ]);

    var pl = Provider.of<LocationNotifier>(context, listen: false);
    await pl.searchNearPlace(p!, searchOption: _searchOption);
    if (_searchOption == "주변 검색") {
      pl.setType("restaurant");
      await pl.searchNearPlaceCluster(pl.searchLatLng);

    } else {
      pl.setType("");
      await pl.detailSearchPlaceCluster(pl.place);
    }
    await pl.animatedViewofMap(
        lat: pl.searchLatLng.latitude,
        lng: pl.searchLatLng.longitude,
        zoom: 16);
  }

// // 에러 발생시 메시지 보이게
//   void onError(PlacesAutocompleteResponse response) {
//     log("에러확인");
//     _scaffoldKey.currentState!
//         .showBottomSheet((context) => Text(response.errorMessage!));
//   }
}
