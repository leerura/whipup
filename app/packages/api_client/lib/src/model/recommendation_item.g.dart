// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecommendationItem extends RecommendationItem {
  @override
  final int recipeId;
  @override
  final String name;
  @override
  final String thumbnailUrl;
  @override
  final int missingCount;
  @override
  final BuiltList<RequirementResult> requirementResults;

  factory _$RecommendationItem(
          [void Function(RecommendationItemBuilder)? updates]) =>
      (RecommendationItemBuilder()..update(updates))._build();

  _$RecommendationItem._(
      {required this.recipeId,
      required this.name,
      required this.thumbnailUrl,
      required this.missingCount,
      required this.requirementResults})
      : super._();
  @override
  RecommendationItem rebuild(
          void Function(RecommendationItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecommendationItemBuilder toBuilder() =>
      RecommendationItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecommendationItem &&
        recipeId == other.recipeId &&
        name == other.name &&
        thumbnailUrl == other.thumbnailUrl &&
        missingCount == other.missingCount &&
        requirementResults == other.requirementResults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipeId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, missingCount.hashCode);
    _$hash = $jc(_$hash, requirementResults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecommendationItem')
          ..add('recipeId', recipeId)
          ..add('name', name)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('missingCount', missingCount)
          ..add('requirementResults', requirementResults))
        .toString();
  }
}

class RecommendationItemBuilder
    implements Builder<RecommendationItem, RecommendationItemBuilder> {
  _$RecommendationItem? _$v;

  int? _recipeId;
  int? get recipeId => _$this._recipeId;
  set recipeId(int? recipeId) => _$this._recipeId = recipeId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  int? _missingCount;
  int? get missingCount => _$this._missingCount;
  set missingCount(int? missingCount) => _$this._missingCount = missingCount;

  ListBuilder<RequirementResult>? _requirementResults;
  ListBuilder<RequirementResult> get requirementResults =>
      _$this._requirementResults ??= ListBuilder<RequirementResult>();
  set requirementResults(ListBuilder<RequirementResult>? requirementResults) =>
      _$this._requirementResults = requirementResults;

  RecommendationItemBuilder() {
    RecommendationItem._defaults(this);
  }

  RecommendationItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recipeId = $v.recipeId;
      _name = $v.name;
      _thumbnailUrl = $v.thumbnailUrl;
      _missingCount = $v.missingCount;
      _requirementResults = $v.requirementResults.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecommendationItem other) {
    _$v = other as _$RecommendationItem;
  }

  @override
  void update(void Function(RecommendationItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecommendationItem build() => _build();

  _$RecommendationItem _build() {
    _$RecommendationItem _$result;
    try {
      _$result = _$v ??
          _$RecommendationItem._(
            recipeId: BuiltValueNullFieldError.checkNotNull(
                recipeId, r'RecommendationItem', 'recipeId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'RecommendationItem', 'name'),
            thumbnailUrl: BuiltValueNullFieldError.checkNotNull(
                thumbnailUrl, r'RecommendationItem', 'thumbnailUrl'),
            missingCount: BuiltValueNullFieldError.checkNotNull(
                missingCount, r'RecommendationItem', 'missingCount'),
            requirementResults: requirementResults.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requirementResults';
        requirementResults.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RecommendationItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
