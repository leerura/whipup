// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_group_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IngredientGroupListResponse extends IngredientGroupListResponse {
  @override
  final BuiltList<IngredientGroup> groups;

  factory _$IngredientGroupListResponse(
          [void Function(IngredientGroupListResponseBuilder)? updates]) =>
      (IngredientGroupListResponseBuilder()..update(updates))._build();

  _$IngredientGroupListResponse._({required this.groups}) : super._();
  @override
  IngredientGroupListResponse rebuild(
          void Function(IngredientGroupListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IngredientGroupListResponseBuilder toBuilder() =>
      IngredientGroupListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IngredientGroupListResponse && groups == other.groups;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groups.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IngredientGroupListResponse')
          ..add('groups', groups))
        .toString();
  }
}

class IngredientGroupListResponseBuilder
    implements
        Builder<IngredientGroupListResponse,
            IngredientGroupListResponseBuilder> {
  _$IngredientGroupListResponse? _$v;

  ListBuilder<IngredientGroup>? _groups;
  ListBuilder<IngredientGroup> get groups =>
      _$this._groups ??= ListBuilder<IngredientGroup>();
  set groups(ListBuilder<IngredientGroup>? groups) => _$this._groups = groups;

  IngredientGroupListResponseBuilder() {
    IngredientGroupListResponse._defaults(this);
  }

  IngredientGroupListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groups = $v.groups.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IngredientGroupListResponse other) {
    _$v = other as _$IngredientGroupListResponse;
  }

  @override
  void update(void Function(IngredientGroupListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IngredientGroupListResponse build() => _build();

  _$IngredientGroupListResponse _build() {
    _$IngredientGroupListResponse _$result;
    try {
      _$result = _$v ??
          _$IngredientGroupListResponse._(
            groups: groups.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'groups';
        groups.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IngredientGroupListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
