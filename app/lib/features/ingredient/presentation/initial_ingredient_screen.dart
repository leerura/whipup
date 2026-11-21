import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import 'ingredient_ui_item.dart';
import 'ingredient_registration_complete_sheet.dart';
import 'widgets/ingredient_chip.dart';
import 'widgets/ingredient_group_selector.dart';
import 'widgets/ingredient_search_field.dart';
import 'widgets/ingredient_thumbnail.dart';
import 'ingredient_presentation_catalog.dart';

class InitialIngredientScreen extends StatefulWidget {
  const InitialIngredientScreen({
    required this.apiClient,
    this.onSubmit,
    this.onViewRecommendations,
    this.onBatchSubmit,
    this.allowEmptySubmit = false,
    super.key,
  });

  final ApiClient apiClient;
  final ValueChanged<Set<String>>? onSubmit;
  final VoidCallback? onViewRecommendations;
  final Future<void> Function(Set<int> variantIds)? onBatchSubmit;
  final bool allowEmptySubmit;

  @override
  State<InitialIngredientScreen> createState() =>
      _InitialIngredientScreenState();
}

class _InitialIngredientScreenState extends State<InitialIngredientScreen> {
  static const _presetNames = {
    '진간장',
    '계란',
    '고추장',
    '밥',
    '물',
    '식용유',
    '참기름',
    '참깨',
    '양파',
    '대파',
    '김치',
    '다진 마늘',
    '소금',
    '설탕',
  };

  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedIds = {};
  final Set<int> _savedVariantIds = {};
  List<IngredientGroup> _groups = const [];
  List<IngredientUiItem> _ingredients = const [];
  String _query = '';
  String? _loadError;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<IngredientUiItem> get _selectedIngredients => _ingredients
      .where((ingredient) => _selectedIds.contains(ingredient.ingredientId))
      .toList(growable: false);

  List<IngredientUiItem> get _presetIngredients => _ingredients
      .where((ingredient) => _presetNames.contains(ingredient.displayName))
      .toList(growable: false);

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
          .getIngredientGroups();
      final data = response.data;
      if (data == null) {
        throw StateError('The ingredient response body is empty.');
      }

      final ingredients = data.groups
          .expand((group) => group.items)
          .map(
            (item) => IngredientUiItem(
              ingredientId: item.variantId,
              displayName: item.name,
            ),
          )
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _ingredients = ingredients;
        _groups = data.groups.toList(growable: false);
        if (widget.onBatchSubmit != null) {
          _selectedIds.addAll(
            ingredients
                .where(
                  (ingredient) => _presetNames.contains(ingredient.displayName),
                )
                .map((ingredient) => ingredient.ingredientId),
          );
        }
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
    if (_isSubmitting) return;
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(_savedVariantIds)
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
    if (_isSubmitting || _savedVariantIds.contains(id)) return;
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

  Future<RecommendationListResponse?> _loadRecommendationPreview() async {
    try {
      final response = await widget.apiClient
          .getRecommendationApi()
          .getRecipeRecommendations(mode: RecommendationMode.AVAILABLE);
      return response.data;
    } catch (error) {
      debugPrint('Recommendation preview loading failed: $error');
      return null;
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting || (!widget.allowEmptySubmit && _selectedIds.isEmpty)) {
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final selectedIds = Set<int>.of(_selectedIds);
      if (widget.onBatchSubmit != null) {
        await widget.onBatchSubmit!(selectedIds);
      } else {
        for (final id in selectedIds) {
          if (_savedVariantIds.contains(id)) continue;
          final response = await widget.apiClient
              .getOwnedIngredientApi()
              .addOwnedIngredient(
                addOwnedIngredientRequest: AddOwnedIngredientRequest(
                  (builder) => builder.variantId = id,
                ),
              );
          if (response.data == null) {
            throw StateError('The owned ingredient response body is empty.');
          }
          _savedVariantIds.add(id);
        }
      }

      if (widget.onBatchSubmit != null) {
        final selectedLabels = Set<String>.unmodifiable(_selectedLabels);
        widget.onSubmit?.call(selectedLabels);
        widget.onViewRecommendations?.call();
        return;
      }

      final recommendationList = await _loadRecommendationPreview();
      final selectedLabels = Set<String>.unmodifiable(_selectedLabels);
      if (!mounted) return;
      widget.onSubmit?.call(selectedLabels);
      if (!mounted) return;

      final shouldViewRecommendations = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: const Color(0x6B1C1C1E),
        builder: (sheetContext) => IngredientRegistrationCompleteSheet(
          ingredientCount: selectedLabels.length,
          recommendationList: recommendationList,
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
        SnackBar(
          content: Text(
            _savedVariantIds.isEmpty
                ? '재료를 등록하지 못했어요. 다시 시도해주세요.'
                : '${_savedVariantIds.length}개는 등록됐어요. 다시 시도하면 나머지 재료를 등록해요.',
          ),
        ),
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
    final showFullCatalog = widget.onBatchSubmit == null;

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
                widget.onBatchSubmit != null
                    ? '집에 있을 만한 재료를\n모아봤어요'
                    : '냉장고에 있는\n재료를 골라주세요',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: widget.onBatchSubmit != null ? 20 : 24,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.onBatchSubmit != null
                    ? '아닌 건 눌러서 빼주세요.\n나머지는 레시피를 보면서 담으면 돼요.'
                    : '하나 이상 고르면 추천이 시작돼요',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (showFullCatalog)
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
                    if (_selectedIds.isNotEmpty && showFullCatalog) ...[
                      _SelectedIngredientSummary(
                        ingredients: _selectedIngredients,
                        onRemove: (id) => _setIngredientSelected(id, false),
                      ),
                      if (!hasQuery) const SizedBox(height: 16),
                    ],
                    if (!hasQuery && !showFullCatalog)
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
              if (!_isLoading && _loadError == null && showFullCatalog) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasQuery
                            ? '검색 결과'
                            : widget.onBatchSubmit != null
                            ? '직접 고르기'
                            : '전체 재료',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    if (widget.onBatchSubmit != null && !hasQuery)
                      TextButton(
                        onPressed: _selectPreset,
                        child: const Text('추천 재료 선택'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                IngredientGroupSelector(
                  groups: _groups,
                  query: _query,
                  selectedVariantIds: _selectedIds,
                  pendingVariantIds: _isSubmitting
                      ? _ingredients.map((item) => item.ingredientId).toSet()
                      : const <int>{},
                  onToggle: (id) =>
                      _setIngredientSelected(id, !_selectedIds.contains(id)),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed:
                          (!widget.allowEmptySubmit && selectedCount == 0) ||
                              _isLoading ||
                              _isSubmitting
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
                            : selectedCount == 0 && widget.allowEmptySubmit
                            ? '재료 없이 둘러보기'
                            : selectedCount == 0
                            ? '재료를 골라주세요'
                            : widget.onBatchSubmit != null
                            ? (_presetIngredients.isNotEmpty &&
                                      _selectedIds.length ==
                                          _presetIngredients.length &&
                                      _presetIngredients.every(
                                        (item) => _selectedIds.contains(
                                          item.ingredientId,
                                        ),
                                      )
                                  ? '이대로 시작하기'
                                  : '$selectedCount개로 시작하기')
                            : '선택한 재료 $selectedCount개 등록하기',
                      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '자주 쓰는 재료',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${selectedIds.length}개 담김',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < ingredients.length; index += 2)
          Row(
            children: [
              for (final ingredient in ingredients.skip(index).take(2))
                Expanded(
                  child: _QuickIngredientRow(
                    ingredient: ingredient,
                    selected: selectedIds.contains(ingredient.ingredientId),
                    onTap: () => onChanged(
                      ingredient.ingredientId,
                      !selectedIds.contains(ingredient.ingredientId),
                    ),
                  ),
                ),
              if (index + 1 >= ingredients.length)
                const Expanded(child: SizedBox()),
            ],
          ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '지금 다 고르지 않아도 돼요. 나머지는 재료함이나 레시피에서 언제든 담을 수 있어요.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickIngredientRow extends StatelessWidget {
  const _QuickIngredientRow({
    required this.ingredient,
    required this.selected,
    required this.onTap,
  });
  final IngredientUiItem ingredient;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 44,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFD1D1D6),
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          IngredientThumbnail(
            displayName: ingredient.displayName,
            assetPath: ingredientAssetPathFor(ingredient.displayName),
            size: 30,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ingredient.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
