import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class WhippyHeader extends StatelessWidget {
  const WhippyHeader({this.onHomeTap, this.onSettingsTap, super.key});
  final VoidCallback? onHomeTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
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
                  child: Text(
                    'whippy',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSettingsTap,
            tooltip: '설정',
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}
