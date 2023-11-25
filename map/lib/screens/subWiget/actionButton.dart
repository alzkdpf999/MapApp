import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map/customIcon/my_flutter_app_icons.dart';
import 'package:map/provider/locationNotifier.dart';
import 'package:provider/provider.dart';

const Duration _durationSpeed = Duration(milliseconds: 300);
/// 스위칭 액션버튼 시작 부분
class ActionButton extends StatefulWidget {
  final double distance;
  final List<Widget> childButtons;

  const ActionButton(
      {Key? key, required this.distance, required this.childButtons})
      : super(key: key);

  @override
  State<ActionButton> createState() => ActionButtonState();
}

class ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  AnimationController? _controller;
  Animation<double>? _expandAnimation;


  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, value: _open ? 1.0 : 0.0, duration: _durationSpeed);
    _expandAnimation =
        CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Visibility(
        visible: Provider.of<LocationNotifier>(context,listen: false).showHide,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            _buildCloseAnimatedContainer(),
            _buildOpenAnimatedContainer(),
          ]..insertAll(0, _buildActionButton()),
        ),
      ),
    );
  }

  List<_ActionButtons> _buildActionButton() {
    List<_ActionButtons> buttonChildren = [];
    final int count = widget.childButtons.length;
    final double gap = 90.0 / (count - 1);
    for (var i = 0, degree = 0.0; i < count; i++, degree += gap) {
      buttonChildren.add(_ActionButtons(
          distance: widget.distance,
          degree: degree,
          progress: _expandAnimation!,
          child: widget.childButtons[i]));
    }
    return buttonChildren;
  }

  /// 액션 버튼 처음
  AnimatedContainer _buildOpenAnimatedContainer() {
    return AnimatedContainer(
      margin: EdgeInsets.only(right: 10, top: 10),
      width: 40,
      duration: _durationSpeed,
      transform: Matrix4.rotationZ(_open ? 0 : math.pi / 4),
      transformAlignment: Alignment.center,
      child: AnimatedOpacity(
        duration: _durationSpeed,
        opacity: _open ? 0.0 : 1.0,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: toggle,
          child: const Icon(MyFlutterApp.switch_icon, color: Colors.white),
        ),
      ),
    );
  }

  ///  액션 버튼 닫기
  AnimatedContainer _buildCloseAnimatedContainer() {
    return AnimatedContainer(
      margin: const EdgeInsets.only(right: 10, top: 10),
      width: 40,
      duration: _durationSpeed,
      transform: Matrix4.rotationZ(_open ? 0 : math.pi / 4),
      transformAlignment: Alignment.center,
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: toggle,
        child: const Icon(
          Icons.close,
          color: Colors.black,
        ),
      ),
    );
  }


  void toggle() {
    _open = !_open;
    setState(() {
      if (_open) {
        _controller!.forward();
      } else {
        _controller!.reverse();
      }
    });
  }
}

class _ActionButtons extends StatelessWidget {
  final double distance;
  final double degree;
  final Animation<double> progress; //시간
  final Widget child;

  const _ActionButtons(
      {Key? key,
      required this.distance,
      required this.degree,
      required this.progress,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final Offset offset = Offset.fromDirection(
            degree * (math.pi / 180), progress.value * distance);
        return Positioned(
            right: offset.dx + 12, top: offset.dy + 15, child: child!);
      },
      child: child,
    );
  }
}
