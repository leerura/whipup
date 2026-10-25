import 'package:app/features/recipe/presentation/video_pip_geometry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('standard PIP keeps a 16:9 viewport at YouTube minimum height', () {
    expect(VideoPipGeometry.standardSize.width, 356);
    expect(VideoPipGeometry.standardSize.height, 200);
    expect(
      VideoPipGeometry.standardSize.width /
          VideoPipGeometry.standardSize.height,
      closeTo(16 / 9, 0.003),
    );
  });

  test('uses the available width without shrinking below YouTube minimum', () {
    expect(VideoPipGeometry.sizeForAvailableWidth(390), const Size(356, 200));
    expect(VideoPipGeometry.sizeForAvailableWidth(372), const Size(356, 200));
    expect(VideoPipGeometry.sizeForAvailableWidth(320), const Size(304, 200));
    expect(VideoPipGeometry.sizeForAvailableWidth(216), const Size(200, 200));
    expect(VideoPipGeometry.sizeForAvailableWidth(215), isNull);
  });
}
