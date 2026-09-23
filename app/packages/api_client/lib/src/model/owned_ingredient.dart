//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owned_ingredient.g.dart';

/// OwnedIngredient
///
/// Properties:
/// * [userIngredientId] 
/// * [ingredientId] 
/// * [displayName] 
@BuiltValue()
abstract class OwnedIngredient implements Built<OwnedIngredient, OwnedIngredientBuilder> {
  @BuiltValueField(wireName: r'userIngredientId')
  int get userIngredientId;

  @BuiltValueField(wireName: r'ingredientId')
  int get ingredientId;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  OwnedIngredient._();

  factory OwnedIngredient([void updates(OwnedIngredientBuilder b)]) = _$OwnedIngredient;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnedIngredientBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnedIngredient> get serializer => _$OwnedIngredientSerializer();
}

class _$OwnedIngredientSerializer implements PrimitiveSerializer<OwnedIngredient> {
  @override
  final Iterable<Type> types = const [OwnedIngredient, _$OwnedIngredient];

  @override
  final String wireName = r'OwnedIngredient';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnedIngredient object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userIngredientId';
    yield serializers.serialize(
      object.userIngredientId,
      specifiedType: const FullType(int),
    );
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
    OwnedIngredient object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OwnedIngredientBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userIngredientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.userIngredientId = valueDes;
          break;
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
  OwnedIngredient deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnedIngredientBuilder();
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


