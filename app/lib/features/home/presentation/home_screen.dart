import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';
import '../../../shared/presentation/widgets/main_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.apiClient,
    this.onHomeSelected,
    this.onIngredientsSelected,
    this.onRecommendationsSelected,
    this.onRecipeSelected,
    super.key,
  });

  final ApiClient apiClient;
  final VoidCallback? onHomeSelected;
  final VoidCallback? onIngredientsSelected;
  final VoidCallback? onRecommendationsSelected;
  final ValueChanged<int>? onRecipeSelected;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<OwnedIngredient> _ownedIngredients = const [];
  List<RecommendationItem> _availableItems = const [];
  List<RecommendationItem> _oneMissingItem = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    final requestId = ++_requestId;
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });

    try {
      final ownedResponse = await widget.apiClient
          .getOwnedIngredientApi()
          .getOwnedIngredients();
      final owned = ownedResponse.data;
      if (owned == null) {
        throw StateError('The owned ingredient response body is empty.');
      }
      if (!mounted || requestId != _requestId) return;

      if (owned.items.isEmpty) {
        setState(() {
          _ownedIngredients = const [];
          _availableItems = const [];
          _oneMissingItem = const [];
          _isLoading = false;
        });
        return;
      }

      final recommendations = await Future.wait([
        widget.apiClient.getRecommendationApi().getRecipeRecommendations(
          mode: RecommendationMode.AVAILABLE,
        ),
        widget.apiClient.getRecommendationApi().getRecipeRecommendations(
          mode: RecommendationMode.MISSING_INGREDIENTS,
        ),
      ]);
      final available = recommendations[0].data;
      final missing = recommendations[1].data;
      if (available == null || missing == null) {
        throw StateError('The recommendation response body is empty.');
      }
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _ownedIngredients = owned.items.toList(growable: false);
        _availableItems = available.items
            .where((item) => item.missingCount == 0)
            .take(2)
            .toList(growable: false);
        _oneMissingItem = missing.items
            .where((item) => item.missingCount == 1)
            .take(1)
            .toList(growable: false);
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Failed to load Home: $error');
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _hasLoadError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInventoryEmpty =
        !_isLoading && !_hasLoadError && _ownedIngredients.isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: MainBottomNavigation(
          selectedTab: MainTab.home,
          onIngredientsSelected: widget.onIngredientsSelected,
          onRecommendationsSelected: widget.onRecommendationsSelected,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _HomeHeader(onTap: widget.onHomeSelected),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasLoadError
                    ? _HomeLoadError(onRetry: _loadHome)
                    : isInventoryEmpty
                    ? _EmptyInventoryHome(
                        onRegisterIngredients: widget.onIngredientsSelected,
                      )
                    : _PopulatedInventoryHome(
                        ownedIngredients: _ownedIngredients,
                        availableItems: _availableItems,
                        oneMissingItem: _oneMissingItem,
                        onIngredientsSelected: widget.onIngredientsSelected,
                        onRecommendationsSelected:
                            widget.onRecommendationsSelected,
                        onRecipeSelected: widget.onRecipeSelected,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: onTap,
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
    );
  }
}

class _PopulatedInventoryHome extends StatelessWidget {
  const _PopulatedInventoryHome({
    required this.ownedIngredients,
    required this.availableItems,
    required this.oneMissingItem,
    required this.onIngredientsSelected,
    required this.onRecommendationsSelected,
    required this.onRecipeSelected,
  });

  final List<OwnedIngredient> ownedIngredients;
  final List<RecommendationItem> availableItems;
  final List<RecommendationItem> oneMissingItem;
  final VoidCallback? onIngredientsSelected;
  final VoidCallback? onRecommendationsSelected;
  final ValueChanged<int>? onRecipeSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          '오늘, 뭐 먹을까요?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 24,
            height: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '내 재료에 맞는 메뉴를 골라봤어요.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 10),
        _InventorySummary(
          ownedIngredients: ownedIngredients,
          onManage: onIngredientsSelected,
        ),
        if (availableItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
            title: '지금 바로 만들 수 있어요',
            actionLabel: '추천 더 보기',
            onAction: onRecommendationsSelected,
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < availableItems.length; index++) ...[
            _HomeRecipeCard(
              item: availableItems[index],
              onTap: onRecipeSelected == null
                  ? null
                  : () => onRecipeSelected!(availableItems[index].recipeId),
            ),
            if (index + 1 < availableItems.length) const SizedBox(height: 8),
          ],
        ],
        if (oneMissingItem.isNotEmpty) ...[
          SizedBox(height: availableItems.isEmpty ? 24 : 18),
          const _SectionHeader(title: '재료 한 가지만 더 있으면 돼요'),
          const SizedBox(height: 10),
          _HomeRecipeCard(
            item: oneMissingItem.single,
            missingIngredientName: _missingIngredientName(
              oneMissingItem.single,
            ),
            onTap: onRecipeSelected == null
                ? null
                : () => onRecipeSelected!(oneMissingItem.single.recipeId),
          ),
        ],
      ],
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({
    required this.ownedIngredients,
    required this.onManage,
  });

  final List<OwnedIngredient> ownedIngredients;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final names = ownedIngredients.take(3).map((item) => item.name).join(' · ');
    final summary = ownedIngredients.length > 3 ? '$names 등' : names;

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '내 재료함',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onManage,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(44, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '관리',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.only(left: 8),
              minimumSize: const Size(44, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeRecipeCard extends StatelessWidget {
  const _HomeRecipeCard({
    required this.item,
    required this.onTap,
    this.missingIngredientName,
  });

  final RecommendationItem item;
  final VoidCallback? onTap;
  final String? missingIngredientName;

  @override
  Widget build(BuildContext context) {
    final isMissing = missingIngredientName != null;
    return Semantics(
      button: onTap != null,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: isMissing ? 88 : 82,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _HomeRecipeThumbnail(item: item),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isMissing
                              ? '$missingIngredientName 부족'
                              : '재료가 모두 있어요',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isMissing
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontSize: 12,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeRecipeThumbnail extends StatelessWidget {
  const _HomeRecipeThumbnail({required this.item});

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    if (item.thumbnailUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          item.thumbnailUrl,
          width: 62,
          height: 62,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _thumbnailFallback(),
        ),
      );
    }
    return _thumbnailFallback();
  }

  Widget _thumbnailFallback() => SizedBox(
    width: 62,
    height: 62,
    child: SvgPicture.asset(
      'assets/recipe/kimchi_fried_rice.svg',
      fit: BoxFit.cover,
    ),
  );
}

String _missingIngredientName(RecommendationItem item) {
  for (final result in item.requirementResults) {
    final value = result.oneOf.value;
    if (value is MissingRequirementResult) {
      final options = value.missingOptions;
      if (options.isEmpty) return '재료';
      return options.map((option) => option.requiredName).join(' 또는 ');
    }
  }
  return '재료';
}

class _EmptyInventoryHome extends StatelessWidget {
  const _EmptyInventoryHome({required this.onRegisterIngredients});

  final VoidCallback? onRegisterIngredients;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 58, 20, 0),
      children: [
        Text(
          '재료함이 비어 있어요',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 24,
            height: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: Text(
            '재료를 다시 담으면 메뉴를 다시 찾아드릴게요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: SvgPicture.asset(
            'assets/home_pantry_illustration.svg',
            width: 190,
            height: 170,
            semanticsLabel: '비어 있는 재료함 일러스트',
          ),
        ),
        const SizedBox(height: 50),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: onRegisterIngredients,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              '재료 다시 담기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '재료는 언제든 다시 수정할 수 있어요.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _HomeLoadError extends StatelessWidget {
  const _HomeLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '홈 정보를 불러오지 못했어요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
