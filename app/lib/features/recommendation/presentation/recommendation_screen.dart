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
  RecommendationMode _selectedMode = RecommendationMode.AVAILABLE;
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
          .getRecipeRecommendations(mode: _selectedMode);
      final data = response.data;
      if (data == null) {
        throw StateError('The recommendation response body is empty.');
      }
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _items = data.items.toList(growable: false);
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
                      selectedMode: _selectedMode,
                      onChanged: (value) {
                        if (value == _selectedMode) return;
                        setState(() => _selectedMode = value);
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
                        mode: _selectedMode,
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
    required this.selectedMode,
    required this.onChanged,
  });

  final RecommendationMode selectedMode;
  final ValueChanged<RecommendationMode> onChanged;

  static const _modes = [
    RecommendationMode.AVAILABLE,
    RecommendationMode.MISSING_INGREDIENTS,
  ];
  static const _labels = ['지금 있는 걸로', '재료 추가해서'];

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
          final isSelected = selectedMode == _modes[index];

          return Expanded(
            child: Semantics(
              selected: isSelected,
              button: true,
              child: Material(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => onChanged(_modes[index]),
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
    final copy = _RecommendationCopy.fromItem(item);

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
                child: _RecipeThumbnail(item: item),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      copy.primary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: item.missingCount > 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.6,
                        letterSpacing: 0,
                      ),
                    ),
                    for (final note in copy.secondary) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.6,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
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

class _RecommendationCopy {
  const _RecommendationCopy({required this.primary, this.secondary = const []});

  final String primary;
  final List<String> secondary;

  factory _RecommendationCopy.fromItem(RecommendationItem item) {
    final missing = <MissingRequirementResult>[];
    final matchNotes = <String>{};
    for (final result in item.requirementResults) {
      final value = result.oneOf.value;
      if (value is MissingRequirementResult) {
        missing.add(value);
      } else if (value is SatisfiedRequirementResult) {
        for (final match in value.matches) {
          if (match.type == IngredientMatchTypeEnum.PREPARATION) {
            matchNotes.add('${_withParticle(match.requiredName, '은', '는')} 가지고 있는 ${_withParticle(match.ownedName, '을', '를')} 활용할 수 있어요');
          } else if (match.type == IngredientMatchTypeEnum.SUBSTITUTE) {
            matchNotes.add('${_withParticle(match.requiredName, '은', '는')} 가지고 있는 ${_withParticle(match.ownedName, '으로', '로', rieulAsVowel: true)} 대신해도 돼요');
          }
        }
      }
    }

    if (item.missingCount > 1) {
      return _RecommendationCopy(
        primary: '재료 ${item.missingCount}개가 더 필요해요',
        secondary: matchNotes.take(1).toList(growable: false),
      );
    }
    if (item.missingCount == 1) {
      final options = missing.isEmpty
          ? const <MissingOption>[]
          : missing.first.missingOptions.toList(growable: false);
      final names = options.map((option) => option.requiredName).join(' 또는 ');
      final substituteNotes = <String>[
        for (final option in options)
          if (option.substitutes.isNotEmpty)
            '${_withParticle(option.requiredName, '은', '는')} ${_withParticle(option.substitutes.map((substitute) => substitute.name).join(' 또는 '), '으로', '로', rieulAsVowel: true)} 대신해도 돼요',
      ];
      return _RecommendationCopy(
        primary: options.isEmpty
            ? '재료 1개가 더 필요해요'
            : options.length > 1
                ? '$names 중 하나만 있으면 돼요'
                : options.single.substitutes.isEmpty
                    ? '$names만 있으면 돼요'
                    : '${_withParticle(names, '이', '가')} 필요해요',
        secondary: [...substituteNotes, ...matchNotes.take(1)],
      );
    }
    if (matchNotes.isEmpty) {
      return const _RecommendationCopy(primary: '지금 바로 만들 수 있어요');
    }
    return _RecommendationCopy(
      primary: matchNotes.first,
      secondary: matchNotes.skip(1).take(1).toList(growable: false),
    );
  }

  static String _withParticle(
    String text,
    String consonant,
    String vowel, {
    bool rieulAsVowel = false,
  }) {
    if (text.isEmpty) return text;
    final last = text.runes.last;
    if (last < 0xAC00 || last > 0xD7A3) return '$text($consonant/$vowel)';
    final finalConsonant = (last - 0xAC00) % 28;
    final useVowel = finalConsonant == 0 || (rieulAsVowel && finalConsonant == 8);
    return '$text${useVowel ? vowel : consonant}';
  }
}

class _EmptyRecommendations extends StatelessWidget {
  const _EmptyRecommendations({
    required this.mode,
    required this.onRegisterIngredients,
  });

  final RecommendationMode mode;
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
            mode == RecommendationMode.AVAILABLE
                ? '지금 만들 수 있는 메뉴가 없어요'
                : '재료를 추가해서 만들 메뉴가 없어요',
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
