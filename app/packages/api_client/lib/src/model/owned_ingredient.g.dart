// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_ingredient.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnedIngredient extends OwnedIngredient {
  @override
  final int userIngredientId;
  @override
  final int variantId;
  @override
  final String name;

  factory _$OwnedIngredient([void Function(OwnedIngredientBuilder)? updates]) =>
      (OwnedIngredientBuilder()..update(updates))._build();

  _$OwnedIngredient._(
      {required this.userIngredientId,
      required this.variantId,
      required this.name})
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
        variantId == other.variantId &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userIngredientId.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnedIngredient')
          ..add('userIngredientId', userIngredientId)
          ..add('variantId', variantId)
          ..add('name', name))
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

  int? _variantId;
  int? get variantId => _$this._variantId;
  set variantId(int? variantId) => _$this._variantId = variantId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  OwnedIngredientBuilder() {
    OwnedIngredient._defaults(this);
  }

  OwnedIngredientBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userIngredientId = $v.userIngredientId;
      _variantId = $v.variantId;
      _name = $v.name;
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
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'OwnedIngredient', 'variantId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'OwnedIngredient', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
