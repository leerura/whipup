import 'package:flutter/material.dart';

import '../../../app/theme.dart';

enum MainTab { home, ingredients, recommendations }

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({
    required this.selectedTab,
    this.onHomeSelected,
    this.onIngredientsSelected,
    this.onRecommendationsSelected,
    super.key,
  });

  final MainTab selectedTab;
  final VoidCallback? onHomeSelected;
  final VoidCallback? onIngredientsSelected;
  final VoidCallback? onRecommendationsSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            children: [
              _MainBottomNavigationItem(
                icon: Icons.home_outlined,
                label: '홈',
                selected: selectedTab == MainTab.home,
                onTap: onHomeSelected,
              ),
              _MainBottomNavigationItem(
                icon: Icons.shopping_bag_outlined,
                label: '재료',
                selected: selectedTab == MainTab.ingredients,
                onTap: onIngredientsSelected,
              ),
              _MainBottomNavigationItem(
                icon: Icons.room_service_outlined,
                label: '추천',
                selected: selectedTab == MainTab.recommendations,
                onTap: onRecommendationsSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainBottomNavigationItem extends StatelessWidget {
  const _MainBottomNavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFFAEAEB2);

    return Expanded(
      child: Semantics(
        button: onTap != null,
        selected: selected,
        child: InkWell(
          onTap: selected ? null : onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
