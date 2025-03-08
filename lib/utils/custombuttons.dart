import 'package:flutter/material.dart';

class Custombutton extends StatelessWidget {
  final double? height;
  final Color color;
  final double? width;
  final Widget child;

  final VoidCallback ontap;
  const Custombutton({
    super.key,
    required this.ontap,
    this.height,
    this.width,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: ontap,
        child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: color),
            child: child));
  }
}
