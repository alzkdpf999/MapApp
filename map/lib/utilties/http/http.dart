import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:map/entity/responsePlace.dart';
import 'package:map/entity/user.dart';

const serverUrl = "http://192.168.45.5:80";

class Http {
  static const storage = FlutterSecureStorage();
/// 로그인했을때 내가 알람했던 가게 주기
  Future<List<ResponsePlace>> myLoginPlaceList(UserEntity user) async {
    final url = Uri.parse("$serverUrl/map/login");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final userId = jsonResponse["userId"];
      await storage.write(key: "userId", value: userId.toString());
      final List<dynamic> list = jsonResponse["place"];
      final List<ResponsePlace> placeList =
          list.map((e) => ResponsePlace.fromJson(e)).toList();
      return placeList;
    } else {
      log("${response.statusCode}");
      throw Exception("fail");
    }
  }

  /// 오토로그인했을때 내가 알람했던 가게 주기
  Future<List<ResponsePlace>> myAutoPlaceList() async {
    final userId = await storage.read(key: "userId");
    // final userId = "2";
    final url = Uri.parse("$serverUrl/map/login/$userId");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      final List<ResponsePlace> placeList = [];

      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> list = jsonResponse["place"];
      for (final place in list) {
        placeList.add(ResponsePlace.fromJson(place));
      }
      return placeList;
    } else {
      throw Exception("fail");
    }
  }
  /// 알람 시작한 가게 저장하기
  Future<bool> myPlaceSave(ResponsePlace places) async {

      final userId = await storage.read(key: "userId");
      final url = Uri.parse("$serverUrl/map/$userId");

      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(places.toJson()));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }

  }
}
