import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';

class OwnedIngredientsScreen extends StatefulWidget {
  const OwnedIngredientsScreen({
    this.initialOwnedIngredients = const {
      '계란',
      '대파',
      '고추장',
      '김치',
      '삼겹살',
      '양파',
      '간장',
      '밥',
    },
    this.onOwnedIngredientsChanged,
    this.onRecommendationsSelected,
    super.key,
  });

  final Set<String> initialOwnedIngredients;
  final ValueChanged<Set<String>>? onOwnedIngredientsChanged;
  final VoidCallback? onRecommendationsSelected;

  @override
  State<OwnedIngredientsScreen> createState() =>
      _OwnedIngredientsScreenState();
}

class _OwnedIngredientsScreenState extends State<OwnedIngredientsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final Set<String> _ownedIngredients;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _ownedIngredients = {...widget.initialOwnedIngredients};
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleIngredient(String ingredientName) {
    setState(() {
      if (!_ownedIngredients.add(ingredientName)) {
        _ownedIngredients.remove(ingredientName);
      }
    });
    widget.onOwnedIngredientsChanged?.call(
      Set<String>.unmodifiable(_ownedIngredients),
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
        .where((ingredient) => _ownedIngredients.contains(ingredient.name))
        .toList();
    final available = _ingredients
        .where((ingredient) => !_ownedIngredients.contains(ingredient.name))
        .toList();
    final normalizedQuery = _query.trim();
    final searchResults = normalizedQuery.isEmpty
        ? const <_Ingredient>[]
        : _ingredients
              .where((ingredient) => ingredient.name.contains(normalizedQuery))
              .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: _IngredientsBottomNavigation(
          onRecommendationsSelected: widget.onRecommendationsSelected,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _ScreenHeader(),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      if (normalizedQuery.isNotEmpty)
                        _SearchResults(
                          query: normalizedQuery,
                          ingredients: searchResults,
                          ownedIngredients: _ownedIngredients,
                          onToggle: _toggleIngredient,
                        )
                      else if (owned.isEmpty)
                        _EmptyIngredients(
                          onRegister: () => _searchFocusNode.requestFocus(),
                        )
                      else ...[
                        _IngredientSection(
                          title: '보유 중 ${owned.length}개',
                          ingredients: owned,
                          ownedIngredients: _ownedIngredients,
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
                          ownedIngredients: _ownedIngredients,
                          onToggle: _toggleIngredient,
                        ),
                      ],
                    ],
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
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
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
    required this.ownedIngredients,
    required this.onToggle,
  });

  final String query;
  final List<_Ingredient> ingredients;
  final Set<String> ownedIngredients;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IngredientSection(
          title: "'$query' 검색 결과 ${ingredients.length}개",
          ingredients: ingredients,
          ownedIngredients: ownedIngredients,
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
    required this.ownedIngredients,
    required this.onToggle,
    this.emptyMessage,
  });

  final String title;
  final List<_Ingredient> ingredients;
  final Set<String> ownedIngredients;
  final ValueChanged<String> onToggle;
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
                        isOwned: ownedIngredients.contains(ingredient.name),
                        onToggle: () => onToggle(ingredient.name),
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
    required this.isOwned,
    required this.onToggle,
  });

  final _Ingredient ingredient;
  final bool isOwned;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: isOwned,
      button: true,
      label: ingredient.name,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isOwned ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isOwned
                      ? AppColors.primary
                      : const Color(0xFFD1D1D6),
                ),
              ),
              child: isOwned
                  ? const Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: ingredient.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ingredient.icon,
                size: 20,
                color: ingredient.iconColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ingredient.name,
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

class _IngredientsBottomNavigation extends StatelessWidget {
  const _IngredientsBottomNavigation({this.onRecommendationsSelected});

  final VoidCallback? onRecommendationsSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F2F7))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              const _NavigationItem(icon: Icons.home_outlined, label: '홈'),
              const _NavigationItem(
                icon: Icons.kitchen_rounded,
                label: '재료',
                isSelected: true,
              ),
              _NavigationItem(
                icon: Icons.menu_book_outlined,
                label: '레시피',
                onTap: onRecommendationsSelected,
              ),
              const _NavigationItem(
                icon: Icons.person_outline_rounded,
                label: '마이',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : const Color(0xFF8E8E93);

    return Expanded(
      child: Semantics(
        button: onTap != null,
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ingredient {
  const _Ingredient({
    required this.name,
    required this.icon,
    required this.color,
    this.iconColor = const Color(0xFF636366),
  });

  final String name;
  final IconData icon;
  final Color color;
  final Color iconColor;
}

const _ingredients = <_Ingredient>[
  _Ingredient(
    name: '계란',
    icon: Icons.egg_alt_rounded,
    color: Color(0xFFFFF2BE),
    iconColor: Color(0xFFD99B00),
  ),
  _Ingredient(
    name: '대파',
    icon: Icons.grass_rounded,
    color: Color(0xFFE6F3D9),
    iconColor: Color(0xFF4F8E35),
  ),
  _Ingredient(
    name: '고추장',
    icon: Icons.soup_kitchen_rounded,
    color: Color(0xFFFFDDD3),
    iconColor: Color(0xFFD84315),
  ),
  _Ingredient(
    name: '김치',
    icon: Icons.ramen_dining_rounded,
    color: Color(0xFFFFE1D6),
    iconColor: Color(0xFFE6531A),
  ),
  _Ingredient(
    name: '삼겹살',
    icon: Icons.set_meal_rounded,
    color: Color(0xFFFFE4E4),
    iconColor: Color(0xFFCA6E6E),
  ),
  _Ingredient(
    name: '양파',
    icon: Icons.spa_rounded,
    color: Color(0xFFF0E4F4),
    iconColor: Color(0xFF8D6B9B),
  ),
  _Ingredient(
    name: '간장',
    icon: Icons.water_drop_rounded,
    color: Color(0xFFE9DED5),
    iconColor: Color(0xFF76513C),
  ),
  _Ingredient(
    name: '밥',
    icon: Icons.rice_bowl_rounded,
    color: Color(0xFFF2F2F2),
  ),
  _Ingredient(
    name: '두부',
    icon: Icons.view_in_ar_rounded,
    color: Color(0xFFFFF5CE),
    iconColor: Color(0xFFB99B36),
  ),
  _Ingredient(
    name: '마늘',
    icon: Icons.eco_rounded,
    color: Color(0xFFF2EDD4),
    iconColor: Color(0xFF8D8449),
  ),
  _Ingredient(
    name: '팽이버섯',
    icon: Icons.park_rounded,
    color: Color(0xFFF0E9DD),
    iconColor: Color(0xFF8A7358),
  ),
  _Ingredient(
    name: '양배추',
    icon: Icons.local_florist_rounded,
    color: Color(0xFFE4F1D5),
    iconColor: Color(0xFF679047),
  ),
  _Ingredient(
    name: '치즈',
    icon: Icons.breakfast_dining_rounded,
    color: Color(0xFFFFEDB5),
    iconColor: Color(0xFFE1A91B),
  ),
  _Ingredient(
    name: '우유',
    icon: Icons.local_drink_rounded,
    color: Color(0xFFE7F1F7),
    iconColor: Color(0xFF6D8C9F),
  ),
  _Ingredient(
    name: '깨',
    icon: Icons.scatter_plot_rounded,
    color: Color(0xFFF1E8D7),
    iconColor: Color(0xFF8A7252),
  ),
  _Ingredient(
    name: '고쵧가루',
    icon: Icons.grain_rounded,
    color: Color(0xFFFFE0D8),
    iconColor: Color(0xFFD84B29),
  ),
  _Ingredient(
    name: '물',
    icon: Icons.water_drop_outlined,
    color: Color(0xFFDFF2FB),
    iconColor: Color(0xFF4A9BC4),
  ),
  _Ingredient(
    name: '설탕',
    icon: Icons.blur_on_rounded,
    color: Color(0xFFF4F4F4),
  ),
  _Ingredient(
    name: '코인육수',
    icon: Icons.circle_rounded,
    color: Color(0xFFF4E1C5),
    iconColor: Color(0xFF9B6C35),
  ),
  _Ingredient(
    name: '참기름',
    icon: Icons.opacity_rounded,
    color: Color(0xFFF1E1C6),
    iconColor: Color(0xFF8B5B27),
  ),
  _Ingredient(
    name: '치킨스톡',
    icon: Icons.soup_kitchen_outlined,
    color: Color(0xFFFFEACB),
    iconColor: Color(0xFFC6862A),
  ),
  _Ingredient(
    name: '식용유',
    icon: Icons.opacity_rounded,
    color: Color(0xFFFFF0BF),
    iconColor: Color(0xFFD2A21C),
  ),
  _Ingredient(
    name: '후추',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFFE7E3DF),
    iconColor: Color(0xFF5D5751),
  ),
  _Ingredient(
    name: '참치액',
    icon: Icons.water_drop_rounded,
    color: Color(0xFFE8E0D8),
    iconColor: Color(0xFF725B4A),
  ),
  _Ingredient(
    name: '올리브오일',
    icon: Icons.opacity_rounded,
    color: Color(0xFFE9EDCF),
    iconColor: Color(0xFF78803A),
  ),
  _Ingredient(
    name: '레드페퍼',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFFE0D7),
    iconColor: Color(0xFFD94A27),
  ),
  _Ingredient(
    name: '맛술',
    icon: Icons.local_bar_rounded,
    color: Color(0xFFF3E7D3),
    iconColor: Color(0xFF9B7546),
  ),
  _Ingredient(
    name: '식초',
    icon: Icons.science_outlined,
    color: Color(0xFFE8F0D8),
    iconColor: Color(0xFF6D8846),
  ),
  _Ingredient(
    name: '알룰로스',
    icon: Icons.blur_on_rounded,
    color: Color(0xFFF2F0EC),
  ),
  _Ingredient(
    name: '와사비',
    icon: Icons.grass_rounded,
    color: Color(0xFFE0F0CD),
    iconColor: Color(0xFF6B983B),
  ),
  _Ingredient(
    name: '버터',
    icon: Icons.rectangle_rounded,
    color: Color(0xFFFFF0B8),
    iconColor: Color(0xFFD6A720),
  ),
  _Ingredient(
    name: '소금',
    icon: Icons.blur_on_rounded,
    color: Color(0xFFF3F3F3),
  ),
  _Ingredient(
    name: '파스타면',
    icon: Icons.ramen_dining_rounded,
    color: Color(0xFFFFEBC2),
    iconColor: Color(0xFFC99429),
  ),
  _Ingredient(
    name: '물엿',
    icon: Icons.water_drop_rounded,
    color: Color(0xFFF1E1D2),
    iconColor: Color(0xFF9B6848),
  ),
  _Ingredient(
    name: '케찹',
    icon: Icons.water_drop_rounded,
    color: Color(0xFFFFDED8),
    iconColor: Color(0xFFD9472E),
  ),
  _Ingredient(
    name: '굴소스',
    icon: Icons.water_drop_rounded,
    color: Color(0xFFE8DFD8),
    iconColor: Color(0xFF715848),
  ),
  _Ingredient(
    name: '고추',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFE2F1D5),
    iconColor: Color(0xFF4D933E),
  ),
  _Ingredient(
    name: '감자',
    icon: Icons.circle_rounded,
    color: Color(0xFFF3E3C6),
    iconColor: Color(0xFFB28547),
  ),
  _Ingredient(
    name: '당근',
    icon: Icons.eco_rounded,
    color: Color(0xFFFFE4D2),
    iconColor: Color(0xFFE86B28),
  ),
  _Ingredient(
    name: '애호박',
    icon: Icons.eco_rounded,
    color: Color(0xFFE4F1D5),
    iconColor: Color(0xFF669342),
  ),
  _Ingredient(
    name: '오이',
    icon: Icons.eco_rounded,
    color: Color(0xFFDDF0D3),
    iconColor: Color(0xFF4D913E),
  ),
  _Ingredient(
    name: '버섯',
    icon: Icons.park_rounded,
    color: Color(0xFFECE4DA),
    iconColor: Color(0xFF8A7059),
  ),
  _Ingredient(
    name: '베이컨',
    icon: Icons.set_meal_rounded,
    color: Color(0xFFFFE1DF),
    iconColor: Color(0xFFC75D5A),
  ),
];
