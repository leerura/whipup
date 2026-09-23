//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/owned_ingredient.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owned_ingredient_list_response.g.dart';

/// OwnedIngredientListResponse
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class OwnedIngredientListResponse implements Built<OwnedIngredientListResponse, OwnedIngredientListResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<OwnedIngredient> get items;

  OwnedIngredientListResponse._();

  factory OwnedIngredientListResponse([void updates(OwnedIngredientListResponseBuilder b)]) = _$OwnedIngredientListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnedIngredientListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnedIngredientListResponse> get serializer => _$OwnedIngredientListResponseSerializer();
}

class _$OwnedIngredientListResponseSerializer implements PrimitiveSerializer<OwnedIngredientListResponse> {
  @override
  final Iterable<Type> types = const [OwnedIngredientListResponse, _$OwnedIngredientListResponse];

  @override
  final String wireName = r'OwnedIngredientListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnedIngredientListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(OwnedIngredient)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnedIngredientListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OwnedIngredientListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OwnedIngredient)]),
          ) as BuiltList<OwnedIngredient>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnedIngredientListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnedIngredientListResponseBuilder();
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

