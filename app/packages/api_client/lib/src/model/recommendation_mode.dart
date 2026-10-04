//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recommendation_mode.g.dart';

class RecommendationMode extends EnumClass {

  @BuiltValueEnumConst(wireName: r'AVAILABLE')
  static const RecommendationMode AVAILABLE = _$AVAILABLE;
  @BuiltValueEnumConst(wireName: r'MISSING_INGREDIENTS')
  static const RecommendationMode MISSING_INGREDIENTS = _$MISSING_INGREDIENTS;

  static Serializer<RecommendationMode> get serializer => _$recommendationModeSerializer;

  const RecommendationMode._(String name): super(name);

  static BuiltSet<RecommendationMode> get values => _$values;
  static RecommendationMode valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RecommendationModeMixin = Object with _$RecommendationModeMixin;

