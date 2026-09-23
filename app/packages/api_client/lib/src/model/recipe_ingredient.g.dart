// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecipeIngredient extends RecipeIngredient {
  @override
  final int recipeIngredientId;
  @override
  final int ingredientId;
  @override
  final String displayName;
  @override
  final String? amount;
  @override
  final String? unit;
  @override
  final int displayOrder;
  @override
  final bool owned;

  factory _$RecipeIngredient(
          [void Function(RecipeIngredientBuilder)? updates]) =>
      (RecipeIngredientBuilder()..update(updates))._build();

  _$RecipeIngredient._(
      {required this.recipeIngredientId,
      required this.ingredientId,
      required this.displayName,
      this.amount,
      this.unit,
      required this.displayOrder,
      required this.owned})
      : super._();
  @override
  RecipeIngredient rebuild(void Function(RecipeIngredientBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecipeIngredientBuilder toBuilder() =>
      RecipeIngredientBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecipeIngredient &&
        recipeIngredientId == other.recipeIngredientId &&
        ingredientId == other.ingredientId &&
        displayName == other.displayName &&
        amount == other.amount &&
        unit == other.unit &&
        displayOrder == other.displayOrder &&
        owned == other.owned;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipeIngredientId.hashCode);
    _$hash = $jc(_$hash, ingredientId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, displayOrder.hashCode);
    _$hash = $jc(_$hash, owned.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecipeIngredient')
          ..add('recipeIngredientId', recipeIngredientId)
          ..add('ingredientId', ingredientId)
          ..add('displayName', displayName)
          ..add('amount', amount)
          ..add('unit', unit)
          ..add('displayOrder', displayOrder)
          ..add('owned', owned))
        .toString();
  }
}

class RecipeIngredientBuilder
    implements Builder<RecipeIngredient, RecipeIngredientBuilder> {
  _$RecipeIngredient? _$v;

  int? _recipeIngredientId;
  int? get recipeIngredientId => _$this._recipeIngredientId;
  set recipeIngredientId(int? recipeIngredientId) =>
      _$this._recipeIngredientId = recipeIngredientId;

  int? _ingredientId;
  int? get ingredientId => _$this._ingredientId;
  set ingredientId(int? ingredientId) => _$this._ingredientId = ingredientId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  int? _displayOrder;
  int? get displayOrder => _$this._displayOrder;
  set displayOrder(int? displayOrder) => _$this._displayOrder = displayOrder;

  bool? _owned;
  bool? get owned => _$this._owned;
  set owned(bool? owned) => _$this._owned = owned;

  RecipeIngredientBuilder() {
    RecipeIngredient._defaults(this);
  }

  RecipeIngredientBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recipeIngredientId = $v.recipeIngredientId;
      _ingredientId = $v.ingredientId;
      _displayName = $v.displayName;
      _amount = $v.amount;
      _unit = $v.unit;
      _displayOrder = $v.displayOrder;
      _owned = $v.owned;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecipeIngredient other) {
    _$v = other as _$RecipeIngredient;
  }

  @override
  void update(void Function(RecipeIngredientBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecipeIngredient build() => _build();

  _$RecipeIngredient _build() {
    final _$result = _$v ??
        _$RecipeIngredient._(
          recipeIngredientId: BuiltValueNullFieldError.checkNotNull(
              recipeIngredientId, r'RecipeIngredient', 'recipeIngredientId'),
          ingredientId: BuiltValueNullFieldError.checkNotNull(
              ingredientId, r'RecipeIngredient', 'ingredientId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'RecipeIngredient', 'displayName'),
          amount: amount,
          unit: unit,
          displayOrder: BuiltValueNullFieldError.checkNotNull(
              displayOrder, r'RecipeIngredient', 'displayOrder'),
          owned: BuiltValueNullFieldError.checkNotNull(
              owned, r'RecipeIngredient', 'owned'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
