// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:map/entity/place.dart';
import 'package:map/utilties/locationUntil/locationWidgetUtil.dart';

class LocationUtil {
  final locationWidgetUtil = LocationWidgetUtil();

  final GoogleApikey = dotenv.env["GoogleApikey"];
  late Position _currentPosition;
  late LatLng _current ;

  late LocationPermission checkPermission;
  StreamSubscription<Position>? _positionStream;
  late final Completer<GoogleMapController> _controller = Completer();
  List<Place> placeCluster = List<Place>.empty(growable: true);

  ClusterManager? _clusterManager;

  LatLng get trackCurrent => _current;

  List<Place> get cluster => placeCluster;

  StreamSubscription<Position> get positionStream => _positionStream!;

  Completer<GoogleMapController> get controller => _controller;

  ClusterManager? get clusterManager => _clusterManager;

  /// 권한 확인하면서 현재 위치 주기
  Future<LatLng> getCurrentLocation() async {
    try {
      checkPermission = await Geolocator.checkPermission();
      if (checkPermission == LocationPermission.denied ||
          checkPermission == LocationPermission.deniedForever) {
        checkPermission = await Geolocator.requestPermission();
      }
      // 한번더 권한 취소햇으면
      if (checkPermission == LocationPermission.denied ||
          checkPermission == LocationPermission.deniedForever) {
        Geolocator.openLocationSettings();
      } else if (checkPermission == LocationPermission.always ||
          checkPermission == LocationPermission.whileInUse) {
        _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _current =
            LatLng(_currentPosition.latitude, _currentPosition.longitude);
      }
    } catch (e) {
      Geolocator.openLocationSettings();
    }

    return _current;
  }


  /// 검색 한 장소 위도 경도 정보 넘겨주기
  Future<LatLng> displayPredictionLatLng(
      Prediction p) async {
    GoogleMapsPlaces place = GoogleMapsPlaces(
        apiKey: GoogleApikey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail =
        await place.getDetailsByPlaceId(p.placeId!, language: "ko");

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    return LatLng(lat, lng);
  }

  /// 검색 한 장소 디테일 보내주기
  Future<Place> displayPredictionPlace(
      String placeId) async {
    String type;
    GoogleMapsPlaces place = GoogleMapsPlaces(
        apiKey: GoogleApikey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail =
        await place.getDetailsByPlaceId(placeId, language: "ko");
    PlaceDetails detailOne = detail.result;
    final lat = detailOne.geometry!.location.lat;
    final lng = detailOne.geometry!.location.lng;
    if (detailOne.types.contains("restaurant")) {
      type = "restaurant";
    } else if (detailOne.types.contains("cafe")) {
      type = "cafe";
    } else {
      type = "bar";
    }
    return Place(
        rate: detailOne.rating ?? 6,
        address: detailOne.formattedAddress ?? (detailOne.vicinity ?? ""),
        photoReference: detailOne.photos,
        openClose: detailOne.openingHours == null
            ? "empty"
            : detailOne.openingHours!.openNow.toString(),
        type: type,
        name: detailOne.name,
        placeId: detailOne.placeId,
        latLng: LatLng(lat, lng));
  }

  /// 위도 경도를 입력해서 근처 가게들 정보 가져오기
  Future<List<Place>> nearSearchPlace(LatLng latLng,
      {String type = "restaurant"}) async {
    GoogleMapsPlaces place = GoogleMapsPlaces(
        apiKey: GoogleApikey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());
    PlacesSearchResponse details = await place.searchNearbyWithRadius(
        Location(lat: latLng.latitude, lng: latLng.longitude), 300.0,
        language: "ko", type: type);
    placeCluster.clear();
    for (PlacesSearchResult detail in details.results) {
      placeCluster.add(Place(
          rate: detail.rating ?? 6,
          address: detail.formattedAddress ?? (detail.vicinity ?? ""),
          photoReference: detail.photos,
          openClose: detail.openingHours == null
              ? "empty"
              : detail.openingHours!.openNow.toString(),
          type: type,
          name: detail.name,
          placeId: detail.placeId,
          latLng: LatLng(
              detail.geometry!.location.lat, detail.geometry!.location.lng)));
    }
    return placeCluster;
  }

  /// 마커 그려주기
  Future<BitmapDescriptor> getMarkerBitmap(int size,
      {String? text, String? type}) async {
    if (kIsWeb) size = (size / 4).floor();

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.black;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);

    if (text != null) {
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    } else {
      ByteData? data0;
      if (type == "restaurant") {
        data0 = await rootBundle.load("assets/images/food.png");
      } else if (type == "cafe") {
        data0 = await rootBundle.load("assets/images/cafe.png");
      } else {
        data0 = await rootBundle.load("assets/images/cocktail.png");
      }
      final ui.Codec codec = await ui
          .instantiateImageCodec(data0!.buffer.asUint8List(), targetWidth: 65);
      final ui.FrameInfo fi = await codec.getNextFrame();

      canvas.drawImage(fi.image, Offset(size / 11.5, size / 27), paint1);
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data =
        await img.toByteData(format: ui.ImageByteFormat.png) as ByteData;
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  /// 마커 터치 동작과 아이콘 수정
  Future<Marker> Function(Cluster<Place>) markerBuilder(BuildContext context,
          {String type = "restaurant"}) =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () async {
            log("${cluster.items.first}");
            if (cluster.items.length > 1) {
              await locationWidgetUtil.buildShowModalBottomSheet(
                  context,
                  locationWidgetUtil.buildListSheet(
                      context, cluster.items, detailsPlace));
            } else {
              Place detail = await detailsPlace(cluster.items.first.placeId,cluster.items.first.getType);
              await locationWidgetUtil.buildShowModalBottomSheet(
                  context, locationWidgetUtil.buildSheet(context, detail));
            }
          },
          icon: await getMarkerBitmap(cluster.isMultiple ? 125 : 77,
              text: cluster.isMultiple ? cluster.count.toString() : null,
              type: type),
        );
      };

  /// 가게 세부 설명 사항들
  Future<Place> detailsPlace(String placeId,String type) async {
    GoogleMapsPlaces place = GoogleMapsPlaces(
        apiKey: GoogleApikey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());
    PlacesDetailsResponse detail = await place.getDetailsByPlaceId(
      placeId,
      language: "ko",
    );

    return Place(
        rate: detail.result.rating ?? 6,
        address:
            detail.result.formattedAddress ?? (detail.result.vicinity ?? ""),
        photoReference: detail.result.photos,
        openClose: detail.result.openingHours == null
            ? "empty"
            : detail.result.openingHours!.openNow.toString(),
        weekendOpenTime: detail.result.openingHours == null
            ? []
            : detail.result.openingHours!.weekdayText,
        type: type,
        name: detail.result.name,
        placeId: detail.result.placeId,
        phoneNumber: detail.result.formattedPhoneNumber ?? "",
        latLng: LatLng(detail.result.geometry!.location.lat,
            detail.result.geometry!.location.lng),);
  }
}
