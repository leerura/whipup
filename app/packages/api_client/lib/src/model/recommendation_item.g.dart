// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RecommendationItemMissingCountEnum
    _$recommendationItemMissingCountEnum_number0 =
    const RecommendationItemMissingCountEnum._('number0');
const RecommendationItemMissingCountEnum
    _$recommendationItemMissingCountEnum_number1 =
    const RecommendationItemMissingCountEnum._('number1');
const RecommendationItemMissingCountEnum
    _$recommendationItemMissingCountEnum_number2 =
    const RecommendationItemMissingCountEnum._('number2');

RecommendationItemMissingCountEnum _$recommendationItemMissingCountEnumValueOf(
    String name) {
  switch (name) {
    case 'number0':
      return _$recommendationItemMissingCountEnum_number0;
    case 'number1':
      return _$recommendationItemMissingCountEnum_number1;
    case 'number2':
      return _$recommendationItemMissingCountEnum_number2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RecommendationItemMissingCountEnum>
    _$recommendationItemMissingCountEnumValues = BuiltSet<
        RecommendationItemMissingCountEnum>(const <RecommendationItemMissingCountEnum>[
  _$recommendationItemMissingCountEnum_number0,
  _$recommendationItemMissingCountEnum_number1,
  _$recommendationItemMissingCountEnum_number2,
]);

Serializer<RecommendationItemMissingCountEnum>
    _$recommendationItemMissingCountEnumSerializer =
    _$RecommendationItemMissingCountEnumSerializer();

class _$RecommendationItemMissingCountEnumSerializer
    implements PrimitiveSerializer<RecommendationItemMissingCountEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'number1': 1,
    'number2': 2,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    1: 'number1',
    2: 'number2',
  };

  @override
  final Iterable<Type> types = const <Type>[RecommendationItemMissingCountEnum];
  @override
  final String wireName = 'RecommendationItemMissingCountEnum';

  @override
  Object serialize(
          Serializers serializers, RecommendationItemMissingCountEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RecommendationItemMissingCountEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RecommendationItemMissingCountEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RecommendationItem extends RecommendationItem {
  @override
  final int recipeId;
  @override
  final String name;
  @override
  final String thumbnailUrl;
  @override
  final RecommendationItemMissingCountEnum missingCount;
  @override
  final BuiltList<MissingIngredient> missingIngredients;

  factory _$RecommendationItem(
          [void Function(RecommendationItemBuilder)? updates]) =>
      (RecommendationItemBuilder()..update(updates))._build();

  _$RecommendationItem._(
      {required this.recipeId,
      required this.name,
      required this.thumbnailUrl,
      required this.missingCount,
      required this.missingIngredients})
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
        missingIngredients == other.missingIngredients;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipeId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, missingCount.hashCode);
    _$hash = $jc(_$hash, missingIngredients.hashCode);
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
          ..add('missingIngredients', missingIngredients))
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

  RecommendationItemMissingCountEnum? _missingCount;
  RecommendationItemMissingCountEnum? get missingCount => _$this._missingCount;
  set missingCount(RecommendationItemMissingCountEnum? missingCount) =>
      _$this._missingCount = missingCount;

  ListBuilder<MissingIngredient>? _missingIngredients;
  ListBuilder<MissingIngredient> get missingIngredients =>
      _$this._missingIngredients ??= ListBuilder<MissingIngredient>();
  set missingIngredients(ListBuilder<MissingIngredient>? missingIngredients) =>
      _$this._missingIngredients = missingIngredients;

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
      _missingIngredients = $v.missingIngredients.toBuilder();
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
            missingIngredients: missingIngredients.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'missingIngredients';
        missingIngredients.build();
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
