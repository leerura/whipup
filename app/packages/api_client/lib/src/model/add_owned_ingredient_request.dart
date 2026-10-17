//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_owned_ingredient_request.g.dart';

/// AddOwnedIngredientRequest
///
/// Properties:
/// * [variantId] 
@BuiltValue()
abstract class AddOwnedIngredientRequest implements Built<AddOwnedIngredientRequest, AddOwnedIngredientRequestBuilder> {
  @BuiltValueField(wireName: r'variantId')
  int get variantId;

  AddOwnedIngredientRequest._();

  factory AddOwnedIngredientRequest([void updates(AddOwnedIngredientRequestBuilder b)]) = _$AddOwnedIngredientRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddOwnedIngredientRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddOwnedIngredientRequest> get serializer => _$AddOwnedIngredientRequestSerializer();
}

class _$AddOwnedIngredientRequestSerializer implements PrimitiveSerializer<AddOwnedIngredientRequest> {
  @override
  final Iterable<Type> types = const [AddOwnedIngredientRequest, _$AddOwnedIngredientRequest];

  @override
  final String wireName = r'AddOwnedIngredientRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddOwnedIngredientRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'variantId';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AddOwnedIngredientRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddOwnedIngredientRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'variantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.variantId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AddOwnedIngredientRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddOwnedIngredientRequestBuilder();
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


