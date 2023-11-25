import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class Place with ClusterItem {
  final String name; // 가게이름
  final LatLng latLng; // 위치정보
  final String placeId; // 가게 아이디
  final String address; // 가세 주소
  final String type; // 카페, 식당, 바
  final List<Photo> photoReference; // 사진 레퍼런스
  final String openClose; // 영업여부
  final num rate; // 별점
  final List<String>? weekendOpenTime; // 오픈 ~ 오프 시간대
  final String? phoneNumber; // 가게 번호

  Place(
      {required this.name,
      required this.latLng,
      required this.placeId,
      required this.address,
      required this.type,
      required this.photoReference,
      required this.openClose,
      required this.rate,
      this.phoneNumber,
      this.weekendOpenTime});

  @override
  LatLng get location => latLng;

  String get getPlaceId => placeId;

  String get getName => name;

  String get getAddress => address;

  List<Photo> get getPhotoReference => photoReference;

  String get getOpenClose => openClose;

  num get getRating => rate;

  String get getType => type;

  List<String> get getWeekend => weekendOpenTime!;

  String get getPhoneNumber => phoneNumber!;
}
