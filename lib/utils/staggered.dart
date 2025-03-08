// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class StaggeredCategoryCard extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const StaggeredCategoryCard({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
