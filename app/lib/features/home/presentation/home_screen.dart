import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';
import '../../../shared/presentation/widgets/main_bottom_navigation.dart';
import '../../../shared/presentation/widgets/whippy_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.apiClient,
    this.onHomeSelected,
    this.onIngredientsSelected,
    this.onRecommendationsSelected,
    this.onRecipeSelected,
    this.onSettingsSelected,
    super.key,
  });

  final ApiClient apiClient;
  final VoidCallback? onHomeSelected;
  final VoidCallback? onIngredientsSelected;
  final VoidCallback? onRecommendationsSelected;
  final ValueChanged<int>? onRecipeSelected;
  final VoidCallback? onSettingsSelected;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<OwnedIngredient> _ownedIngredients = const [];
  List<RecommendationItem> _availableItems = const [];
  List<RecommendationItem> _oneMissingItem = const [];
  List<RecommendationItem> _dailyMenuItems = const [];
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

      List<RecommendationItem> dailyMenuItems = const [];
      try {
        final dailyResponse = await widget.apiClient
            .getDailyMenuApi()
            .getDailyMenu();
        dailyMenuItems =
            dailyResponse.data?.items.toList(growable: false) ??
            const <RecommendationItem>[];
      } catch (error) {
        // Today-menu is an optional Redis-backed section. A failure must not
        // turn the rest of the home screen into an error state.
        debugPrint('Today menu unavailable: $error');
      }

      if (owned.items.isEmpty) {
        setState(() {
          _ownedIngredients = const [];
          _availableItems = const [];
          _oneMissingItem = const [];
          _dailyMenuItems = dailyMenuItems;
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
        _dailyMenuItems = dailyMenuItems;
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
        !_isLoading &&
        !_hasLoadError &&
        _ownedIngredients.isEmpty &&
        _dailyMenuItems.isEmpty;

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
              WhippyHeader(
                onHomeTap: widget.onHomeSelected,
                onSettingsTap: widget.onSettingsSelected,
              ),
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
                        dailyMenuItems: _dailyMenuItems,
                        onDailyMenuRemoved: _removeDailyMenu,
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

  Future<void> _removeDailyMenu(int recipeId) async {
    try {
      await widget.apiClient.getDailyMenuApi().removeDailyMenu(
        recipeId: recipeId,
      );
      if (!mounted) return;
      setState(() {
        _dailyMenuItems = _dailyMenuItems
            .where((item) => item.recipeId != recipeId)
            .toList(growable: false);
      });
    } catch (error) {
      debugPrint('Failed to remove today menu item: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('잠시 후 다시 시도해 주세요.')));
    }
  }
}

class _PopulatedInventoryHome extends StatelessWidget {
  const _PopulatedInventoryHome({
    required this.ownedIngredients,
    required this.availableItems,
    required this.oneMissingItem,
    required this.dailyMenuItems,
    required this.onDailyMenuRemoved,
    required this.onIngredientsSelected,
    required this.onRecommendationsSelected,
    required this.onRecipeSelected,
  });

  final List<OwnedIngredient> ownedIngredients;
  final List<RecommendationItem> availableItems;
  final List<RecommendationItem> oneMissingItem;
  final List<RecommendationItem> dailyMenuItems;
  final ValueChanged<int> onDailyMenuRemoved;
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
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '내 재료에 맞는 메뉴를 골라봤어요.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary, fontSize: 14),
        ),
        if (dailyMenuItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Row(
            children: [
              Icon(Icons.bookmark_border, color: AppColors.primary, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  '오늘 먹을 메뉴',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '자정에 사라져요',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in dailyMenuItems)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 50) / 2,
                  child: _TodayMenuCard(
                    item: item,
                    onTap: onRecipeSelected == null
                        ? null
                        : () => onRecipeSelected!(item.recipeId),
                    onRemove: () => onDailyMenuRemoved(item.recipeId),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < availableItems.length; index++) ...[
                if (index > 0) const SizedBox(width: 10),
                Expanded(
                  child: _HomeRecipeCard(
                    item: availableItems[index],
                    onTap: onRecipeSelected == null
                        ? null
                        : () =>
                              onRecipeSelected!(availableItems[index].recipeId),
                  ),
                ),
              ],
              if (availableItems.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        ],
        if (oneMissingItem.isNotEmpty) ...[
          SizedBox(height: availableItems.isEmpty ? 24 : 18),
          const _SectionHeader(title: '재료 한 가지만 더 있으면 돼요'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HomeRecipeCard(
                  item: oneMissingItem.single,
                  missingIngredientName: _missingIngredientName(
                    oneMissingItem.single,
                  ),
                  onTap: onRecipeSelected == null
                      ? null
                      : () => onRecipeSelected!(oneMissingItem.single.recipeId),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }
}

class _TodayMenuCard extends StatelessWidget {
  const _TodayMenuCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final RecommendationItem item;
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _HomeRecipeCard(
          item: item,
          onTap: onTap,
          missingIngredientName: item.missingCount > 0
              ? _missingIngredientName(item)
              : null,
        ),
        Positioned(
          top: 5,
          right: 5,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: Material(
                color: AppColors.white.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onRemove,
                  tooltip: '오늘 메뉴에서 빼기',
                  color: AppColors.textPrimary,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 22,
                    height: 22,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_rounded, size: 13),
                ),
              ),
            ),
          ),
        ),
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.28,
                child: _HomeRecipeThumbnail(item: item, size: double.infinity),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMissing ? '$missingIngredientName 부족' : '재료가 모두 있어요',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMissing
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w500,
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

class _HomeRecipeThumbnail extends StatelessWidget {
  const _HomeRecipeThumbnail({required this.item, this.size = 62});

  final RecommendationItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (item.thumbnailUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          item.thumbnailUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _thumbnailFallback(),
        ),
      );
    }
    return _thumbnailFallback();
  }

  Widget _thumbnailFallback() => SizedBox(
    width: size,
    height: size,
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
