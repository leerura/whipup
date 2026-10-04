// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_owned_ingredient_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddOwnedIngredientRequest extends AddOwnedIngredientRequest {
  @override
  final int variantId;

  factory _$AddOwnedIngredientRequest(
          [void Function(AddOwnedIngredientRequestBuilder)? updates]) =>
      (AddOwnedIngredientRequestBuilder()..update(updates))._build();

  _$AddOwnedIngredientRequest._({required this.variantId}) : super._();
  @override
  AddOwnedIngredientRequest rebuild(
          void Function(AddOwnedIngredientRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddOwnedIngredientRequestBuilder toBuilder() =>
      AddOwnedIngredientRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddOwnedIngredientRequest && variantId == other.variantId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AddOwnedIngredientRequest')
          ..add('variantId', variantId))
        .toString();
  }
}

class AddOwnedIngredientRequestBuilder
    implements
        Builder<AddOwnedIngredientRequest, AddOwnedIngredientRequestBuilder> {
  _$AddOwnedIngredientRequest? _$v;

  int? _variantId;
  int? get variantId => _$this._variantId;
  set variantId(int? variantId) => _$this._variantId = variantId;

  AddOwnedIngredientRequestBuilder() {
    AddOwnedIngredientRequest._defaults(this);
  }

  AddOwnedIngredientRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddOwnedIngredientRequest other) {
    _$v = other as _$AddOwnedIngredientRequest;
  }

  @override
  void update(void Function(AddOwnedIngredientRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddOwnedIngredientRequest build() => _build();

  _$AddOwnedIngredientRequest _build() {
    final _$result = _$v ??
        _$AddOwnedIngredientRequest._(
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'AddOwnedIngredientRequest', 'variantId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
