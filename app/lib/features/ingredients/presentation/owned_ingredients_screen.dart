import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../shared/presentation/widgets/main_bottom_navigation.dart';
import '../../ingredient/presentation/ingredient_ui_item.dart';
import '../../ingredient/presentation/widgets/ingredient_thumbnail.dart';

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
          .getIngredientOptions();
      final ownedResponse = await widget.apiClient
          .getOwnedIngredientApi()
          .getOwnedIngredients();
      final ingredientData = ingredientResponse.data;
      final ownedData = ownedResponse.data;
      if (ingredientData == null || ownedData == null) {
        throw StateError('The ingredient response body is empty.');
      }
      final ownedById = {
        for (final item in ownedData.items) item.ingredientId: item,
      };
      final ingredients = ingredientData.items
          .map(
            (item) => IngredientUiItem(
              ingredientId: item.ingredientId,
              displayName: item.displayName,
              userIngredientId: ownedById[item.ingredientId]?.userIngredientId,
            ),
          )
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _ingredients = ingredients;
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
            .addOwnedIngredients(
              addOwnedIngredientsRequest: AddOwnedIngredientsRequest(
                (builder) => builder.items.add(
                  OwnedIngredientSelection(
                    (builder) => builder.ingredientId = ingredient.ingredientId,
                  ),
                ),
              ),
            );
        final data = response.data;
        if (data == null) {
          throw StateError('The owned ingredient response body is empty.');
        }
        final saved = data.items.firstWhere(
          (item) => item.ingredientId == ingredient.ingredientId,
        );
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

  @override
  Widget build(BuildContext context) {
    final owned = _ingredients
        .where((ingredient) => ingredient.isOwned)
        .toList(growable: false);
    final available = _ingredients
        .where((ingredient) => !ingredient.isOwned)
        .toList(growable: false);
    final normalizedQuery = _query.trim();
    final searchResults = normalizedQuery.isEmpty
        ? const <IngredientUiItem>[]
        : _ingredients
              .where(
                (ingredient) =>
                    ingredient.displayName.contains(normalizedQuery),
              )
              .toList(growable: false);

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
                      '현재 가지고 있는 재료예요',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 24,
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '여기 있는 재료로 메뉴를 찾아봐요',
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
                      _LoadError(
                        message: _loadError!,
                        onRetry: _loadIngredients,
                      )
                    else if (normalizedQuery.isNotEmpty)
                      _SearchResults(
                        query: normalizedQuery,
                        ingredients: searchResults,
                        pendingIngredientIds: _pendingIngredientIds,
                        onToggle: _toggleIngredient,
                      )
                    else if (owned.isEmpty)
                      _EmptyIngredients(
                        onRegister:
                            widget.onRegisterIngredients ??
                            () => _searchFocusNode.requestFocus(),
                      )
                    else ...[
                      _IngredientSection(
                        title: '보유 중 ${owned.length}개',
                        ingredients: owned,
                        pendingIngredientIds: _pendingIngredientIds,
                        onToggle: _toggleIngredient,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE5E5EA),
                        ),
                      ),
                      _IngredientSection(
                        title: '재료 더 담기 ${available.length}개',
                        ingredients: available,
                        pendingIngredientIds: _pendingIngredientIds,
                        onToggle: _toggleIngredient,
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
          hintText: '재료 추가하기',
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

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.ingredients,
    required this.pendingIngredientIds,
    required this.onToggle,
  });

  final String query;
  final List<IngredientUiItem> ingredients;
  final Set<int> pendingIngredientIds;
  final ValueChanged<IngredientUiItem> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IngredientSection(
          title: "'$query' 검색 결과 ${ingredients.length}개",
          ingredients: ingredients,
          pendingIngredientIds: pendingIngredientIds,
          onToggle: onToggle,
          emptyMessage: '검색 결과가 없어요',
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 19,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '체크하면 바로 담기고, 체크를 풀면 삭제돼요',
                  style: TextStyle(
                    color: Color(0xFF636366),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientSection extends StatelessWidget {
  const _IngredientSection({
    required this.title,
    required this.ingredients,
    required this.pendingIngredientIds,
    required this.onToggle,
    this.emptyMessage,
  });

  final String title;
  final List<IngredientUiItem> ingredients;
  final Set<int> pendingIngredientIds;
  final ValueChanged<IngredientUiItem> onToggle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        if (ingredients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Text(
              emptyMessage ?? '등록된 재료가 없어요',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final itemWidth = (constraints.maxWidth - gap) / 2;

              return Wrap(
                spacing: gap,
                runSpacing: 4,
                children: [
                  for (final ingredient in ingredients)
                    SizedBox(
                      width: itemWidth,
                      height: 56,
                      child: _IngredientTile(
                        ingredient: ingredient,
                        isPending: pendingIngredientIds.contains(
                          ingredient.ingredientId,
                        ),
                        onToggle: () => onToggle(ingredient),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.ingredient,
    required this.isPending,
    required this.onToggle,
  });

  final IngredientUiItem ingredient;
  final bool isPending;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: ingredient.isOwned,
      button: true,
      label: ingredient.displayName,
      child: InkWell(
        onTap: isPending ? null : onToggle,
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: ingredient.isOwned ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: ingredient.isOwned
                      ? AppColors.primary
                      : const Color(0xFFD1D1D6),
                ),
              ),
              child: isPending
                  ? const Padding(
                      padding: EdgeInsets.all(4),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ingredient.isOwned
                  ? const Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            IngredientThumbnail(
              displayName: ingredient.displayName,
              assetPath: ingredient.assetPath,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ingredient.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _EmptyIngredients extends StatelessWidget {
  const _EmptyIngredients({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.kitchen_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '등록된 재료가 없어요',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '재료를 등록하면 만들 수 있는 메뉴를\n찾아드릴게요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(126, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            child: const Text('재료 등록하기'),
          ),
        ],
      ),
    );
  }
}
