//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/recommendation_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recommendation_page.g.dart';

/// RecommendationPage
///
/// Properties:
/// * [items] 
/// * [page] 
/// * [size] 
/// * [hasNext] 
@BuiltValue()
abstract class RecommendationPage implements Built<RecommendationPage, RecommendationPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<RecommendationItem> get items;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'size')
  int get size;

  @BuiltValueField(wireName: r'hasNext')
  bool get hasNext;

  RecommendationPage._();

  factory RecommendationPage([void updates(RecommendationPageBuilder b)]) = _$RecommendationPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecommendationPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecommendationPage> get serializer => _$RecommendationPageSerializer();
}

class _$RecommendationPageSerializer implements PrimitiveSerializer<RecommendationPage> {
  @override
  final Iterable<Type> types = const [RecommendationPage, _$RecommendationPage];

  @override
  final String wireName = r'RecommendationPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecommendationPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(RecommendationItem)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(int),
    );
    yield r'size';
    yield serializers.serialize(
      object.size,
      specifiedType: const FullType(int),
    );
    yield r'hasNext';
    yield serializers.serialize(
      object.hasNext,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecommendationPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecommendationPageBuilder result,
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
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.page = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.size = valueDes;
          break;
        case r'hasNext':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasNext = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecommendationPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecommendationPageBuilder();
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

