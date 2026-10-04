import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class IngredientRegistrationCompleteSheet extends StatelessWidget {
  const IngredientRegistrationCompleteSheet({
    required this.ingredientCount,
    required this.recommendationList,
    required this.onViewRecommendations,
    super.key,
  });

  final int ingredientCount;
  final RecommendationListResponse? recommendationList;
  final VoidCallback onViewRecommendations;

  @override
  Widget build(BuildContext context) {
    final recommendations = recommendationList?.items
        .take(5)
        .toList(growable: false) ?? const <RecommendationItem>[];
    late final String title;
    if (recommendationList == null) {
      title = '추천 메뉴는\n다음 화면에서 확인해 주세요';
    } else if (recommendations.isEmpty) {
      title = '지금 바로 만들 수 있는\n메뉴가 아직 없어요';
    } else {
      title = '지금 바로 만들 수 있는\n메뉴가 ${recommendationList!.items.length}개 있어요';
    }

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
                      title,
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
                child: recommendations.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: _RecommendationPreviewMessage(
                          hasError: recommendationList == null,
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 24),
                        itemCount: recommendations.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            _RecommendationPreviewCard(
                              item: recommendations[index],
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

class _RecommendationPreviewCard extends StatelessWidget {
  const _RecommendationPreviewCard({required this.item});

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: item.name,
      child: SizedBox(
        width: 140,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    item.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const _RecipeImageFallback(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendationPreviewMessage extends StatelessWidget {
  const _RecommendationPreviewMessage({required this.hasError});

  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          hasError ? '추천 화면에서 다시 불러올게요' : '추천 가능한 메뉴가 없어요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _RecipeImageFallback extends StatelessWidget {
  const _RecipeImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceSubtle,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.textMuted,
          size: 32,
        ),
      ),
    );
  }
}
