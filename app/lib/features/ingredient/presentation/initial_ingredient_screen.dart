import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';
import 'ingredient_registration_complete_sheet.dart';
import 'widgets/ingredient_chip.dart';
import 'widgets/ingredient_row.dart';
import 'widgets/ingredient_search_field.dart';

class InitialIngredientScreen extends StatefulWidget {
  const InitialIngredientScreen({
    this.onSubmit,
    this.onViewRecommendations,
    super.key,
  });

  final ValueChanged<Set<String>>? onSubmit;
  final VoidCallback? onViewRecommendations;

  @override
  State<InitialIngredientScreen> createState() =>
      _InitialIngredientScreenState();
}

class _InitialIngredientScreenState extends State<InitialIngredientScreen> {
  static const _presetIds = [
    'egg',
    'green-onion',
    'gochujang',
    'kimchi',
    'onion',
    'tofu',
    'rice',
    'soy-sauce',
  ];

  static const _ingredients = [
    _IngredientOption('egg', '계란', 'assets/ingredient/egg.svg'),
    _IngredientOption(
      'green-onion',
      '대파',
      'assets/ingredient/green_onion.svg',
    ),
    _IngredientOption(
      'gochujang',
      '고추장',
      'assets/ingredient/gochujang.svg',
    ),
    _IngredientOption('kimchi', '김치', 'assets/ingredient/kimchi.svg'),
    _IngredientOption('onion', '양파', 'assets/ingredient/onion.svg'),
    _IngredientOption('tofu', '두부', 'assets/ingredient/tofu.svg'),
    _IngredientOption('pork', '삼겹살', 'assets/ingredient/pork.svg'),
    _IngredientOption('rice', '밥', 'assets/ingredient/rice.svg'),
    _IngredientOption(
      'soy-sauce',
      '간장',
      'assets/ingredient/soy_sauce.svg',
    ),
    _IngredientOption('cheese', '치즈', 'assets/ingredient/cheese.svg'),
    _IngredientOption('milk', '우유', 'assets/ingredient/milk.svg'),
    _IngredientOption('garlic', '마늘', 'assets/ingredient/garlic.svg'),
    _IngredientOption('pasta', '파스타면', 'assets/ingredient/pasta.svg'),
    _IngredientOption(
      'beef-belly',
      '우삼겹',
      'assets/ingredient/beef_belly.svg',
    ),
  ];

  static const _previewIngredients = [
    _IngredientOption('pork', '삼겹살', 'assets/ingredient/pork.svg'),
    _IngredientOption('cheese', '치즈', 'assets/ingredient/cheese.svg'),
    _IngredientOption('milk', '우유', 'assets/ingredient/milk.svg'),
    _IngredientOption('pasta', '파스타면', 'assets/ingredient/pasta.svg'),
    _IngredientOption('pork', '삼겹살', 'assets/ingredient/pork.svg'),
    _IngredientOption('cheese', '치즈', 'assets/ingredient/cheese.svg'),
    _IngredientOption('milk', '우유', 'assets/ingredient/milk.svg'),
    _IngredientOption('pasta', '파스타면', 'assets/ingredient/pasta.svg'),
  ];

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _query = '';

  List<_IngredientOption> get _visibleIngredients {
    final normalizedQuery = _query.trim().toLowerCase();
    final source = normalizedQuery.isEmpty && _selectedIds.isEmpty
        ? _previewIngredients
        : _ingredients;
    if (normalizedQuery.isEmpty) return source;

    return source
        .where(
          (ingredient) => ingredient.label.toLowerCase().contains(
            normalizedQuery,
          ),
        )
        .toList();
  }

  List<_IngredientOption> get _selectedIngredients => _ingredients
      .where((ingredient) => _selectedIds.contains(ingredient.id))
      .toList();

  Set<String> get _selectedLabels => _selectedIngredients
      .map((ingredient) => ingredient.label)
      .toSet();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectPreset() {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(_presetIds);
    });
  }

  void _setIngredientSelected(String id, bool selected) {
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

  void _setSuggestedIngredient(String id, bool selected) {
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

  Future<void> _submit() async {
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
        availableMenuCount: 5,
        onViewRecommendations: () => Navigator.of(sheetContext).pop(true),
      ),
    );

    if (!mounted) return;
    if (shouldViewRecommendations == true) {
      widget.onViewRecommendations?.call();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (_selectedIds.isNotEmpty)
                  _SelectedIngredientSummary(
                    ingredients: _selectedIngredients,
                    onRemove: (id) => _setIngredientSelected(id, false),
                  )
                else if (!hasQuery)
                  _PresetCard(onSelect: _selectPreset)
                else
                  const SizedBox.shrink(),
                if (hasNoSearchResults) ...[
                  const SizedBox(height: 48),
                  _SearchEmptyState(
                    query: _query.trim(),
                    porkSelected: _selectedIds.contains('pork'),
                    beefBellySelected: _selectedIds.contains('beef-belly'),
                    onChanged: _setSuggestedIngredient,
                  ),
                ] else ...[
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
                                label: ingredient.label,
                                assetPath: ingredient.assetPath,
                                selected: _selectedIds.contains(ingredient.id),
                                onChanged: (selected) =>
                                    _setIngredientSelected(
                                      ingredient.id,
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
                  onPressed: selectedCount == 0 ? null : _submit,
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
                    selectedCount == 0
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
  const _PresetCard({required this.onSelect});

  final VoidCallback onSelect;

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
            Text(
              '자주 쓰는 재료 8개',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '한 번에 담고 바로 추천받기',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                IngredientChip(label: '계란'),
                IngredientChip(label: '대파'),
                IngredientChip(label: '고추장'),
                IngredientChip(label: '김치'),
                IngredientChip(label: '양파'),
                IngredientChip(label: '두부'),
                IngredientChip(label: '밥'),
                IngredientChip(label: '간장'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onSelect,
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

  final List<_IngredientOption> ingredients;
  final ValueChanged<String> onRemove;

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
                label: ingredient.label,
                onRemoved: () => onRemove(ingredient.id),
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
    required this.porkSelected,
    required this.beefBellySelected,
    required this.onChanged,
  });

  final String query;
  final bool porkSelected;
  final bool beefBellySelected;
  final void Function(String id, bool selected) onChanged;

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
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '등록된 재료 중에서만 고를 수 있어요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFAEAEB2),
          ),
          textAlign: TextAlign.center,
        ),
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
        IngredientRow(
          label: '삼겹살',
          assetPath: 'assets/ingredient/pork.svg',
          selected: porkSelected,
          onChanged: (selected) => onChanged('pork', selected),
        ),
        IngredientRow(
          label: '우삼겹',
          assetPath: 'assets/ingredient/beef_belly.svg',
          selected: beefBellySelected,
          onChanged: (selected) => onChanged('beef-belly', selected),
        ),
      ],
    );
  }
}

class _IngredientOption {
  const _IngredientOption(this.id, this.label, this.assetPath);

  final String id;
  final String label;
  final String assetPath;
}
