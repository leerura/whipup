// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_group.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IngredientGroup extends IngredientGroup {
  @override
  final String name;
  @override
  final BuiltList<IngredientVariantOption> items;

  factory _$IngredientGroup([void Function(IngredientGroupBuilder)? updates]) =>
      (IngredientGroupBuilder()..update(updates))._build();

  _$IngredientGroup._({required this.name, required this.items}) : super._();
  @override
  IngredientGroup rebuild(void Function(IngredientGroupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IngredientGroupBuilder toBuilder() => IngredientGroupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IngredientGroup &&
        name == other.name &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IngredientGroup')
          ..add('name', name)
          ..add('items', items))
        .toString();
  }
}

class IngredientGroupBuilder
    implements Builder<IngredientGroup, IngredientGroupBuilder> {
  _$IngredientGroup? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<IngredientVariantOption>? _items;
  ListBuilder<IngredientVariantOption> get items =>
      _$this._items ??= ListBuilder<IngredientVariantOption>();
  set items(ListBuilder<IngredientVariantOption>? items) =>
      _$this._items = items;

  IngredientGroupBuilder() {
    IngredientGroup._defaults(this);
  }

  IngredientGroupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IngredientGroup other) {
    _$v = other as _$IngredientGroup;
  }

  @override
  void update(void Function(IngredientGroupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IngredientGroup build() => _build();

  _$IngredientGroup _build() {
    _$IngredientGroup _$result;
    try {
      _$result = _$v ??
          _$IngredientGroup._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'IngredientGroup', 'name'),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IngredientGroup', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
