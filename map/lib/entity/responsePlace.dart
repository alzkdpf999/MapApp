import 'dart:ffi';

class ResponsePlace {
  final String placeId; //가게 아이디
  final double lat; // 위도
  final double lng; // 경도
  final String photoReference; // 포토 래퍼런스
  final num rate; // 별점
  final String placeName; // 가게 이름
  final String type; // 가게 타입

  String get getPlaceId => placeId;

  String get getPlaceName => placeName;

  String get getType => type;

  String get getPhotoReference => photoReference;

  num get getNum => rate;

  double get getLat => lat;

  double get getLng => lng;

  ResponsePlace(
      {required this.placeName, 
      required this.placeId,
      required this.lat,
      required this.lng,
      required this.photoReference,
      required this.rate,
      required this.type});

  factory ResponsePlace.fromJson(Map<String, dynamic> json) {
    return ResponsePlace(
        placeName: json["placeName"] as String,
        placeId: json["placeId"] as String,
        lat: json["lat"] as double,
        lng: json["lng"] as double,
        photoReference:
            (json["photoReference"] ?? "assets/images/noImageW.png") as String,
        rate: (json["rate"] ?? 6) as num,
        type: json["type"] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      "placeName": placeName,
      "placeId": placeId,
      "lat": lat,
      "lng": lng,
      "photoReference": photoReference,
      "rate": rate,
      "type": type
    };
  }
}
