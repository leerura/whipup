//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/ingredient_group.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ingredient_group_list_response.g.dart';

/// IngredientGroupListResponse
///
/// Properties:
/// * [groups] 
@BuiltValue()
abstract class IngredientGroupListResponse implements Built<IngredientGroupListResponse, IngredientGroupListResponseBuilder> {
  @BuiltValueField(wireName: r'groups')
  BuiltList<IngredientGroup> get groups;

  IngredientGroupListResponse._();

  factory IngredientGroupListResponse([void updates(IngredientGroupListResponseBuilder b)]) = _$IngredientGroupListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IngredientGroupListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IngredientGroupListResponse> get serializer => _$IngredientGroupListResponseSerializer();
}

class _$IngredientGroupListResponseSerializer implements PrimitiveSerializer<IngredientGroupListResponse> {
  @override
  final Iterable<Type> types = const [IngredientGroupListResponse, _$IngredientGroupListResponse];

  @override
  final String wireName = r'IngredientGroupListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IngredientGroupListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'groups';
    yield serializers.serialize(
      object.groups,
      specifiedType: const FullType(BuiltList, [FullType(IngredientGroup)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IngredientGroupListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IngredientGroupListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(IngredientGroup)]),
          ) as BuiltList<IngredientGroup>;
          result.groups.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IngredientGroupListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IngredientGroupListResponseBuilder();
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


