// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_owned_ingredients_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddOwnedIngredientsRequest extends AddOwnedIngredientsRequest {
  @override
  final BuiltList<OwnedIngredientSelection> items;

  factory _$AddOwnedIngredientsRequest(
          [void Function(AddOwnedIngredientsRequestBuilder)? updates]) =>
      (AddOwnedIngredientsRequestBuilder()..update(updates))._build();

  _$AddOwnedIngredientsRequest._({required this.items}) : super._();
  @override
  AddOwnedIngredientsRequest rebuild(
          void Function(AddOwnedIngredientsRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddOwnedIngredientsRequestBuilder toBuilder() =>
      AddOwnedIngredientsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddOwnedIngredientsRequest && items == other.items;
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
    return (newBuiltValueToStringHelper(r'AddOwnedIngredientsRequest')
          ..add('items', items))
        .toString();
  }
}

class AddOwnedIngredientsRequestBuilder
    implements
        Builder<AddOwnedIngredientsRequest, AddOwnedIngredientsRequestBuilder> {
  _$AddOwnedIngredientsRequest? _$v;

  ListBuilder<OwnedIngredientSelection>? _items;
  ListBuilder<OwnedIngredientSelection> get items =>
      _$this._items ??= ListBuilder<OwnedIngredientSelection>();
  set items(ListBuilder<OwnedIngredientSelection>? items) =>
      _$this._items = items;

  AddOwnedIngredientsRequestBuilder() {
    AddOwnedIngredientsRequest._defaults(this);
  }

  AddOwnedIngredientsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddOwnedIngredientsRequest other) {
    _$v = other as _$AddOwnedIngredientsRequest;
  }

  @override
  void update(void Function(AddOwnedIngredientsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddOwnedIngredientsRequest build() => _build();

  _$AddOwnedIngredientsRequest _build() {
    _$AddOwnedIngredientsRequest _$result;
    try {
      _$result = _$v ??
          _$AddOwnedIngredientsRequest._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AddOwnedIngredientsRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
