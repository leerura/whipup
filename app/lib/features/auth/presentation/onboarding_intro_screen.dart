import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  static const _designWidth = 390.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _designWidth;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: (constraints.maxWidth - (646 * scale)) / 2,
                  top: -95 * scale,
                  width: 646 * scale,
                  height: 646 * scale,
                  child: SvgPicture.asset(
                    'assets/onboarding/intro_glow.svg',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: 253 * scale,
                  left: 0,
                  right: 0,
                  child: Text(
                    '있는 재료로\n오늘의 한 끼를!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  left: -5 * scale,
                  bottom: 34 * scale,
                  width: 400 * scale,
                  height: 119.87 * scale,
                  child: SvgPicture.asset(
                    'assets/onboarding/intro_wordmark.svg',
                    fit: BoxFit.fill,
                    semanticsLabel: 'whippy',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
