//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'missing_ingredient.g.dart';

/// MissingIngredient
///
/// Properties:
/// * [ingredientId] 
/// * [name] 
@BuiltValue()
abstract class MissingIngredient implements Built<MissingIngredient, MissingIngredientBuilder> {
  @BuiltValueField(wireName: r'ingredientId')
  int get ingredientId;

  @BuiltValueField(wireName: r'name')
  String get name;

  MissingIngredient._();

  factory MissingIngredient([void updates(MissingIngredientBuilder b)]) = _$MissingIngredient;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MissingIngredientBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MissingIngredient> get serializer => _$MissingIngredientSerializer();
}

class _$MissingIngredientSerializer implements PrimitiveSerializer<MissingIngredient> {
  @override
  final Iterable<Type> types = const [MissingIngredient, _$MissingIngredient];

  @override
  final String wireName = r'MissingIngredient';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MissingIngredient object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ingredientId';
    yield serializers.serialize(
      object.ingredientId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MissingIngredient object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MissingIngredientBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MissingIngredient deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MissingIngredientBuilder();
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

