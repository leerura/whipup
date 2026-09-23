// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecommendationPage extends RecommendationPage {
  @override
  final BuiltList<RecommendationItem> items;
  @override
  final int page;
  @override
  final int size;
  @override
  final bool hasNext;

  factory _$RecommendationPage(
          [void Function(RecommendationPageBuilder)? updates]) =>
      (RecommendationPageBuilder()..update(updates))._build();

  _$RecommendationPage._(
      {required this.items,
      required this.page,
      required this.size,
      required this.hasNext})
      : super._();
  @override
  RecommendationPage rebuild(
          void Function(RecommendationPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecommendationPageBuilder toBuilder() =>
      RecommendationPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecommendationPage &&
        items == other.items &&
        page == other.page &&
        size == other.size &&
        hasNext == other.hasNext;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, hasNext.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecommendationPage')
          ..add('items', items)
          ..add('page', page)
          ..add('size', size)
          ..add('hasNext', hasNext))
        .toString();
  }
}

class RecommendationPageBuilder
    implements Builder<RecommendationPage, RecommendationPageBuilder> {
  _$RecommendationPage? _$v;

  ListBuilder<RecommendationItem>? _items;
  ListBuilder<RecommendationItem> get items =>
      _$this._items ??= ListBuilder<RecommendationItem>();
  set items(ListBuilder<RecommendationItem>? items) => _$this._items = items;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _size;
  int? get size => _$this._size;
  set size(int? size) => _$this._size = size;

  bool? _hasNext;
  bool? get hasNext => _$this._hasNext;
  set hasNext(bool? hasNext) => _$this._hasNext = hasNext;

  RecommendationPageBuilder() {
    RecommendationPage._defaults(this);
  }

  RecommendationPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page;
      _size = $v.size;
      _hasNext = $v.hasNext;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecommendationPage other) {
    _$v = other as _$RecommendationPage;
  }

  @override
  void update(void Function(RecommendationPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecommendationPage build() => _build();

  _$RecommendationPage _build() {
    _$RecommendationPage _$result;
    try {
      _$result = _$v ??
          _$RecommendationPage._(
            items: items.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'RecommendationPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'RecommendationPage', 'size'),
            hasNext: BuiltValueNullFieldError.checkNotNull(
                hasNext, r'RecommendationPage', 'hasNext'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RecommendationPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
