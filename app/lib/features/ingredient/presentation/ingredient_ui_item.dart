import 'ingredient_presentation_catalog.dart';

class IngredientUiItem {
  const IngredientUiItem({
    required this.ingredientId,
    required this.displayName,
    this.userIngredientId,
  });

  final int ingredientId;
  final String displayName;
  final int? userIngredientId;

  String? get assetPath => ingredientAssetPathFor(displayName);

  bool get isOwned => userIngredientId != null;

  IngredientUiItem copyWith({
    int? userIngredientId,
    bool clearUserIngredientId = false,
  }) {
    return IngredientUiItem(
      ingredientId: ingredientId,
      displayName: displayName,
      userIngredientId: clearUserIngredientId
          ? null
          : userIngredientId ?? this.userIngredientId,
    );
  }
}
