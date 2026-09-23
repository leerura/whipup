import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';

class IngredientRegistrationCompleteSheet extends StatelessWidget {
  const IngredientRegistrationCompleteSheet({
    required this.ingredientCount,
    required this.availableMenuCount,
    required this.onViewRecommendations,
    super.key,
  });

  static const _dishAssetPaths = [
    'assets/recipe/kimchi_fried_rice.svg',
    'assets/recipe/rolled_omelette.svg',
    'assets/recipe/spicy_pork.svg',
  ];

  final int ingredientCount;
  final int availableMenuCount;
  final VoidCallback onViewRecommendations;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        height: 454,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '재료 ${ingredientCount}개를 등록했어요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '지금 바로 만들 수 있는\n메뉴가 ${availableMenuCount}개 있어요',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 161,
                left: 24,
                right: 0,
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _dishAssetPaths.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _DishIllustration(
                    assetPath: _dishAssetPaths[index],
                    scaleToFigmaFrame: index == 2,
                  ),
                ),
              ),
              Positioned(
                top: 344,
                left: 24,
                right: 24,
                height: 56,
                child: FilledButton(
                  onPressed: onViewRecommendations,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '추천 보러가기',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DishIllustration extends StatelessWidget {
  const _DishIllustration({
    required this.assetPath,
    required this.scaleToFigmaFrame,
  });

  final String assetPath;
  final bool scaleToFigmaFrame;

  @override
  Widget build(BuildContext context) {
    final illustration = SvgPicture.asset(
      assetPath,
      width: 140,
      height: 140,
      fit: BoxFit.cover,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 140,
        child: scaleToFigmaFrame
            ? Transform.scale(
                scale: 150.7692307692 / 140,
                child: illustration,
              )
            : illustration,
      ),
    );
  }
}
