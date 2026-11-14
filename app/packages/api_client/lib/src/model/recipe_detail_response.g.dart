// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_detail_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecipeDetailResponse extends RecipeDetailResponse {
  @override
  final int recipeId;
  @override
  final String name;
  @override
  final String shortsReference;
  @override
  final String? sourceTitle;
  @override
  final String? sourceChannelName;
  @override
  final String? sourceChannelId;
  @override
  final String? sourceChannelThumbnailUrl;
  @override
  final DateTime? sourceMetadataFetchedAt;
  @override
  final String thumbnailUrl;
  @override
  final int missingCount;
  @override
  final BuiltList<DetailRequirement> requirements;
  @override
  final BuiltList<DetailIngredientDisplay> optionalIngredients;
  @override
  final BuiltList<RecipeStep> steps;

  factory _$RecipeDetailResponse(
          [void Function(RecipeDetailResponseBuilder)? updates]) =>
      (RecipeDetailResponseBuilder()..update(updates))._build();

  _$RecipeDetailResponse._(
      {required this.recipeId,
      required this.name,
      required this.shortsReference,
      this.sourceTitle,
      this.sourceChannelName,
      this.sourceChannelId,
      this.sourceChannelThumbnailUrl,
      this.sourceMetadataFetchedAt,
      required this.thumbnailUrl,
      required this.missingCount,
      required this.requirements,
      required this.optionalIngredients,
      required this.steps})
      : super._();
  @override
  RecipeDetailResponse rebuild(
          void Function(RecipeDetailResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecipeDetailResponseBuilder toBuilder() =>
      RecipeDetailResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecipeDetailResponse &&
        recipeId == other.recipeId &&
        name == other.name &&
        shortsReference == other.shortsReference &&
        sourceTitle == other.sourceTitle &&
        sourceChannelName == other.sourceChannelName &&
        sourceChannelId == other.sourceChannelId &&
        sourceChannelThumbnailUrl == other.sourceChannelThumbnailUrl &&
        sourceMetadataFetchedAt == other.sourceMetadataFetchedAt &&
        thumbnailUrl == other.thumbnailUrl &&
        missingCount == other.missingCount &&
        requirements == other.requirements &&
        optionalIngredients == other.optionalIngredients &&
        steps == other.steps;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipeId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, shortsReference.hashCode);
    _$hash = $jc(_$hash, sourceTitle.hashCode);
    _$hash = $jc(_$hash, sourceChannelName.hashCode);
    _$hash = $jc(_$hash, sourceChannelId.hashCode);
    _$hash = $jc(_$hash, sourceChannelThumbnailUrl.hashCode);
    _$hash = $jc(_$hash, sourceMetadataFetchedAt.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, missingCount.hashCode);
    _$hash = $jc(_$hash, requirements.hashCode);
    _$hash = $jc(_$hash, optionalIngredients.hashCode);
    _$hash = $jc(_$hash, steps.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecipeDetailResponse')
          ..add('recipeId', recipeId)
          ..add('name', name)
          ..add('shortsReference', shortsReference)
          ..add('sourceTitle', sourceTitle)
          ..add('sourceChannelName', sourceChannelName)
          ..add('sourceChannelId', sourceChannelId)
          ..add('sourceChannelThumbnailUrl', sourceChannelThumbnailUrl)
          ..add('sourceMetadataFetchedAt', sourceMetadataFetchedAt)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('missingCount', missingCount)
          ..add('requirements', requirements)
          ..add('optionalIngredients', optionalIngredients)
          ..add('steps', steps))
        .toString();
  }
}

class RecipeDetailResponseBuilder
    implements Builder<RecipeDetailResponse, RecipeDetailResponseBuilder> {
  _$RecipeDetailResponse? _$v;

  int? _recipeId;
  int? get recipeId => _$this._recipeId;
  set recipeId(int? recipeId) => _$this._recipeId = recipeId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _shortsReference;
  String? get shortsReference => _$this._shortsReference;
  set shortsReference(String? shortsReference) =>
      _$this._shortsReference = shortsReference;

  String? _sourceTitle;
  String? get sourceTitle => _$this._sourceTitle;
  set sourceTitle(String? sourceTitle) => _$this._sourceTitle = sourceTitle;

  String? _sourceChannelName;
  String? get sourceChannelName => _$this._sourceChannelName;
  set sourceChannelName(String? sourceChannelName) =>
      _$this._sourceChannelName = sourceChannelName;

  String? _sourceChannelId;
  String? get sourceChannelId => _$this._sourceChannelId;
  set sourceChannelId(String? sourceChannelId) =>
      _$this._sourceChannelId = sourceChannelId;

  String? _sourceChannelThumbnailUrl;
  String? get sourceChannelThumbnailUrl => _$this._sourceChannelThumbnailUrl;
  set sourceChannelThumbnailUrl(String? sourceChannelThumbnailUrl) =>
      _$this._sourceChannelThumbnailUrl = sourceChannelThumbnailUrl;

  DateTime? _sourceMetadataFetchedAt;
  DateTime? get sourceMetadataFetchedAt => _$this._sourceMetadataFetchedAt;
  set sourceMetadataFetchedAt(DateTime? sourceMetadataFetchedAt) =>
      _$this._sourceMetadataFetchedAt = sourceMetadataFetchedAt;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  int? _missingCount;
  int? get missingCount => _$this._missingCount;
  set missingCount(int? missingCount) => _$this._missingCount = missingCount;

  ListBuilder<DetailRequirement>? _requirements;
  ListBuilder<DetailRequirement> get requirements =>
      _$this._requirements ??= ListBuilder<DetailRequirement>();
  set requirements(ListBuilder<DetailRequirement>? requirements) =>
      _$this._requirements = requirements;

  ListBuilder<DetailIngredientDisplay>? _optionalIngredients;
  ListBuilder<DetailIngredientDisplay> get optionalIngredients =>
      _$this._optionalIngredients ??= ListBuilder<DetailIngredientDisplay>();
  set optionalIngredients(
          ListBuilder<DetailIngredientDisplay>? optionalIngredients) =>
      _$this._optionalIngredients = optionalIngredients;

  ListBuilder<RecipeStep>? _steps;
  ListBuilder<RecipeStep> get steps =>
      _$this._steps ??= ListBuilder<RecipeStep>();
  set steps(ListBuilder<RecipeStep>? steps) => _$this._steps = steps;

  RecipeDetailResponseBuilder() {
    RecipeDetailResponse._defaults(this);
  }

  RecipeDetailResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recipeId = $v.recipeId;
      _name = $v.name;
      _shortsReference = $v.shortsReference;
      _sourceTitle = $v.sourceTitle;
      _sourceChannelName = $v.sourceChannelName;
      _sourceChannelId = $v.sourceChannelId;
      _sourceChannelThumbnailUrl = $v.sourceChannelThumbnailUrl;
      _sourceMetadataFetchedAt = $v.sourceMetadataFetchedAt;
      _thumbnailUrl = $v.thumbnailUrl;
      _missingCount = $v.missingCount;
      _requirements = $v.requirements.toBuilder();
      _optionalIngredients = $v.optionalIngredients.toBuilder();
      _steps = $v.steps.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecipeDetailResponse other) {
    _$v = other as _$RecipeDetailResponse;
  }

  @override
  void update(void Function(RecipeDetailResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecipeDetailResponse build() => _build();

  _$RecipeDetailResponse _build() {
    _$RecipeDetailResponse _$result;
    try {
      _$result = _$v ??
          _$RecipeDetailResponse._(
            recipeId: BuiltValueNullFieldError.checkNotNull(
                recipeId, r'RecipeDetailResponse', 'recipeId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'RecipeDetailResponse', 'name'),
            shortsReference: BuiltValueNullFieldError.checkNotNull(
                shortsReference, r'RecipeDetailResponse', 'shortsReference'),
            sourceTitle: sourceTitle,
            sourceChannelName: sourceChannelName,
            sourceChannelId: sourceChannelId,
            sourceChannelThumbnailUrl: sourceChannelThumbnailUrl,
            sourceMetadataFetchedAt: sourceMetadataFetchedAt,
            thumbnailUrl: BuiltValueNullFieldError.checkNotNull(
                thumbnailUrl, r'RecipeDetailResponse', 'thumbnailUrl'),
            missingCount: BuiltValueNullFieldError.checkNotNull(
                missingCount, r'RecipeDetailResponse', 'missingCount'),
            requirements: requirements.build(),
            optionalIngredients: optionalIngredients.build(),
            steps: steps.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requirements';
        requirements.build();
        _$failedField = 'optionalIngredients';
        optionalIngredients.build();
        _$failedField = 'steps';
        steps.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RecipeDetailResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
