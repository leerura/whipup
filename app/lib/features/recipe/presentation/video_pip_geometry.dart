import 'package:flutter/widgets.dart';

class VideoPipGeometry {
  const VideoPipGeometry._();

  static const Size standardSize = Size(356, 200);
  static const double minimumViewportWidth = 200;
  static const double topInset = 12;
  static const double rightInset = 16;

  static Size? sizeForAvailableWidth(double width) {
    final pipWidth = width - rightInset;
    if (pipWidth < minimumViewportWidth) return null;
    return Size(pipWidth.clamp(minimumViewportWidth, standardSize.width), 200);
  }
}
