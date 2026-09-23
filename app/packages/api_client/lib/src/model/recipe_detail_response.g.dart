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
  final String thumbnailUrl;
  @override
  final int missingCount;
  @override
  final BuiltList<RecipeIngredient> ingredients;
  @override
  final BuiltList<RecipeStep> steps;

  factory _$RecipeDetailResponse(
          [void Function(RecipeDetailResponseBuilder)? updates]) =>
      (RecipeDetailResponseBuilder()..update(updates))._build();

  _$RecipeDetailResponse._(
      {required this.recipeId,
      required this.name,
      required this.shortsReference,
      required this.thumbnailUrl,
      required this.missingCount,
      required this.ingredients,
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
        thumbnailUrl == other.thumbnailUrl &&
        missingCount == other.missingCount &&
        ingredients == other.ingredients &&
        steps == other.steps;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipeId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, shortsReference.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, missingCount.hashCode);
    _$hash = $jc(_$hash, ingredients.hashCode);
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
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('missingCount', missingCount)
          ..add('ingredients', ingredients)
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

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  int? _missingCount;
  int? get missingCount => _$this._missingCount;
  set missingCount(int? missingCount) => _$this._missingCount = missingCount;

  ListBuilder<RecipeIngredient>? _ingredients;
  ListBuilder<RecipeIngredient> get ingredients =>
      _$this._ingredients ??= ListBuilder<RecipeIngredient>();
  set ingredients(ListBuilder<RecipeIngredient>? ingredients) =>
      _$this._ingredients = ingredients;

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
      _thumbnailUrl = $v.thumbnailUrl;
      _missingCount = $v.missingCount;
      _ingredients = $v.ingredients.toBuilder();
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
            thumbnailUrl: BuiltValueNullFieldError.checkNotNull(
                thumbnailUrl, r'RecipeDetailResponse', 'thumbnailUrl'),
            missingCount: BuiltValueNullFieldError.checkNotNull(
                missingCount, r'RecipeDetailResponse', 'missingCount'),
            ingredients: ingredients.build(),
            steps: steps.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ingredients';
        ingredients.build();
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
