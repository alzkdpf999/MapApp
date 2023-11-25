// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:map/entity/responsePlace.dart';
import 'package:map/provider/locationNotifier.dart';
import 'package:map/provider/loginNotifier.dart';
import 'package:map/provider/pageNotifier.dart';
import 'package:map/provider/placeNotifier.dart';

import 'package:map/screens/loginScreen/loginScreens.dart';
import 'package:map/screens/subWiget/cardList.dart';

import 'package:provider/provider.dart';

/// 유저 정보와 카드리스트(최근 지역 5개)를 볼 수 있는  Drawer
class ViewDrawer extends StatelessWidget {
  const ViewDrawer({Key? key, @required this.globalKey, @required this.http})
      : super(key: key);
  final globalKey;
  final http;

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    List<ResponsePlace> list =
        Provider.of<PlaceNotifier>(context, listen: false).viewPlaceList();
    // TODO: implement build
    return LayoutBuilder(builder: (context, constraints) {
      return Drawer(
          child: Column(children: <Widget>[
        _buildUserAccountsDrawerHeader(context.read<LoginNotifier>().loginData),
        for (int i = 0; i < list.length; i++)
          CardList(
            place: list[i],
            constraints: constraints,
            globalKey: globalKey,
          ),
        for (int i = 0; i < 5 - list.length; i++)
          CardList(place: null, constraints: constraints, globalKey: globalKey),
        const Spacer(),
        Container(
          alignment: const Alignment(0.9, 1.0),
          margin: const EdgeInsets.only(bottom: 20),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.logout,
              size: 25,
              color: Colors.white,
            ),
            onPressed: () async {

              await context.read<LoginNotifier>().loginData.logout();
              await Provider.of<PlaceNotifier>(context,listen: false).clearPlace();
              await storage.delete(key: "platForm");
              await storage.delete(key: "userId");
              context.read<LocationNotifier>().initController();
              Provider.of<LocationNotifier>(context, listen: false).streamCancle();
              Navigator.pop(context);

              Provider.of<PageNotifier>(context, listen: false)
                  .goToOther(LoginScreen.pageName); // 페이지이름 넘겨주기
            },
          ),
        ),
      ]));
    });
  }

  UserAccountsDrawerHeader _buildUserAccountsDrawerHeader(dynamic received) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
          backgroundImage: NetworkImage(received.userEntity.getImgUrl)),
      accountName: Text(received.userEntity.getName),
      accountEmail: Text(received.userEntity.getEmail),
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0))),
    );
  }
}
