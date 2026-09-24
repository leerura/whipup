import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';

class KakaoLoginScreen extends StatelessWidget {
  const KakaoLoginScreen({
    required this.onKakaoLogin,
    this.isLoading = false,
    this.hasError = false,
    super.key,
  });

  static const _designWidth = 390.0;

  final VoidCallback onKakaoLogin;
  final bool isLoading;
  final bool hasError;

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
                if (!hasError) ...[
                  Positioned(
                    left: (constraints.maxWidth - (646 * scale)) / 2,
                    top: -428 * scale,
                    width: 646 * scale,
                    height: 646 * scale,
                    child: SvgPicture.asset(
                      'assets/onboarding/login_glow.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
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
                    assetName:
                        'assets/onboarding/login_dot_small_bottom.svg',
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
                ] else ...[
                  Positioned(
                    top: 289 * scale,
                    left: 20 * scale,
                    right: 20 * scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/onboarding/login_error_icon.svg',
                          width: 64,
                          height: 64,
                          semanticsLabel: '로그인 오류',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '다시 한 번\n시도해 주세요',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '카카오 인증이 완료되지 않았어요',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 20 * scale,
                    right: 20 * scale,
                    bottom: 142 * scale,
                    height: 49,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '로그인 상태가 인증되지 않았어요',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  left: 20 * scale,
                  right: 20 * scale,
                  bottom: 70 * scale,
                  height: 56,
                  child: FilledButton(
                    onPressed: isLoading ? null : onKakaoLogin,
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.kakao,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('카카오로 시작하기'),
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
