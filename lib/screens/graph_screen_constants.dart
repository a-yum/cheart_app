import 'package:flutter/material.dart';

enum TimeFilter {
  hourly,
  weekly,
  monthly,
}

class GraphScreenConstants {
  static const double minCardSize = 90.0;
  static const double maxCardSize = 150.0;
  static const double cardSpacing = 8.0;
  static const double minPadding = 8.0;
  static const double maxPadding = 16.0;

  static double getResponsivePadding(double cardSize) {
    if (cardSize <= minCardSize) return minPadding;
    if (cardSize >= maxCardSize) return maxPadding;
    return minPadding +
        (cardSize - minCardSize) *
            (maxPadding - minPadding) /
            (maxCardSize - minCardSize);
  }

  static TextStyle getCardTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width < 360 ? 12.0 : 14.0,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    );
  }

  static TextStyle getCardValueStyle(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width < 360 ? 20.0 : 24.0,
      fontWeight: FontWeight.bold,
    );
  }
}
