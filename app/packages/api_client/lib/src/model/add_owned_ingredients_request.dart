//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/owned_ingredient_selection.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_owned_ingredients_request.g.dart';

/// AddOwnedIngredientsRequest
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class AddOwnedIngredientsRequest implements Built<AddOwnedIngredientsRequest, AddOwnedIngredientsRequestBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<OwnedIngredientSelection> get items;

  AddOwnedIngredientsRequest._();

  factory AddOwnedIngredientsRequest([void updates(AddOwnedIngredientsRequestBuilder b)]) = _$AddOwnedIngredientsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddOwnedIngredientsRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddOwnedIngredientsRequest> get serializer => _$AddOwnedIngredientsRequestSerializer();
}

class _$AddOwnedIngredientsRequestSerializer implements PrimitiveSerializer<AddOwnedIngredientsRequest> {
  @override
  final Iterable<Type> types = const [AddOwnedIngredientsRequest, _$AddOwnedIngredientsRequest];

  @override
  final String wireName = r'AddOwnedIngredientsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddOwnedIngredientsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(OwnedIngredientSelection)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AddOwnedIngredientsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddOwnedIngredientsRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OwnedIngredientSelection)]),
          ) as BuiltList<OwnedIngredientSelection>;
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
  AddOwnedIngredientsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddOwnedIngredientsRequestBuilder();
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


