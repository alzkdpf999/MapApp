import 'package:flutter/foundation.dart';
import 'package:map/entity/responsePlace.dart';

class PlaceNotifier with ChangeNotifier {
  List<ResponsePlace> _responsePlaceList = []; //디비에서 데이터 가져온 리스트
  final List<ResponsePlace> _requestPlaceList = []; // 방금 추가한 것들 보여주기

  final List<ResponsePlace> _viewPlaceList = [];

  List<ResponsePlace> get responsePlaceList => _responsePlaceList;

  List<ResponsePlace> get requestPlaceList => _requestPlaceList;
/// 지금 알람 추가한 가게 넣어주기
  Future<void> placeListAdd(ResponsePlace place) async {
    int i = _requestPlaceList
        .indexWhere((element) => element.getPlaceId == place.getPlaceId);
    int j = _responsePlaceList
        .indexWhere((element) => element.getPlaceId == place.getPlaceId);
    if (i != -1) {
      _requestPlaceList.removeAt(i);
    }
    if (j != -1) {
      _responsePlaceList.removeAt(j);
    }
    _requestPlaceList.insert(0, place);
    notifyListeners();
  }
/// 드로우 부분에 보여줄 부분
  List<ResponsePlace> viewPlaceList() {
    _viewPlaceList.clear();
    for (ResponsePlace place in _requestPlaceList) {
      if (_viewPlaceList.length == 5) break;
      _viewPlaceList.add(place);
    }

    for (ResponsePlace place in _responsePlaceList) {
      if (_viewPlaceList.length == 5) break;
      _viewPlaceList.add(place);
    }
    return _viewPlaceList;
  }
  Future<void>  setResponsePlace(List<ResponsePlace> places) async{
    _responsePlaceList = places;
    notifyListeners();
}
  Future<void> clearPlace() async{
    _requestPlaceList.clear();
    notifyListeners();
  }

}
