//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ingredient_option.g.dart';

/// IngredientOption
///
/// Properties:
/// * [ingredientId] 
/// * [displayName] 
@BuiltValue()
abstract class IngredientOption implements Built<IngredientOption, IngredientOptionBuilder> {
  @BuiltValueField(wireName: r'ingredientId')
  int get ingredientId;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  IngredientOption._();

  factory IngredientOption([void updates(IngredientOptionBuilder b)]) = _$IngredientOption;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IngredientOptionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IngredientOption> get serializer => _$IngredientOptionSerializer();
}

class _$IngredientOptionSerializer implements PrimitiveSerializer<IngredientOption> {
  @override
  final Iterable<Type> types = const [IngredientOption, _$IngredientOption];

  @override
  final String wireName = r'IngredientOption';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IngredientOption object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ingredientId';
    yield serializers.serialize(
      object.ingredientId,
      specifiedType: const FullType(int),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IngredientOption object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IngredientOptionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ingredientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ingredientId = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IngredientOption deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IngredientOptionBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


