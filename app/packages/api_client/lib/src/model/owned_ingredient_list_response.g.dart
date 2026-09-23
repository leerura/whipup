// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_ingredient_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnedIngredientListResponse extends OwnedIngredientListResponse {
  @override
  final BuiltList<OwnedIngredient> items;

  factory _$OwnedIngredientListResponse(
          [void Function(OwnedIngredientListResponseBuilder)? updates]) =>
      (OwnedIngredientListResponseBuilder()..update(updates))._build();

  _$OwnedIngredientListResponse._({required this.items}) : super._();
  @override
  OwnedIngredientListResponse rebuild(
          void Function(OwnedIngredientListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnedIngredientListResponseBuilder toBuilder() =>
      OwnedIngredientListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnedIngredientListResponse && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnedIngredientListResponse')
          ..add('items', items))
        .toString();
  }
}

class OwnedIngredientListResponseBuilder
    implements
        Builder<OwnedIngredientListResponse,
            OwnedIngredientListResponseBuilder> {
  _$OwnedIngredientListResponse? _$v;

  ListBuilder<OwnedIngredient>? _items;
  ListBuilder<OwnedIngredient> get items =>
      _$this._items ??= ListBuilder<OwnedIngredient>();
  set items(ListBuilder<OwnedIngredient>? items) => _$this._items = items;

  OwnedIngredientListResponseBuilder() {
    OwnedIngredientListResponse._defaults(this);
  }

  OwnedIngredientListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnedIngredientListResponse other) {
    _$v = other as _$OwnedIngredientListResponse;
  }

  @override
  void update(void Function(OwnedIngredientListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnedIngredientListResponse build() => _build();

  _$OwnedIngredientListResponse _build() {
    _$OwnedIngredientListResponse _$result;
    try {
      _$result = _$v ??
          _$OwnedIngredientListResponse._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnedIngredientListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
