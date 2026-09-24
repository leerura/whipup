import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../shared/presentation/widgets/main_bottom_navigation.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({
    super.key,
    required this.apiClient,
    this.ownedIngredientCount = 8,
    this.onRegisterIngredients,
    this.onIngredientsSelected,
    this.onRecipeSelected,
  });

  final ApiClient apiClient;
  final int ownedIngredientCount;
  final VoidCallback? onRegisterIngredients;
  final VoidCallback? onIngredientsSelected;
  final ValueChanged<int>? onRecipeSelected;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _selectedMissingCount = 0;
  List<RecommendationItem> _items = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final requestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _hasLoadError = false;
      _items = const [];
    });

    try {
      final response = await widget.apiClient
          .getRecommendationApi()
          .getRecommendations(
            missingCount: _selectedMissingCount,
            page: 0,
            size: 30,
          );
      final page = response.data;
      if (page == null) {
        throw StateError('The recommendation response body is empty.');
      }
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _items = page.items.toList(growable: false);
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Failed to load recommendations: $error');
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _hasLoadError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: MainBottomNavigation(
          selectedTab: MainTab.recommendations,
          onIngredientsSelected: widget.onIngredientsSelected,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _ScreenHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Text(
                      '내 재료 ${widget.ownedIngredientCount}개 기준',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '만들 수 있는 메뉴예요',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RecommendationSelector(
                      selectedMissingCount: _selectedMissingCount,
                      onChanged: (value) {
                        if (value == _selectedMissingCount) return;
                        setState(() => _selectedMissingCount = value);
                        _loadRecommendations();
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 72),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_hasLoadError)
                      _RecommendationLoadError(
                        onRetry: _loadRecommendations,
                      )
                    else if (_items.isEmpty)
                      _EmptyRecommendations(
                        missingCount: _selectedMissingCount,
                        onRegisterIngredients: widget.onRegisterIngredients,
                      )
                    else
                      _RecipeGrid(
                        items: _items,
                        onRecipeSelected: widget.onRecipeSelected,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: Alignment.centerLeft,
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
    );
  }
}

class _RecommendationSelector extends StatelessWidget {
  const _RecommendationSelector({
    required this.selectedMissingCount,
    required this.onChanged,
  });

  final int selectedMissingCount;
  final ValueChanged<int> onChanged;

  static const _labels = ['바로 가능', '1개 부족', '2개 부족'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFD1D1D6)),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isSelected = selectedMissingCount == index;

          return Expanded(
            child: Semantics(
              selected: isSelected,
              button: true,
              child: Material(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => onChanged(index),
                  borderRadius: BorderRadius.circular(18),
                  child: Center(
                    child: Text(
                      _labels[index],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.items, required this.onRecipeSelected});

  final List<RecommendationItem> items;
  final ValueChanged<int>? onRecipeSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: items
              .map(
                (item) => SizedBox(
                  width: cardWidth,
                  child: _RecipeCard(
                    item: item,
                    onTap: onRecipeSelected == null
                        ? null
                        : () => onRecipeSelected!(item.recipeId),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.item, this.onTap});

  final RecommendationItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final missingIngredient = item.missingIngredients.isEmpty
        ? null
        : item.missingIngredients.first.name;

    return Semantics(
      button: onTap != null,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.28,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _RecipeThumbnail(item: item),
                    if (missingIngredient != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _MissingIngredientBadge(
                          ingredient: missingIngredient,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      missingIngredient == null
                          ? '재료가 다 있어요'
                          : '$missingIngredient만 있으면 돼요',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeThumbnail extends StatelessWidget {
  const _RecipeThumbnail({required this.item});

  final RecommendationItem item;

  static const _fallbackColors = [
    Color(0xFFFFE1D5),
    Color(0xFFFFF0B8),
    Color(0xFFE9F1C7),
    Color(0xFFDCECF8),
  ];

  @override
  Widget build(BuildContext context) {
    final fallbackColor =
        _fallbackColors[item.recipeId.abs() % _fallbackColors.length];

    if (item.thumbnailUrl.isNotEmpty) {
      return Image.network(
        item.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _ThumbnailPlaceholder(color: fallbackColor),
      );
    }

    return _ThumbnailPlaceholder(color: fallbackColor);
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 42,
          color: AppColors.textPrimary.withValues(alpha: 0.28),
        ),
      ),
    );
  }
}

class _MissingIngredientBadge extends StatelessWidget {
  const _MissingIngredientBadge({required this.ingredient});

  final String ingredient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        ingredient.characters.first,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyRecommendations extends StatelessWidget {
  const _EmptyRecommendations({
    required this.missingCount,
    required this.onRegisterIngredients,
  });

  final int missingCount;
  final VoidCallback? onRegisterIngredients;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 54),
      child: Column(
        children: [
          const _EmptyPlateIllustration(),
          const SizedBox(height: 26),
          Text(
            '$missingCount개 부족 메뉴가 없어요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '다른 메뉴를 확인하거나\n재료를 더 등록해 보세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 150,
            height: 46,
            child: OutlinedButton(
              onPressed: onRegisterIngredients,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '재료 등록하기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationLoadError extends StatelessWidget {
  const _RecommendationLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 54),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 44,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 18),
          Text(
            '추천 메뉴를 불러오지 못했어요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlateIllustration extends StatelessWidget {
  const _EmptyPlateIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: 112,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0x12000000),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F4),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE3E3E7), width: 2),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 30,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
