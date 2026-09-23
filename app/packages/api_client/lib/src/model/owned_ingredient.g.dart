// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_ingredient.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnedIngredient extends OwnedIngredient {
  @override
  final int userIngredientId;
  @override
  final int ingredientId;
  @override
  final String displayName;

  factory _$OwnedIngredient([void Function(OwnedIngredientBuilder)? updates]) =>
      (OwnedIngredientBuilder()..update(updates))._build();

  _$OwnedIngredient._(
      {required this.userIngredientId,
      required this.ingredientId,
      required this.displayName})
      : super._();
  @override
  OwnedIngredient rebuild(void Function(OwnedIngredientBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnedIngredientBuilder toBuilder() => OwnedIngredientBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnedIngredient &&
        userIngredientId == other.userIngredientId &&
        ingredientId == other.ingredientId &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userIngredientId.hashCode);
    _$hash = $jc(_$hash, ingredientId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnedIngredient')
          ..add('userIngredientId', userIngredientId)
          ..add('ingredientId', ingredientId)
          ..add('displayName', displayName))
        .toString();
  }
}

class OwnedIngredientBuilder
    implements Builder<OwnedIngredient, OwnedIngredientBuilder> {
  _$OwnedIngredient? _$v;

  int? _userIngredientId;
  int? get userIngredientId => _$this._userIngredientId;
  set userIngredientId(int? userIngredientId) =>
      _$this._userIngredientId = userIngredientId;

  int? _ingredientId;
  int? get ingredientId => _$this._ingredientId;
  set ingredientId(int? ingredientId) => _$this._ingredientId = ingredientId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  OwnedIngredientBuilder() {
    OwnedIngredient._defaults(this);
  }

  OwnedIngredientBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userIngredientId = $v.userIngredientId;
      _ingredientId = $v.ingredientId;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnedIngredient other) {
    _$v = other as _$OwnedIngredient;
  }

  @override
  void update(void Function(OwnedIngredientBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnedIngredient build() => _build();

  _$OwnedIngredient _build() {
    final _$result = _$v ??
        _$OwnedIngredient._(
          userIngredientId: BuiltValueNullFieldError.checkNotNull(
              userIngredientId, r'OwnedIngredient', 'userIngredientId'),
          ingredientId: BuiltValueNullFieldError.checkNotNull(
              ingredientId, r'OwnedIngredient', 'ingredientId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'OwnedIngredient', 'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
