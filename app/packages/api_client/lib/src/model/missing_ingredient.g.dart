// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missing_ingredient.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MissingIngredient extends MissingIngredient {
  @override
  final int ingredientId;
  @override
  final String name;

  factory _$MissingIngredient(
          [void Function(MissingIngredientBuilder)? updates]) =>
      (MissingIngredientBuilder()..update(updates))._build();

  _$MissingIngredient._({required this.ingredientId, required this.name})
      : super._();
  @override
  MissingIngredient rebuild(void Function(MissingIngredientBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MissingIngredientBuilder toBuilder() =>
      MissingIngredientBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MissingIngredient &&
        ingredientId == other.ingredientId &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ingredientId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MissingIngredient')
          ..add('ingredientId', ingredientId)
          ..add('name', name))
        .toString();
  }
}

class MissingIngredientBuilder
    implements Builder<MissingIngredient, MissingIngredientBuilder> {
  _$MissingIngredient? _$v;

  int? _ingredientId;
  int? get ingredientId => _$this._ingredientId;
  set ingredientId(int? ingredientId) => _$this._ingredientId = ingredientId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  MissingIngredientBuilder() {
    MissingIngredient._defaults(this);
  }

  MissingIngredientBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ingredientId = $v.ingredientId;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MissingIngredient other) {
    _$v = other as _$MissingIngredient;
  }

  @override
  void update(void Function(MissingIngredientBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MissingIngredient build() => _build();

  _$MissingIngredient _build() {
    final _$result = _$v ??
        _$MissingIngredient._(
          ingredientId: BuiltValueNullFieldError.checkNotNull(
              ingredientId, r'MissingIngredient', 'ingredientId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MissingIngredient', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
