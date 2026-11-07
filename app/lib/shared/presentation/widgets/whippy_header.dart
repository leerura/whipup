import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';

class WhippyHeader extends StatelessWidget {
  const WhippyHeader({this.onHomeTap, this.onSettingsTap, super.key});
  final VoidCallback? onHomeTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onHomeTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: 70,
                    height: 21,
                    child: SvgPicture.asset(
                      'assets/onboarding/intro_wordmark.svg',
                      width: 70,
                      height: 21,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: onSettingsTap,
              tooltip: '설정',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
