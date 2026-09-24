import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';
import 'ingredient_ui_item.dart';
import 'ingredient_registration_complete_sheet.dart';
import 'widgets/ingredient_chip.dart';
import 'widgets/ingredient_row.dart';
import 'widgets/ingredient_search_field.dart';

class InitialIngredientScreen extends StatefulWidget {
  const InitialIngredientScreen({
    required this.apiClient,
    this.onSubmit,
    this.onViewRecommendations,
    super.key,
  });

  final ApiClient apiClient;
  final ValueChanged<Set<String>>? onSubmit;
  final VoidCallback? onViewRecommendations;

  @override
  State<InitialIngredientScreen> createState() =>
      _InitialIngredientScreenState();
}

class _InitialIngredientScreenState extends State<InitialIngredientScreen> {
  static const _presetNames = {'계란', '대파', '고추장', '김치', '양파', '마늘', '밥', '간장'};

  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedIds = {};
  List<IngredientUiItem> _ingredients = const [];
  String _query = '';
  String? _loadError;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<IngredientUiItem> get _visibleIngredients {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _ingredients;

    return _ingredients
        .where(
          (ingredient) =>
              ingredient.displayName.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  List<IngredientUiItem> get _selectedIngredients => _ingredients
      .where((ingredient) => _selectedIds.contains(ingredient.ingredientId))
      .toList(growable: false);

  List<IngredientUiItem> get _presetIngredients {
    final ingredientsByName = {
      for (final ingredient in _ingredients) ingredient.displayName: ingredient,
    };

    return _presetNames
        .map((name) => ingredientsByName[name])
        .whereType<IngredientUiItem>()
        .toList(growable: false);
  }

  Set<String> get _selectedLabels =>
      _selectedIngredients.map((ingredient) => ingredient.displayName).toSet();

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final response = await widget.apiClient
          .getIngredientApi()
          .getIngredientOptions();
      final data = response.data;
      if (data == null) {
        throw StateError('The ingredient response body is empty.');
      }

      final ingredients = data.items
          .map(
            (item) => IngredientUiItem(
              ingredientId: item.ingredientId,
              displayName: item.displayName,
            ),
          )
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _ingredients = ingredients;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Ingredient loading failed: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = '재료 목록을 불러오지 못했어요.';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectPreset() {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(
          _ingredients
              .where(
                (ingredient) => _presetNames.contains(ingredient.displayName),
              )
              .map((ingredient) => ingredient.ingredientId),
        );
    });
  }

  void _setIngredientSelected(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _setSuggestedIngredient(int id, bool selected) {
    _searchController.clear();
    setState(() {
      _query = '';
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  Future<RecommendationPage?> _loadRecommendationPreview() async {
    try {
      final response = await widget.apiClient
          .getRecommendationApi()
          .getRecommendations(missingCount: 0, page: 0, size: 5);
      return response.data;
    } catch (error) {
      debugPrint('Recommendation preview loading failed: $error');
      return null;
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting || _selectedIds.isEmpty) return;
    setState(() => _isSubmitting = true);

    try {
      final request = AddOwnedIngredientsRequest(
        (builder) => builder.items.addAll(
          _selectedIds.map(
            (id) => OwnedIngredientSelection(
              (builder) => builder.ingredientId = id,
            ),
          ),
        ),
      );
      final response = await widget.apiClient
          .getOwnedIngredientApi()
          .addOwnedIngredients(addOwnedIngredientsRequest: request);
      if (response.data == null) {
        throw StateError('The owned ingredient response body is empty.');
      }

      final recommendationPage = await _loadRecommendationPreview();
      final selectedLabels = Set<String>.unmodifiable(_selectedLabels);
      widget.onSubmit?.call(selectedLabels);
      if (!mounted) return;

      final shouldViewRecommendations = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: const Color(0x6B1C1C1E),
        builder: (sheetContext) => IngredientRegistrationCompleteSheet(
          ingredientCount: selectedLabels.length,
          recommendationPage: recommendationPage,
          onViewRecommendations: () => Navigator.of(sheetContext).pop(true),
        ),
      );

      if (!mounted) return;
      if (shouldViewRecommendations == true) {
        widget.onViewRecommendations?.call();
      }
    } catch (error) {
      debugPrint('Ingredient registration failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재료를 등록하지 못했어요. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedIds.length;
    final hasQuery = _query.trim().isNotEmpty;
    final hasNoSearchResults = hasQuery && _visibleIngredients.isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Text(
                '냉장고에 있는\n재료를 골라주세요',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '하나 이상 고르면 추천이 시작돼요',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              IngredientSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                onClear: hasQuery ? _clearSearch : null,
              ),
              const SizedBox(height: 16),
              if (_isLoading) ...[
                const SizedBox(height: 48),
                const Center(child: CircularProgressIndicator()),
              ] else if (_loadError != null) ...[
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Text(
                        _loadError!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadIngredients,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ] else if (_selectedIds.isNotEmpty || !hasQuery)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedIds.isNotEmpty) ...[
                      _SelectedIngredientSummary(
                        ingredients: _selectedIngredients,
                        onRemove: (id) => _setIngredientSelected(id, false),
                      ),
                      if (!hasQuery) const SizedBox(height: 16),
                    ],
                    if (!hasQuery)
                      _PresetCard(
                        ingredients: _presetIngredients,
                        selectedIds: _selectedIds,
                        onChanged: _setIngredientSelected,
                        onSelectAll: _selectPreset,
                      ),
                  ],
                )
              else
                const SizedBox.shrink(),
              if (!_isLoading && _loadError == null && hasNoSearchResults) ...[
                const SizedBox(height: 48),
                _SearchEmptyState(
                  query: _query.trim(),
                  suggestions: _ingredients
                      .where(
                        (ingredient) => const {
                          '삼겹살',
                          '우삼겹',
                        }.contains(ingredient.displayName),
                      )
                      .toList(growable: false),
                  selectedIds: _selectedIds,
                  onChanged: _setSuggestedIngredient,
                ),
              ] else if (!_isLoading && _loadError == null) ...[
                const SizedBox(height: 24),
                SvgPicture.asset(
                  'assets/ingredient/divider.svg',
                  width: double.infinity,
                  height: 1,
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 24),
                Text(
                  hasQuery
                      ? '검색 결과'
                      : _selectedIds.isEmpty
                      ? '또는 직접 고르기'
                      : '전체 재료',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 10) / 2;

                    return Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        for (final ingredient in _visibleIngredients)
                          SizedBox(
                            width: itemWidth,
                            child: IngredientRow(
                              label: ingredient.displayName,
                              assetPath: ingredient.assetPath,
                              selected: _selectedIds.contains(
                                ingredient.ingredientId,
                              ),
                              onChanged: (selected) => _setIngredientSelected(
                                ingredient.ingredientId,
                                selected,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: ColoredBox(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: selectedCount == 0 || _isLoading || _isSubmitting
                      ? null
                      : _submit,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.disabled,
                    foregroundColor: AppColors.white,
                    disabledForegroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isSubmitting
                        ? '등록 중...'
                        : selectedCount == 0
                        ? '재료를 골라주세요'
                        : '선택한 재료 $selectedCount개 등록하기',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.ingredients,
    required this.selectedIds,
    required this.onChanged,
    required this.onSelectAll,
  });

  final List<IngredientUiItem> ingredients;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onChanged;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('자주 쓰는 재료 8개', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              '한 번에 담고 바로 추천받기',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final ingredient in ingredients)
                  IngredientChip(
                    label: ingredient.displayName,
                    selected: selectedIds.contains(ingredient.ingredientId),
                    onSelectedChanged: (selected) =>
                        onChanged(ingredient.ingredientId, selected),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onSelectAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: Color(0xFFAEAEB2)),
                  shape: const StadiumBorder(),
                ),
                child: const Text('한 번에 담기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedIngredientSummary extends StatelessWidget {
  const _SelectedIngredientSummary({
    required this.ingredients,
    required this.onRemove,
  });

  final List<IngredientUiItem> ingredients;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선택한 재료 ${ingredients.length}개',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ingredient in ingredients)
              IngredientChip(
                label: ingredient.displayName,
                onRemoved: () => onRemove(ingredient.ingredientId),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.query,
    required this.suggestions,
    required this.selectedIds,
    required this.onChanged,
  });

  final String query;
  final List<IngredientUiItem> suggestions;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/ingredient/search_empty.svg',
          width: 66,
          height: 66,
          semanticsLabel: '검색 결과 없음',
        ),
        const SizedBox(height: 12),
        Text(
          '‘$query’ 검색 결과가 없어요',
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '등록된 재료 중에서만 고를 수 있어요',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xFFAEAEB2)),
          textAlign: TextAlign.center,
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 52),
          SvgPicture.asset(
            'assets/ingredient/divider.svg',
            width: double.infinity,
            height: 1,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '혹시 이걸 찾으셨나요?',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: 4),
          for (final ingredient in suggestions)
            IngredientRow(
              label: ingredient.displayName,
              assetPath: ingredient.assetPath,
              selected: selectedIds.contains(ingredient.ingredientId),
              onChanged: (selected) =>
                  onChanged(ingredient.ingredientId, selected),
            ),
        ],
      ],
    );
  }
}
