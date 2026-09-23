// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IngredientOption extends IngredientOption {
  @override
  final int ingredientId;
  @override
  final String displayName;

  factory _$IngredientOption(
          [void Function(IngredientOptionBuilder)? updates]) =>
      (IngredientOptionBuilder()..update(updates))._build();

  _$IngredientOption._({required this.ingredientId, required this.displayName})
      : super._();
  @override
  IngredientOption rebuild(void Function(IngredientOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IngredientOptionBuilder toBuilder() =>
      IngredientOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IngredientOption &&
        ingredientId == other.ingredientId &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ingredientId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IngredientOption')
          ..add('ingredientId', ingredientId)
          ..add('displayName', displayName))
        .toString();
  }
}

class IngredientOptionBuilder
    implements Builder<IngredientOption, IngredientOptionBuilder> {
  _$IngredientOption? _$v;

  int? _ingredientId;
  int? get ingredientId => _$this._ingredientId;
  set ingredientId(int? ingredientId) => _$this._ingredientId = ingredientId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  IngredientOptionBuilder() {
    IngredientOption._defaults(this);
  }

  IngredientOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ingredientId = $v.ingredientId;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IngredientOption other) {
    _$v = other as _$IngredientOption;
  }

  @override
  void update(void Function(IngredientOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IngredientOption build() => _build();

  _$IngredientOption _build() {
    final _$result = _$v ??
        _$IngredientOption._(
          ingredientId: BuiltValueNullFieldError.checkNotNull(
              ingredientId, r'IngredientOption', 'ingredientId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'IngredientOption', 'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
