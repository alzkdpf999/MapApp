// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as dt;
import 'package:map/entity/place.dart';
import 'package:map/entity/responsePlace.dart';
import 'package:map/utilties/locationUntil/locationUtil.dart';
import 'package:map/utilties/locationUntil/locationWidgetUtil.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:map/utilties/notification/notification.dart';

class LocationNotifier with ChangeNotifier {
  final locationWidgetUtil = LocationWidgetUtil();
  final LocationUtil _locationUtil = LocationUtil();
  final dt.Distance distance = const dt.Distance();
  StreamSubscription<Position>? _positionStream;
  late LatLng _current; // 현재 위치
  LatLng? _searchLatLng; // 검색했을떄 위치
  ClusterManager? _clusterManagerF; // 식당 클러스터
  ClusterManager? _clusterManagerC; // 카페 클러스터
  ClusterManager? _clusterManagerB; // 바 클러스터
  Set<Marker>? _markerList = {};
  bool _showHide = true; // 버튼 보이게 안보이게
  bool _alarmOnOff = false; // 알람 온/오프
  BuildContext? _context;
  String _type = "restaurant";
  Place? _place;

  double _distanceCal = 0;

  double get distanceCal => _distanceCal;
  Completer<GoogleMapController> _controller = Completer();

  Completer<GoogleMapController> get controller => _controller;

  Set<Marker>? get markerList => _markerList;

  bool get showHide => _showHide;

  bool get alarmOnOff => _alarmOnOff;

  ClusterManager? get clusterManagerF => _clusterManagerF!;

  ClusterManager? get clusterManagerC => _clusterManagerC!;

  ClusterManager? get clusterManagerB => _clusterManagerB!;

  Place get place => _place!;

  String get type => _type;

  LatLng get current => _current;

  LatLng get searchLatLng => _searchLatLng!;

  void setController(GoogleMapController controller) {
    _controller.complete(controller);
    notifyListeners();
  }

  void initController() {
    _controller = Completer();
    notifyListeners();
  }

  Future<void> showAndHide() async {
    _showHide = !_showHide;
    notifyListeners();
  }

  Future<void> alarmControl({bool? change}) async {
    _alarmOnOff = change ?? !_alarmOnOff;
    notifyListeners();
  }

  void setType(String type) {
    _type = type;
    notifyListeners();
  }

  /// 현재 위치 가져오기
  Future<LatLng> getPosition() async {
    try {
      _current = await _locationUtil.getCurrentLocation();
    } catch (e) {
      _current = const LatLng(37.579887, 126.976870);
    }
    notifyListeners();
    return _current;
  }

  /// 현재 위치 정보 받기
  Future<LatLng> myPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _current = LatLng(position.latitude, position.longitude);
    notifyListeners();
    return _current;
  }

  /// 근처 플레이스 검색해서 마커 겹치는 정도 컨트롤
  Future<void> initClusterManager(double lat, double lng) async {
    List<Place> placeCluster =
        await _locationUtil.nearSearchPlace(LatLng(lat, lng));
    _clusterManagerF = ClusterManager<Place>(placeCluster, _updateMarkers,
        markerBuilder: _locationUtil.markerBuilder(_context!),
        levels: const [1, 4.25, 6.75, 8.25, 11, 14, 16, 18, 20.0]);

    _clusterManagerC = ClusterManager<Place>([], _updateMarkers,
        markerBuilder: _locationUtil.markerBuilder(_context!, type: "cafe"),
        levels: const [1, 4.25, 6.75, 8.25, 11, 14, 16, 18, 20.0]);

    _clusterManagerB = ClusterManager<Place>([], _updateMarkers,
        markerBuilder: _locationUtil.markerBuilder(_context!, type: "bar"),
        levels: const [1, 4.25, 6.75, 8.25, 11, 14, 16, 18, 20.0]);
    notifyListeners();
  }
  /// 한번 초기화 해주기(로그아웃하고 다시 들어갈 때)
  Future<void> resetPlace() async {
    await getPosition();
    List<Place> empty = [];
    List<Place> placeCluster = await _locationUtil
        .nearSearchPlace(LatLng(_current.latitude, _current.longitude));
    _clusterManagerF!.setItems(placeCluster);
    _clusterManagerC!.setItems(empty);
    _clusterManagerB!.setItems(empty);
    animatedViewofMap(lat: _current.latitude, lng: _current.longitude, zoom: 16);
    notifyListeners();
  }
  /// 장소 검색 시 하나만 추가
  Future<void> detailSearchPlaceCluster(Place place) async {
    clearMark();
    log("1");
    setType(place.getType);
    switch (place.getType) {
      case "restaurant":
        log("2");
        _clusterManagerF!.addItem(place);
        break;
      case "cafe":
        log("3");
        _clusterManagerC!.addItem(place);
        break;
      case "bar":
        log("4");
        _clusterManagerB!.addItem(place);
        break;
    }
    notifyListeners();
  }

  /// 클러스터 위치 조정하기
  Future<void> searchNearPlaceCluster(LatLng latLng) async {
    List<Place> empty= [];
    switch (_type) {
      case "restaurant":
        _clusterManagerF!
            .setItems(await _locationUtil.nearSearchPlace(latLng, type: _type));
        _clusterManagerC!.setItems(empty);
        _clusterManagerB!.setItems(empty);
        log("식당");
        break;
      case "cafe":
        _clusterManagerC!
            .setItems(await _locationUtil.nearSearchPlace(latLng, type: _type));
        _clusterManagerF!.setItems(empty);
        _clusterManagerB!.setItems(empty);
        log("카페");
        break;
      case "bar":
        _clusterManagerB!
            .setItems(await _locationUtil.nearSearchPlace(latLng, type: _type));
        _clusterManagerC!.setItems(empty);
        _clusterManagerF!.setItems(empty);
        log("바");
        break;
      default:
        await clearMark();
        break;
    }

    notifyListeners();
  }

  /// 겹치는 마커 안겹치는 마커 다시 그리는 용도
  void _updateMarkers(Set<Marker> markers) {
    _markerList = markers;
    notifyListeners();
  }

  /// context를 가져와서 bottomsheet를 호출할 때 사용
  void setContext(BuildContext context) {
    _context = context;
    notifyListeners();
  }

  /// 마커 지워주기
  Future<void> clearMark() async {
    List<Place> empty = [];
    _clusterManagerF!.setItems(empty);
    _clusterManagerC!.setItems(empty);
    _clusterManagerB!.setItems(empty);
    notifyListeners();
  }

  /// 검색한 위치 정보 가져오기
  Future<void> searchNearPlace(Prediction p, {String? searchOption}) async {
    _searchLatLng = await _locationUtil.displayPredictionLatLng(p);
    if (searchOption == "장소 검색") {
      _place = await _locationUtil.displayPredictionPlace(p.placeId!);
    }
    notifyListeners();
  }

  ///드로우 부분에서 알람 설정할 시 플레이스 가져오기
  Future<Place> alarmDrawClickPlace(ResponsePlace place) async {
    _place = await _locationUtil.displayPredictionPlace(place.getPlaceId);
    return _place!;
  }

  /// 경로 추적하면서 카메라 이동시키고 도달하면 알람 울리기
  Future<void> trackingRouteAlarm(double lat, double lng) async {
    const LocationSettings locationSettings =
        LocationSettings(accuracy: LocationAccuracy.high,);
    // 사용자의 현재 위치 계속 업데이트해주기
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((location) async {
      _distanceCal = distance(dt.LatLng(location.latitude, location.longitude),
              dt.LatLng(lat, lng)) /
          1000;
      if (_distanceCal <= 0.01) {
        if (_alarmOnOff) {
          FlutterLocalNotification.showNotification();
        }
        _showHide = true;
        clearMark();
        _positionStream!.cancel();
      }

      _current = LatLng(location.latitude, location.longitude);

      await animatedViewofMap(
          lat: _current.latitude, lng: _current.longitude, zoom: null);
      notifyListeners();
    });
  }

  ///카메라 이동
  Future<void> animatedViewofMap(
      {required double lat, required double lng, required double? zoom}) async {
    log("움직인다? 안움직인다?");

    GoogleMapController controller = await _controller.future;
    CameraPosition cPosition = CameraPosition(
      zoom: (zoom ?? await controller.getZoomLevel()),
      target: LatLng(lat, lng),
    );

    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }
  /// 스트림 구독 취소
  void streamCancle() {
    if (_positionStream != null) {
      _positionStream!.cancel();
    }
    notifyListeners();
  }

}
