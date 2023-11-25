import 'package:flutter/material.dart';

/// 식당,카페, 바 스위칭 버튼
class ChildButton extends StatelessWidget {
  const ChildButton({super.key, required this.onPressed, required this.image, this.check =false});

  final VoidCallback onPressed;
  final Widget image;
  final bool check;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onPressed,
        child: Container(padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: check ?  Colors.black : Colors.blue, borderRadius: BorderRadius.circular(50)),
            width: 34,
            child: image));
  }
}
