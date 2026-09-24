import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';

class OnboardingMotionSequence extends StatefulWidget {
  const OnboardingMotionSequence({
    required this.onCompleted,
    super.key,
  });

  final VoidCallback onCompleted;

  @override
  State<OnboardingMotionSequence> createState() =>
      _OnboardingMotionSequenceState();
}

class _OnboardingMotionSequenceState extends State<OnboardingMotionSequence>
    with SingleTickerProviderStateMixin {
  static const _timelineDuration = Duration(milliseconds: 3200);
  static const _designWidth = 390.0;
  static const _designHeight = 844.0;
  static const _gentleCurve = Curves.easeInOutCubic;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _timelineDuration,
  )..addStatusListener(_handleAnimationStatus);

  bool _started = false;
  bool _completed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;

    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _complete();
  }

  void _complete() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.onCompleted();
  }

  double _transitionProgress(double value, double start, double end) {
    final progress = ((value - start) / (end - start)).clamp(0.0, 1.0);
    return _gentleCurve.transform(progress);
  }

  double _lerp(double start, double end, double progress) {
    return start + ((end - start) * progress);
  }

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
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final value = _controller.value;
            final introProgress = _transitionProgress(value, 0.25, 0.5);
            final loginProgress = _transitionProgress(value, 0.75, 1);

            return LayoutBuilder(
              builder: (context, constraints) {
                final scale = constraints.maxWidth / _designWidth;

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    _buildAnimatedCircle(
                      scale: scale,
                      introProgress: introProgress,
                      loginProgress: loginProgress,
                    ),
                    _buildAnimatedWordmarks(
                      scale: scale,
                      introProgress: introProgress,
                      loginProgress: loginProgress,
                    ),
                    _buildIntroHeadline(
                      scale: scale,
                      introProgress: introProgress,
                      loginProgress: loginProgress,
                    ),
                    _buildLoginContent(
                      scale: scale,
                      loginProgress: loginProgress,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedCircle({
    required double scale,
    required double introProgress,
    required double loginProgress,
  }) {
    final size = _lerp(1138, 646, introProgress);
    final introLeft = _lerp(-374, -128, introProgress);
    final introTop = _lerp(-147, -95, introProgress);
    final top = _lerp(introTop, -428, loginProgress);

    return Positioned(
      left: introLeft * scale,
      top: top * scale,
      width: size * scale,
      height: size * scale,
      child: SvgPicture.asset(
        'assets/onboarding/intro_glow.svg',
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildAnimatedWordmarks({
    required double scale,
    required double introProgress,
    required double loginProgress,
  }) {
    const splashWidth = 200.0;
    const splashHeight = 59.9366;
    const introWidth = 400.0;
    const introHeight = 119.874;
    const splashLeft = (_designWidth - splashWidth) / 2;
    const splashTop = (_designHeight - splashHeight) / 2;
    const introLeft = -5.0;
    const introTop = _designHeight - 34 - introHeight;

    final left = _lerp(splashLeft, introLeft, introProgress);
    final top = _lerp(splashTop, introTop, introProgress);
    final width = _lerp(splashWidth, introWidth, introProgress);
    final height = _lerp(splashHeight, introHeight, introProgress);
    final visibleOpacity = 1 - loginProgress;

    return Positioned(
      left: left * scale,
      top: top * scale,
      width: width * scale,
      height: height * scale,
      child: Opacity(
        opacity: visibleOpacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - introProgress,
              child: SvgPicture.asset(
                'assets/onboarding/splash_logo.svg',
                fit: BoxFit.fill,
              ),
            ),
            Opacity(
              opacity: introProgress,
              child: SvgPicture.asset(
                'assets/onboarding/intro_wordmark.svg',
                fit: BoxFit.fill,
                semanticsLabel: 'whippy',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroHeadline({
    required double scale,
    required double introProgress,
    required double loginProgress,
  }) {
    return Positioned(
      top: 253 * scale,
      left: 20 * scale,
      right: 20 * scale,
      child: Opacity(
        opacity: introProgress * (1 - loginProgress),
        child: Text(
          '있는 재료로\n오늘의 한 끼를!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoginContent({
    required double scale,
    required double loginProgress,
  }) {
    return Opacity(
      opacity: loginProgress,
      child: Stack(
        children: [
          _DecorationDot(
            assetName: 'assets/onboarding/login_dot_large.svg',
            left: 72 * scale,
            top: 320 * scale,
            size: 27 * scale,
          ),
          _DecorationDot(
            assetName: 'assets/onboarding/login_dot_right.svg',
            left: 334 * scale,
            top: 408 * scale,
            size: 21 * scale,
          ),
          _DecorationDot(
            assetName: 'assets/onboarding/login_dot_small_top.svg',
            left: 119 * scale,
            top: 292 * scale,
            size: 13 * scale,
          ),
          _DecorationDot(
            assetName: 'assets/onboarding/login_dot_small_bottom.svg',
            left: 146 * scale,
            top: 522 * scale,
            size: 12 * scale,
          ),
          Positioned(
            top: 369 * scale,
            left: 20 * scale,
            right: 20 * scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '냉장고 속\n재료를 골라보세요',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '지금 만들 수 있는 메뉴를 찾아드릴게요',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            left: 20 * scale,
            right: 20 * scale,
            bottom: 70 * scale,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.kakao,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '카카오로 시작하기',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorationDot extends StatelessWidget {
  const _DecorationDot({
    required this.assetName,
    required this.left,
    required this.top,
    required this.size,
  });

  final String assetName;
  final double left;
  final double top;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: SvgPicture.asset(assetName, fit: BoxFit.fill),
    );
  }
}
