//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/recommendation_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recommendation_list_response.g.dart';

/// RecommendationListResponse
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class RecommendationListResponse implements Built<RecommendationListResponse, RecommendationListResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<RecommendationItem> get items;

  RecommendationListResponse._();

  factory RecommendationListResponse([void updates(RecommendationListResponseBuilder b)]) = _$RecommendationListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecommendationListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecommendationListResponse> get serializer => _$RecommendationListResponseSerializer();
}

class _$RecommendationListResponseSerializer implements PrimitiveSerializer<RecommendationListResponse> {
  @override
  final Iterable<Type> types = const [RecommendationListResponse, _$RecommendationListResponse];

  @override
  final String wireName = r'RecommendationListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecommendationListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(RecommendationItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecommendationListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecommendationListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RecommendationItem)]),
          ) as BuiltList<RecommendationItem>;
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
  RecommendationListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecommendationListResponseBuilder();
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


