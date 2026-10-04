import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../ingredient_presentation_catalog.dart';
import 'ingredient_thumbnail.dart';

class IngredientGroupSelector extends StatefulWidget {
  const IngredientGroupSelector({
    required this.groups,
    required this.selectedVariantIds,
    required this.onToggle,
    this.pendingVariantIds = const {},
    this.query = '',
    super.key,
  });

  final List<IngredientGroup> groups;
  final Set<int> selectedVariantIds;
  final Set<int> pendingVariantIds;
  final ValueChanged<int> onToggle;
  final String query;

  @override
  State<IngredientGroupSelector> createState() => _IngredientGroupSelectorState();
}

class _IngredientGroupSelectorState extends State<IngredientGroupSelector> {
  final Set<String> _expanded = {};
  final Set<String> _collapsedSearchMatches = {};

  @override
  void didUpdateWidget(covariant IngredientGroupSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _collapsedSearchMatches.clear();
  }

  bool _isExpanded(IngredientGroup group) {
    final query = widget.query.trim().toLowerCase();
    return _expanded.contains(group.name) ||
        (query.isNotEmpty && !_collapsedSearchMatches.contains(group.name) &&
         group.items.any((item) => item.name.toLowerCase() == query));
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.query.trim().toLowerCase();
    final groups = widget.groups.where((group) => query.isEmpty ||
        group.name.toLowerCase().contains(query) ||
        group.items.any((item) => item.name.toLowerCase().contains(query))).toList();
    if (groups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          Icon(Icons.search_off_rounded, size: 52, color: Color(0xFF8E8E93)),
          SizedBox(height: 10),
          Text('검색 결과가 없어요'),
          SizedBox(height: 10),
          Text('다른 재료 이름으로 다시 검색해 보세요', textAlign: TextAlign.center),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var index = 0; index < groups.length; index += 2) ...[
        Row(children: [
          Expanded(child: _groupTile(groups[index])),
          const SizedBox(width: 10),
          Expanded(child: index + 1 < groups.length
              ? _groupTile(groups[index + 1]) : const SizedBox()),
        ]),
        for (final group in groups.skip(index).take(2))
          if (group.items.length > 1 && _isExpanded(group))
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB), borderRadius: BorderRadius.circular(8),
              ),
              child: Column(children: [
                for (final item in group.items) _variantTile(item, size: 32, height: 48),
              ]),
            ),
        if (index + 2 < groups.length) const SizedBox(height: 14),
      ],
    ]);
  }

  Widget _groupTile(IngredientGroup group) {
    if (group.items.length == 1) return _variantTile(group.items.single);
    final expanded = _isExpanded(group);
    final count = group.items.where((item) => widget.selectedVariantIds.contains(item.variantId)).length;
    return Semantics(
      button: true, label: '${group.name}, ${expanded ? '접기' : '펼치기'}',
      child: InkWell(
        onTap: () => setState(() {
          if (expanded) {
            _expanded.remove(group.name);
            _collapsedSearchMatches.add(group.name);
          } else {
            _expanded.add(group.name);
            _collapsedSearchMatches.remove(group.name);
          }
        }),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(children: [
            Container(width: 24, height: 24,
              decoration: BoxDecoration(color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(5)),
              child: Icon(expanded ? Icons.expand_less : Icons.chevron_right, size: 20)),
            const SizedBox(width: 8),
            IngredientThumbnail(displayName: group.name,
              assetPath: ingredientAssetPathFor(group.name), size: 36),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(group.name, style: const TextStyle(fontSize: 14, letterSpacing: 0)),
              Text(count > 0 ? '$count개 보유' : '${group.items.length}가지',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93), letterSpacing: 0)),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _variantTile(IngredientVariantOption item, {double size = 36, double height = 56}) {
    final selected = widget.selectedVariantIds.contains(item.variantId);
    final pending = widget.pendingVariantIds.contains(item.variantId);
    return Semantics(
      checked: selected, button: true, label: item.name,
      child: InkWell(
        onTap: pending ? null : () => widget.onToggle(item.variantId),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Row(children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: selected ? AppColors.primary : const Color(0xFFD1D1D6)),
              ),
              child: pending
                  ? const Padding(padding: EdgeInsets.all(4), child: CircularProgressIndicator(strokeWidth: 2))
                  : selected ? const Icon(Icons.check_rounded, size: 17, color: Colors.white) : null,
            ),
            const SizedBox(width: 8),
            IngredientThumbnail(displayName: item.name,
              assetPath: ingredientAssetPathFor(item.name), size: size),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14, letterSpacing: 0))),
          ]),
        ),
      ),
    );
  }
}
