// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/entity/responsePlace.dart';
import 'package:map/main.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

void main() async {

 const Distance distance = Distance();
 // double meter = distance.as(LengthUnit.Kilometer,LatLng(37.64820, 127.0623),LatLng(37.64318, 127.0652));
 double meter = distance(LatLng(37.64820, 127.0623),LatLng(37.64820, 127.0623));

 print(meter/1000);
}
