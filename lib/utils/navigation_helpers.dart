import 'package:flutter/material.dart';

void navigateWithFade({
  required BuildContext context,
  required Widget destination,
  bool replace = false,
  Duration duration = const Duration(milliseconds: 400),
}) {
  final route = PageRouteBuilder(
    pageBuilder: (_, __, ___) => destination,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: duration,
  );

  if (replace) {
    Navigator.pushReplacement(context, route);
  } else {
    Navigator.push(context, route);
  }
}
