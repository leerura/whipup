import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            OverflowBox(
              maxWidth: 1138,
              maxHeight: 1138,
              child: SvgPicture.asset(
                'assets/onboarding/splash_glow.svg',
                width: 1138,
                height: 1138,
              ),
            ),
            SvgPicture.asset(
              'assets/onboarding/splash_logo.svg',
              width: 200,
              height: 59.94,
            ),
          ],
        ),
      ),
    );
  }
}
