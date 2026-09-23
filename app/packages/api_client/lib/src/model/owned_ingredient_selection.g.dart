// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_ingredient_selection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnedIngredientSelection extends OwnedIngredientSelection {
  @override
  final int ingredientId;

  factory _$OwnedIngredientSelection(
          [void Function(OwnedIngredientSelectionBuilder)? updates]) =>
      (OwnedIngredientSelectionBuilder()..update(updates))._build();

  _$OwnedIngredientSelection._({required this.ingredientId}) : super._();
  @override
  OwnedIngredientSelection rebuild(
          void Function(OwnedIngredientSelectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnedIngredientSelectionBuilder toBuilder() =>
      OwnedIngredientSelectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnedIngredientSelection &&
        ingredientId == other.ingredientId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ingredientId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnedIngredientSelection')
          ..add('ingredientId', ingredientId))
        .toString();
  }
}

class OwnedIngredientSelectionBuilder
    implements
        Builder<OwnedIngredientSelection, OwnedIngredientSelectionBuilder> {
  _$OwnedIngredientSelection? _$v;

  int? _ingredientId;
  int? get ingredientId => _$this._ingredientId;
  set ingredientId(int? ingredientId) => _$this._ingredientId = ingredientId;

  OwnedIngredientSelectionBuilder() {
    OwnedIngredientSelection._defaults(this);
  }

  OwnedIngredientSelectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ingredientId = $v.ingredientId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnedIngredientSelection other) {
    _$v = other as _$OwnedIngredientSelection;
  }

  @override
  void update(void Function(OwnedIngredientSelectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnedIngredientSelection build() => _build();

  _$OwnedIngredientSelection _build() {
    final _$result = _$v ??
        _$OwnedIngredientSelection._(
          ingredientId: BuiltValueNullFieldError.checkNotNull(
              ingredientId, r'OwnedIngredientSelection', 'ingredientId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
