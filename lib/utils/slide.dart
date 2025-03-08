// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class SlideDownAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final Duration duration;

  const SlideDownAppBar({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: -100, end: 0),
      duration: duration,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}