// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecommendationListResponse extends RecommendationListResponse {
  @override
  final BuiltList<RecommendationItem> items;

  factory _$RecommendationListResponse(
          [void Function(RecommendationListResponseBuilder)? updates]) =>
      (RecommendationListResponseBuilder()..update(updates))._build();

  _$RecommendationListResponse._({required this.items}) : super._();
  @override
  RecommendationListResponse rebuild(
          void Function(RecommendationListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecommendationListResponseBuilder toBuilder() =>
      RecommendationListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecommendationListResponse && items == other.items;
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
    return (newBuiltValueToStringHelper(r'RecommendationListResponse')
          ..add('items', items))
        .toString();
  }
}

class RecommendationListResponseBuilder
    implements
        Builder<RecommendationListResponse, RecommendationListResponseBuilder> {
  _$RecommendationListResponse? _$v;

  ListBuilder<RecommendationItem>? _items;
  ListBuilder<RecommendationItem> get items =>
      _$this._items ??= ListBuilder<RecommendationItem>();
  set items(ListBuilder<RecommendationItem>? items) => _$this._items = items;

  RecommendationListResponseBuilder() {
    RecommendationListResponse._defaults(this);
  }

  RecommendationListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecommendationListResponse other) {
    _$v = other as _$RecommendationListResponse;
  }

  @override
  void update(void Function(RecommendationListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecommendationListResponse build() => _build();

  _$RecommendationListResponse _build() {
    _$RecommendationListResponse _$result;
    try {
      _$result = _$v ??
          _$RecommendationListResponse._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RecommendationListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
