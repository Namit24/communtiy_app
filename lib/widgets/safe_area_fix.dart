import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// A wrapper widget that handles safe area differently on web vs mobile
class SafeAreaFix extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const SafeAreaFix({
    Key? key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On web, SafeArea can sometimes cause layout issues with certain browsers
    if (kIsWeb) {
      return Padding(
        padding: EdgeInsets.only(
          top: top ? 8.0 : 0,
          bottom: bottom ? 8.0 : 0,
          left: left ? 8.0 : 0,
          right: right ? 8.0 : 0,
        ),
        child: child,
      );
    }

    // On mobile, use standard SafeArea
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}
