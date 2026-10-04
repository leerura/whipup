// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_variant_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IngredientVariantOption extends IngredientVariantOption {
  @override
  final int variantId;
  @override
  final String name;

  factory _$IngredientVariantOption(
          [void Function(IngredientVariantOptionBuilder)? updates]) =>
      (IngredientVariantOptionBuilder()..update(updates))._build();

  _$IngredientVariantOption._({required this.variantId, required this.name})
      : super._();
  @override
  IngredientVariantOption rebuild(
          void Function(IngredientVariantOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IngredientVariantOptionBuilder toBuilder() =>
      IngredientVariantOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IngredientVariantOption &&
        variantId == other.variantId &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IngredientVariantOption')
          ..add('variantId', variantId)
          ..add('name', name))
        .toString();
  }
}

class IngredientVariantOptionBuilder
    implements
        Builder<IngredientVariantOption, IngredientVariantOptionBuilder> {
  _$IngredientVariantOption? _$v;

  int? _variantId;
  int? get variantId => _$this._variantId;
  set variantId(int? variantId) => _$this._variantId = variantId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  IngredientVariantOptionBuilder() {
    IngredientVariantOption._defaults(this);
  }

  IngredientVariantOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IngredientVariantOption other) {
    _$v = other as _$IngredientVariantOption;
  }

  @override
  void update(void Function(IngredientVariantOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IngredientVariantOption build() => _build();

  _$IngredientVariantOption _build() {
    final _$result = _$v ??
        _$IngredientVariantOption._(
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'IngredientVariantOption', 'variantId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'IngredientVariantOption', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
