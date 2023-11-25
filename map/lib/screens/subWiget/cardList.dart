// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:map/entity/responsePlace.dart';
import 'package:map/provider/locationNotifier.dart';
import 'package:map/utilties/locationUntil/locationWidgetUtil.dart';
import 'package:provider/provider.dart';

/// 최근 알람한 지역들 5개 보여주고 알람 다시 할 수 있도록
class CardList extends StatelessWidget {
  CardList(
      {Key? key,
      @required this.place,
      @required this.constraints,
      @required this.globalKey})
      : super(key: key);
  final constraints;
  final globalKey;
  final place;
  LocationWidgetUtil popUp = LocationWidgetUtil();

  ///   constraints : 부모 크기
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.4;
    return GestureDetector(
      onTap: () async {
        if (Provider.of<LocationNotifier>(context, listen: false).showHide &&
            place != null) {
          await popUp.showPopup(context, place, false,globalKey: globalKey);
        }
         // popUp.testup(context, constraints,  globalKey);
      },
      child: Card(
        color: const Color(0xff2d2d2d),
        child: place == null
            ? Container(
                alignment: Alignment.center,
                width: constraints.maxWidth,
                height: constraints.maxHeight / 9,
                child: const Text("최근 경로 및 알람을 보여줍니다."))
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.getPlaceName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        place.getNum != 6
                            ? SizedBox(
                                width: width,
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: width / 3,
                                        child: Image.asset(
                                          "assets/images/star${popUp.ratingStar(place.getNum)}.png",
                                          fit: BoxFit.cover,
                                        )),
                                    SizedBox(
                                      width: width / 30,
                                    ),
                                    Text("${place.getNum}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ],
                                ))
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: constraints.maxWidth / 4,
                    height: constraints.maxHeight / 9,
                    child:
                        place.getPhotoReference == "assets/images/noImageW.png"
                            ? Image.asset(
                                place.getPhotoReference,
                                fit: BoxFit.fill,
                              )
                            : Image.network(
                                "https://maps.googleapis.com/maps/api/place/photo?photo_reference=${place.getPhotoReference}&key=${dotenv.env["GoogleApikey"]}&maxheight=300&maxwidth=300",
                                fit: BoxFit.fill,
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}
