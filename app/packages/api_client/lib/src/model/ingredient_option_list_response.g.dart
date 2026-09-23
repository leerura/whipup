// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_option_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IngredientOptionListResponse extends IngredientOptionListResponse {
  @override
  final BuiltList<IngredientOption> items;

  factory _$IngredientOptionListResponse(
          [void Function(IngredientOptionListResponseBuilder)? updates]) =>
      (IngredientOptionListResponseBuilder()..update(updates))._build();

  _$IngredientOptionListResponse._({required this.items}) : super._();
  @override
  IngredientOptionListResponse rebuild(
          void Function(IngredientOptionListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IngredientOptionListResponseBuilder toBuilder() =>
      IngredientOptionListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IngredientOptionListResponse && items == other.items;
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
    return (newBuiltValueToStringHelper(r'IngredientOptionListResponse')
          ..add('items', items))
        .toString();
  }
}

class IngredientOptionListResponseBuilder
    implements
        Builder<IngredientOptionListResponse,
            IngredientOptionListResponseBuilder> {
  _$IngredientOptionListResponse? _$v;

  ListBuilder<IngredientOption>? _items;
  ListBuilder<IngredientOption> get items =>
      _$this._items ??= ListBuilder<IngredientOption>();
  set items(ListBuilder<IngredientOption>? items) => _$this._items = items;

  IngredientOptionListResponseBuilder() {
    IngredientOptionListResponse._defaults(this);
  }

  IngredientOptionListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IngredientOptionListResponse other) {
    _$v = other as _$IngredientOptionListResponse;
  }

  @override
  void update(void Function(IngredientOptionListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IngredientOptionListResponse build() => _build();

  _$IngredientOptionListResponse _build() {
    _$IngredientOptionListResponse _$result;
    try {
      _$result = _$v ??
          _$IngredientOptionListResponse._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IngredientOptionListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
