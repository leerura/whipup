// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_mode.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RecommendationMode _$AVAILABLE = const RecommendationMode._('AVAILABLE');
const RecommendationMode _$MISSING_INGREDIENTS =
    const RecommendationMode._('MISSING_INGREDIENTS');

RecommendationMode _$valueOf(String name) {
  switch (name) {
    case 'AVAILABLE':
      return _$AVAILABLE;
    case 'MISSING_INGREDIENTS':
      return _$MISSING_INGREDIENTS;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RecommendationMode> _$values =
    BuiltSet<RecommendationMode>(const <RecommendationMode>[
  _$AVAILABLE,
  _$MISSING_INGREDIENTS,
]);

class _$RecommendationModeMeta {
  const _$RecommendationModeMeta();
  RecommendationMode get AVAILABLE => _$AVAILABLE;
  RecommendationMode get MISSING_INGREDIENTS => _$MISSING_INGREDIENTS;
  RecommendationMode valueOf(String name) => _$valueOf(name);
  BuiltSet<RecommendationMode> get values => _$values;
}

abstract class _$RecommendationModeMixin {
  // ignore: non_constant_identifier_names
  _$RecommendationModeMeta get RecommendationMode =>
      const _$RecommendationModeMeta();
}

Serializer<RecommendationMode> _$recommendationModeSerializer =
    _$RecommendationModeSerializer();

class _$RecommendationModeSerializer
    implements PrimitiveSerializer<RecommendationMode> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'AVAILABLE': 'AVAILABLE',
    'MISSING_INGREDIENTS': 'MISSING_INGREDIENTS',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'AVAILABLE': 'AVAILABLE',
    'MISSING_INGREDIENTS': 'MISSING_INGREDIENTS',
  };

  @override
  final Iterable<Type> types = const <Type>[RecommendationMode];
  @override
  final String wireName = 'RecommendationMode';

  @override
  Object serialize(Serializers serializers, RecommendationMode object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RecommendationMode deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RecommendationMode.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
