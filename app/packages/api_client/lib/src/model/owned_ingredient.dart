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
/// * [variantId] 
/// * [name] 
@BuiltValue()
abstract class OwnedIngredient implements Built<OwnedIngredient, OwnedIngredientBuilder> {
  @BuiltValueField(wireName: r'userIngredientId')
  int get userIngredientId;

  @BuiltValueField(wireName: r'variantId')
  int get variantId;

  @BuiltValueField(wireName: r'name')
  String get name;

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
    yield r'variantId';
    yield serializers.serialize(
      object.variantId,
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
        case r'variantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.variantId = valueDes;
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


