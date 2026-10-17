import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../shared/presentation/widgets/main_bottom_navigation.dart';
import '../../ingredient/presentation/ingredient_ui_item.dart';
import '../../ingredient/presentation/widgets/ingredient_group_selector.dart';

class OwnedIngredientsScreen extends StatefulWidget {
  const OwnedIngredientsScreen({
    required this.apiClient,
    this.onRegisterIngredients,
    this.onOwnedIngredientsChanged,
    this.onRecommendationsSelected,
    super.key,
  });

  final ApiClient apiClient;
  final VoidCallback? onRegisterIngredients;
  final ValueChanged<Set<String>>? onOwnedIngredientsChanged;
  final VoidCallback? onRecommendationsSelected;

  @override
  State<OwnedIngredientsScreen> createState() => _OwnedIngredientsScreenState();
}

class _OwnedIngredientsScreenState extends State<OwnedIngredientsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final Set<int> _pendingIngredientIds = {};

  List<IngredientUiItem> _ingredients = const [];
  List<IngredientGroup> _groups = const [];
  String _query = '';
  String? _loadError;
  bool _isLoading = true;

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
      final ingredientResponse = await widget.apiClient
          .getIngredientApi()
          .getIngredientGroups();
      final ownedResponse = await widget.apiClient
          .getOwnedIngredientApi()
          .getOwnedIngredients();
      final ingredientData = ingredientResponse.data;
      final ownedData = ownedResponse.data;
      if (ingredientData == null || ownedData == null) {
        throw StateError('The ingredient response body is empty.');
      }
      final ownedById = {
        for (final item in ownedData.items) item.variantId: item,
      };
      final ingredients = ingredientData.groups.expand((group) => group.items)
          .map(
            (item) => IngredientUiItem(
              ingredientId: item.variantId,
              displayName: item.name,
              userIngredientId: ownedById[item.variantId]?.userIngredientId,
            ),
          )
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _ingredients = ingredients;
        _groups = ingredientData.groups.toList(growable: false);
        _isLoading = false;
      });
      _notifyOwnedIngredientsChanged();
    } catch (error) {
      debugPrint('Owned ingredient loading failed: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = '보유 재료를 불러오지 못했어요.';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _toggleIngredient(IngredientUiItem ingredient) async {
    if (_pendingIngredientIds.contains(ingredient.ingredientId)) return;
    setState(() => _pendingIngredientIds.add(ingredient.ingredientId));
    try {
      if (ingredient.isOwned) {
        await widget.apiClient.getOwnedIngredientApi().deleteOwnedIngredient(
          userIngredientId: ingredient.userIngredientId!,
        );
        _replaceIngredient(ingredient.copyWith(clearUserIngredientId: true));
      } else {
        final response = await widget.apiClient
            .getOwnedIngredientApi()
            .addOwnedIngredient(
              addOwnedIngredientRequest: AddOwnedIngredientRequest(
                (builder) => builder.variantId = ingredient.ingredientId,
              ),
            );
        final data = response.data;
        if (data == null) {
          throw StateError('The owned ingredient response body is empty.');
        }
        final saved = data;
        _replaceIngredient(
          ingredient.copyWith(userIngredientId: saved.userIngredientId),
        );
      }
      _notifyOwnedIngredientsChanged();
    } catch (error) {
      debugPrint('Owned ingredient update failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보유 재료를 변경하지 못했어요. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingIngredientIds.remove(ingredient.ingredientId));
      }
    }
  }

  void _replaceIngredient(IngredientUiItem replacement) {
    if (!mounted) return;
    setState(() {
      _ingredients = _ingredients
          .map(
            (item) => item.ingredientId == replacement.ingredientId
                ? replacement
                : item,
          )
          .toList(growable: false);
    });
  }

  void _notifyOwnedIngredientsChanged() {
    widget.onOwnedIngredientsChanged?.call(
      Set<String>.unmodifiable(
        _ingredients
            .where((item) => item.isOwned)
            .map((item) => item.displayName),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocusNode.requestFocus();
  }

  Widget _groupSelector(List<IngredientGroup> groups, {String query = ''}) {
    return IngredientGroupSelector(
      groups: groups,
      query: query,
      selectedVariantIds: _ingredients.where((item) => item.isOwned)
          .map((item) => item.ingredientId).toSet(),
      pendingVariantIds: _pendingIngredientIds,
      onToggle: (id) => _toggleIngredient(
        _ingredients.firstWhere((item) => item.ingredientId == id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final owned = _ingredients
        .where((ingredient) => ingredient.isOwned)
        .toList(growable: false);
    final available = _ingredients
        .where((ingredient) => !ingredient.isOwned)
        .toList(growable: false);
    final normalizedQuery = _query.trim();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: MainBottomNavigation(
          selectedTab: MainTab.ingredients,
          onRecommendationsSelected: widget.onRecommendationsSelected,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _ScreenHeader(),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  children: [
                    Text(
                      owned.isEmpty ? '재료를 골라 담아보세요' : '현재 가지고 있는 재료예요',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 24,
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      owned.isEmpty
                          ? '가지고 있는 형태를 그대로 선택하면 돼요'
                          : '여기 있는 재료로 메뉴를 찾아봐요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF636366),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _IngredientSearchField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      query: _query,
                      onChanged: (value) => setState(() => _query = value),
                      onClear: _clearSearch,
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 64),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(children: [
                          Text(_loadError!, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          TextButton(onPressed: _loadIngredients, child: const Text('다시 시도')),
                        ]),
                      )
                    else if (normalizedQuery.isNotEmpty)
                      _groupSelector(_groups, query: normalizedQuery)
                    else if (owned.isEmpty)
                      _groupSelector(_groups)
                    else ...[
                      Text('보유 중 ${owned.length}개'),
                      const SizedBox(height: 14),
                      _groupSelector(_groups.where((group) => group.items.any(
                        (variant) => owned.any((item) => item.ingredientId == variant.variantId),
                      )).toList()),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE5E5EA),
                        ),
                      ),
                      if (available.isNotEmpty) ...[
                        const Text('재료 더 담기'),
                        const SizedBox(height: 14),
                        _groupSelector(_groups.where((group) => group.items.any(
                          (variant) => available.any((item) => item.ingredientId == variant.variantId),
                        )).toList()),
                      ],
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

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Text(
              'whippy',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              tooltip: '알림',
              icon: const Icon(Icons.notifications_none_rounded),
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFFFE9DF),
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientSearchField extends StatelessWidget {
  const _IngredientSearchField({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: '재료명을 검색하세요',
          hintStyle: const TextStyle(
            color: Color(0xFFADA39E),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8E8E93),
            size: 22,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  tooltip: '검색어 지우기',
                  icon: const Icon(Icons.cancel_rounded, size: 20),
                  color: const Color(0xFFAEAEB2),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8D8C7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
