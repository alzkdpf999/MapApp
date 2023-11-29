// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:map/customIcon/my_flutter_app_icons.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/responsePlace.dart';
import 'package:map/provider/locationNotifier.dart';
import 'package:map/provider/placeNotifier.dart';
import 'package:map/utilties/http/http.dart';
import 'package:map/utilties/notification/notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// 로케이션 바텀시트
class LocationWidgetUtil {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  Future<dynamic> buildShowModalBottomSheet(
      BuildContext context, Widget widget) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (context) => widget,
    );
  }

  /// 영역 밖 클릭 시 바텀시트 닫기
  Widget Dismaissible({required Widget child, required BuildContext context}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        onTap: () {},
        child: child,
      ),
    );
  }

  /// 바텀 시트 영역
  Widget buildSheet(BuildContext context, Place detail) {
    DateTime now = DateTime.now();
    Map<String, List<String>> map = {};
    int dayOfWeek = 0;
    List<dynamic> weekDetails = [];
    if (detail.getOpenClose != "empty" && detail.getWeekend.isNotEmpty) {
      map = _buildweekdayMap(detail.getWeekend);
      dayOfWeek = now.weekday - 1;
      weekDetails = weekParse(map);
    }

    num starRate = ratingStar(detail.getRating);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Dismaissible(
      context: context,
      child: DraggableScrollableSheet(
          initialChildSize: 0.68,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                  color: Color(0xff2d2d2d),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              child: ListView(
                controller: controller,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.all(10),
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  /// 건물 이미지 영역
                  SizedBox(
                    width: width,
                    height: height / 3,
                    child: detail.getPhotoReference.isEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20)),
                            child: Image.asset(
                              "assets/images/noImageW.png",
                              fit: BoxFit.fill,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20)),
                            child: Image.network(
                                "https://maps.googleapis.com/maps/api/place/photo?photo_reference=${detail.getPhotoReference[0].photoReference}&key=${dotenv.env["GoogleApikey"]}&maxheight=300&maxwidth=300",
                                fit: BoxFit.cover),
                          ),
                  ),

                  /// 이름과 상세 주소 별점 정보
                  Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          detail.getName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        starRate != 6.0
                            ? SizedBox(
                                width: width / 4.5,
                                child: Image.asset(
                                    "assets/images/star$starRate.png",
                                    fit: BoxFit.cover))
                            : const SizedBox(),
                        starRate != 6.0
                            ? Text("$starRate",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20))
                            : Container(
                                padding: const EdgeInsets.only(top: 10),
                                height: width / 9.5,
                                child: const Text("별점 없음",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                        Container(
                            margin: const EdgeInsets.only(left: 15, right: 15),
                            height: 45,
                            child: Text(detail.getAddress,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center))
                      ],
                    ),
                  ),

                  /// 버튼모양으로 영업중이면 초록색 시계 아니면 빨간색, 전화기 누르면 복사, 경로 누르면 알람 확인 버튼과
                  Container(
                      width: width,
                      height: height / 10,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContainer(width, height, MyFlutterApp.clock,
                              detail.getOpenClose,soonClose: weekDetails.isEmpty ? null : weekDetails[1]),
                          _buildContainer(
                              width,
                              height,
                              MyFlutterApp.phone,
                              _buildCupertinoButton(
                                  context, detail.phoneNumber!)),
                          _buildContainer(width, height, MyFlutterApp.route,
                              buildRoute(context, detail)),
                          // 임시로 "true넣어둠
                        ],
                      )),

                  /// 상세시간 부분
                  Container(
                    margin:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: detail.getOpenClose != "empty"
                        ? ExpansionTile(
                            title: Text(
                              detail.getOpenClose == "true"
                                  ? weekDetails[0]
                                  : "영업 종료",
                              style: TextStyle(
                                  color: detail.getOpenClose == "true"
                                      ? weekDetails[1]
                                      : const Color(0xffff1010),
                                  fontWeight: FontWeight.bold),
                            ),
                            initiallyExpanded: false,
                            backgroundColor: const Color(0xff2d2d2d),
                            children: [
                              for (int i = 0; i < 7; i++)
                                Container(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    width: width,
                                    height: height / 20,
                                    child: Row(
                                      children: [
                                        Text(map.keys
                                            .elementAt((i + dayOfWeek) % 7)),
                                        const Spacer(),
                                        map[map.keys.elementAt(
                                                        (i + dayOfWeek) % 7)]!
                                                    .length ==
                                                2
                                            ? Text(
                                                "${map[map.keys.elementAt((i + 1) % 7)]![0]},${map[map.keys.elementAt((i + 1) % 7)]![1]}")
                                            : Text(map[map.keys
                                                .elementAt((i + 1) % 7)]![0])
                                      ],
                                    )),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.only(left: 15, top: 13),
                            height: width / 7.5,
                            child: const Text(
                              "시간 정보 없음",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                  ),

                  /// 이미지 영역
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (detail.getPhotoReference.length > 5 ||
                            detail.getPhotoReference.isEmpty)
                          for (int i = 0; i < 5; i++)
                            _buildPhotoGesture(context, width, height, i,
                                detail.getPhotoReference),
                        if (detail.getPhotoReference.length <= 5)
                          for (int i = 0;
                              i < detail.getPhotoReference.length;
                              i++)
                            _buildPhotoGesture(context, width, height, i,
                                detail.getPhotoReference,
                                length: detail.getPhotoReference.length),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  ///사진 클릭시 사용 갤러리처럼 보여줌
  StatefulBuilder _buildPhotoGesture(BuildContext context, double width,
      double height, int i, List<Photo> detail,
      {int? length}) {
    int count = 3;
    if (length != null) {
      if (0 < length && length < 3) {
        count = length;
      }
    }
    return StatefulBuilder(builder: (context, StateSetter setState) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _current = i;
          });
          showDialog(
              context: context,
              builder: (context) {
                if (detail.length > 5) {
                  detail = detail.sublist(0, 5);
                }
                return _buildDialog(detail);
              });
        },
        child: Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: const Offset(5, 5))
              ]),
          width: width / count,
          height: height / 3,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: detail.isEmpty
                  ? Image.asset("assets/images/noImageW.png", fit: BoxFit.cover)
                  : Image.network(
                      "https://maps.googleapis.com/maps/api/place/photo?photo_reference=${detail[i].photoReference}&key=${dotenv.env["GoogleApikey"]}&maxheight=300&maxwidth=300",
                      fit: BoxFit.cover)),
        ),
      );
    });
  }

  /// 클릭시 번호 복사
  CupertinoButton _buildCupertinoButton(BuildContext context, String number) {
    return CupertinoButton(
        child: number.isNotEmpty
            ? const Icon(
                MyFlutterApp.phone_android,
                color: Colors.blue,
              )
            : const Icon(
                MyFlutterApp.phonelink_erase,
                color: Color(0xffff1010),
              ),
        onPressed: () {
          if (number.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: number));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "전화번호를 복사했습니다.",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              duration: Duration(milliseconds: 700),
            ));
          }
        });
  }

  /// 알람창 확인
  CupertinoButton buildRoute(BuildContext context, Place detail) {
    return CupertinoButton(
        child: const Icon(
          MyFlutterApp.route,
          color: Colors.blue,
        ),
        onPressed: () async {
          if (Provider.of<LocationNotifier>(context, listen: false).showHide) {
            await showPopup(context, detail, true);
          }
        });
  }

  /// 반복되는  전화, 시간, 경로 컨테이너
  Container _buildContainer(
      double width, double height, IconData icon, dynamic type,{Color? soonClose}) {
    bool checkType = type is String;
    return Container(
        width: width / 5,
        height: height / 10,
        decoration: BoxDecoration(
          color: const Color(0xff262626),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: checkType
            ? Center(
                child: Icon(
                icon,
                color: type == "true"
                    ? (soonClose ?? Colors.green)
                    : (type == "empty"
                        ? Colors.white
                        : const Color(0xffff1010)),
              ))
            : type);
  }

  /// 다이어고르 영역 사진을 보여줌
  StatefulBuilder _buildDialog(List<Photo> detail) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Dialog(
          insetPadding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 6,
              bottom: MediaQuery.of(context).size.height / 6),
          backgroundColor: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider.builder(
                itemBuilder: (context, index, realIndex) {
                  return Builder(builder: (context) {
                    return Container(
                      margin: const EdgeInsets.all(15),
                      child: detail.isNotEmpty
                          ? Image.network(
                              "https://maps.googleapis.com/maps/api/place/photo?photo_reference=${detail[index].photoReference}&key=${dotenv.env["GoogleApikey"]}&maxheight=300&maxwidth=300",
                              fit: BoxFit.cover,
                            )
                          : Image.asset("assets/images/noImageW.png",
                              fit: BoxFit.cover),
                    );
                  });
                },
                itemCount: detail.isNotEmpty ? detail.length : 5,
                options: CarouselOptions(
                    height: MediaQuery.of(context).size.height / 2,
                    scrollDirection: Axis.horizontal,
                    initialPage: _current,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    onPageChanged: (i, reason) {
                      setState(() {
                        _current = i;
                      });
                    }),
                carouselController: _controller,
              ),
              Align(
                child: indicator(detail.isEmpty ? 5 : detail.length),
              )
            ],
          ));
    });
  }

  /// 지금 몇 번째 사진인지 확인
  Widget indicator(int length) => Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      alignment: Alignment.bottomCenter,
      child: AnimatedSmoothIndicator(
        activeIndex: _current,
        count: length,
        effect: JumpingDotEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.white,
            dotColor: Colors.white.withOpacity(0.6)),
      ));

  /// 클러스터 시 겹치는 바텀시트
  Widget buildListSheet(
      BuildContext context, Iterable<Place> places, var detailPlace) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Dismaissible(
      context: context,
      child: DraggableScrollableSheet(
          initialChildSize: 0.68,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                  color: Color(0xff474747),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              child: ListView(
                controller: controller,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.all(10),
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  for (Place place in places)
                    _buildListGesture(
                        context, width, height, place, detailPlace)
                ],
              ),
            );
          }),
    );
  }

  /// 가게 리스트 제스쳐
  GestureDetector _buildListGesture(BuildContext context, double width,
      double height, Place place, var detailPlace) {
    num starRate = ratingStar(place.getRating);

    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        Place detail = await detailPlace(place.getPlaceId, place.getType);
        buildShowModalBottomSheet(context, buildSheet(context, detail));
      },
      child: Card(
        color: const Color(0xff2d2d2d),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width * 2.5 / 4,
                    child: Text(
                      place.getName,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: width / 3,
                    child: Text(place.getType),
                  ),
                  starRate != 6.0
                      ? SizedBox(
                          width: width / 3,
                          child: Row(
                            children: [
                              SizedBox(
                                  width: width / 4.5,
                                  child: Image.asset(
                                      "assets/images/star$starRate.png",
                                      fit: BoxFit.cover)),
                              Text("$starRate",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ],
                          ))
                      : const SizedBox(),
                  place.getOpenClose != "empty"
                      ? SizedBox(
                          width: width / 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: Icon(MyFlutterApp.clock,
                                    size: 20,
                                    color: place.getOpenClose == "true"
                                        ? Colors.green
                                        : const Color(0xffff1010)),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              place.getOpenClose == "true"
                                  ? const Text(
                                "영업 중",
                                      style:
                                          TextStyle(color: Colors.green),
                                    )
                                  : const Text(
                                      "영업 종료",
                                      style:
                                          TextStyle(color: Color(0xffff1010)),
                                    )
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            SizedBox(
              width: width / 4,
              height: width / 4,
              child: place.getPhotoReference.isEmpty
                  ? Image.asset(
                      "assets/images/noImageW.png",
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      "https://maps.googleapis.com/maps/api/place/photo?photo_reference=${place.getPhotoReference[0].photoReference}&key=${dotenv.env["GoogleApikey"]}&maxheight=300&maxwidth=300",
                      fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }

  /// 별점 매기기 0.5 미만이면 0으로 0.5 <= a < 1 이면 0.5로
  num ratingStar(num rate) {
    return (rate / 0.5).floor() * 0.5;
  }

  /// 팝업 창 보여주기 알람이랑 경로 같이 확인하는 용도 드로우 부분
  /// sheetAndDraw true면 시트 false면 드로우
  Future<void> showPopup(
      BuildContext parentContext, dynamic detail, bool sheetAndDraw,
      {globalKey}) async {
    showDialog(
        barrierDismissible: false,
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: const Text("설정"),
            content: Container(
              margin: const EdgeInsets.only(top: 10),
              child: const Text("알람과 추적을 설정해주세요."),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text("모두"),
                    onPressed: () async {
                      requestNotificationPermissions;
                      await _showPopUpClick(context, detail, parentContext,
                          globalKey, true, sheetAndDraw);
                    },
                  ),
                  TextButton(
                    child: const Text("추적"),
                    onPressed: () async {
                      await _showPopUpClick(context, detail, parentContext,
                          globalKey, false, sheetAndDraw);
                    },
                  ),
                  TextButton(
                    child: const Text("취소",
                        style: TextStyle(color: Colors.redAccent)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              )
            ],
          );
        });
  }

  /// sheetAndDraw true면 시트 false면 드로우
  Future<void> _showPopUpClick(
      BuildContext context,
      dynamic rPlace,
      BuildContext parentContext,
      globalKey,
      bool change,
      bool sheetAndDraw) async {
    var pn = Provider.of<PlaceNotifier>(context, listen: false);
    var ln = Provider.of<LocationNotifier>(context, listen: false);
    if (sheetAndDraw) {
      ln.detailSearchPlaceCluster(rPlace);
      rPlace = ResponsePlace(
          placeName: rPlace.getName,
          placeId: rPlace.getPlaceId,
          lat: rPlace.location.latitude,
          lng: rPlace.location.longitude,
          rate: rPlace.getRating ?? 6.0,
          photoReference: rPlace.getPhotoReference.isEmpty
              ? "assets/images/noImageW.png"
              : rPlace.getPhotoReference[0].photoReference,
          type: rPlace.getType);
    } else {
      ln.detailSearchPlaceCluster(await ln.alarmDrawClickPlace(rPlace));
    }
    await Http().myPlaceSave(rPlace);
    pn.placeListAdd(rPlace);
    await ln.showAndHide();
    await ln.alarmControl(change: change);
    await ln.trackingRouteAlarm(rPlace.lat, rPlace.lng);
    Navigator.pop(context);
    if (globalKey != null) {
      globalKey!.currentState.closeDrawer();
    } else {
      Navigator.pop(parentContext);
    }
  }

  /// 알림 권한 요청
  void requestNotificationPermissions(BuildContext context) async {
    //알림 권한 요청
    final status =
        await FlutterLocalNotification.requestNotificationPermissions();
    if (status.isDenied && context.mounted) {
      showDialog(
        // 알림 권한이 거부되었을 경우 다이얼로그 출력
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림 권한이 거부되었습니다.'),
          content: const Text('알림을 받으려면 앱 설정에서 권한을 허용해야 합니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('설정'), //다이얼로그 버튼의 죄측 텍스트
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); //설정 클릭시 권한설정 화면으로 이동
              },
            ),
            TextButton(
              child: const Text('취소'), //다이얼로그 버튼의 우측 텍스트
              onPressed: () => Navigator.of(context).pop(), //다이얼로그 닫기
            ),
          ],
        ),
      );
    }
  }

  /// 요일 파싱하기
  List<dynamic> weekParse(Map<String, List<String>> map) {
    var now = DateTime.now();
    var weekday = DateFormat.EEEE('ko_KR').format(now);
    //이미 영업중이라고 했을 때
    if (!map[weekday]![0].contains("24")) {
      //24시간 영업중이 안나오면
      var currentHour = int.parse(DateFormat('hh').format(now));
      var openingHours = map[weekday]!.map((timeRange) {
        var hours =
            timeRange.replaceAll(RegExp(r"[오전후\s]"), "").split(RegExp(r"[~:]"));
        return [int.parse(hours[2]), int.parse(hours[3])];
      }).toList();
      var soonToClose =
          openingHours.any((hours) => currentHour == hours[0]); // 성립 하는지
      var soonIndex = openingHours
          .indexWhere((hours) => currentHour == hours[0]); // 성립하는 인덱스
      var openIndex = openingHours
          .indexWhere((hours) => currentHour < hours[0]); // 성립하는 인덱스


      if (soonToClose) {
        return ["곧 영업종료 ${map[weekday]![soonIndex]}", const Color(0xFFFF4500)]; // 고치기
      } else {

        if (openIndex == -1) {
          if (map[weekday]!.length == 2) {
            openIndex = 1;
          } else {
            openIndex = 0;
          }
        }
        return ["영업 중 ${map[weekday]![openIndex]}", Colors.green];
      }
    } else {
      // 24시간 영업중이라고 나오면
      return [map[weekday]![0], Colors.green];
    }
  }

  /// 앱바에  장소 검색, 주변 검색을 드랍다운으로 설정하기
  DropdownButtonHideUnderline buildDropdownButtonHideUnderline(
      dynamic onChanged, String searchOption) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        alignment: Alignment.center,
        value: searchOption,
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem(value: "주변 검색", child: Text("주변 검색")),
          DropdownMenuItem(value: "장소 검색", child: Text("장소 검색"))
        ],
        onChanged: onChanged,
      ),
    );
  }

  /// 요일 리스트 맵으로 변환
  Map<String, List<String>> _buildweekdayMap(List<String> weekdayOpenClose) {
    Map<String, List<String>> map = {};

    for (var element in weekdayOpenClose) {
      map[element.substring(0, element.indexOf(":"))] =
          (element.substring(4).split(","));
    }
    return map;
  }
/// 남은 거리 보여주는 화면
  Container buildNaviContainer(BuildContext context, String distance) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 20),
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.height / 9,
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0XFF2c3895), width: 2),
          color: Colors.black),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "남은 거리",
                style: TextStyle(
                    color: Color(0XFF2c3895),
                    fontSize: 18,
                    letterSpacing: -0.5),
              ),
              Text(distance,
                  style:
                      const TextStyle(color: Color(0XFF4156f3), fontSize: 18))
            ],
          ),
        ],
      )),
    );
  }
}
