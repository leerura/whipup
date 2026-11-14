//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/requirement_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recommendation_item.g.dart';

/// RecommendationItem
///
/// Properties:
/// * [recipeId] 
/// * [name] 
/// * [thumbnailUrl] 
/// * [missingCount] 
/// * [requirementResults] 
/// * [sourceChannelName] - Original YouTube channel name, used to tell apart recipes with the same name.
/// * [sourceChannelThumbnailUrl] - Original YouTube channel profile image. Clients fall back to the channel name's first letter.
@BuiltValue()
abstract class RecommendationItem implements Built<RecommendationItem, RecommendationItemBuilder> {
  @BuiltValueField(wireName: r'recipeId')
  int get recipeId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'thumbnailUrl')
  String get thumbnailUrl;

  @BuiltValueField(wireName: r'missingCount')
  int get missingCount;

  @BuiltValueField(wireName: r'requirementResults')
  BuiltList<RequirementResult> get requirementResults;

  /// Original YouTube channel name, used to tell apart recipes with the same name.
  @BuiltValueField(wireName: r'sourceChannelName')
  String? get sourceChannelName;

  /// Original YouTube channel profile image. Clients fall back to the channel name's first letter.
  @BuiltValueField(wireName: r'sourceChannelThumbnailUrl')
  String? get sourceChannelThumbnailUrl;

  RecommendationItem._();

  factory RecommendationItem([void updates(RecommendationItemBuilder b)]) = _$RecommendationItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecommendationItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecommendationItem> get serializer => _$RecommendationItemSerializer();
}

class _$RecommendationItemSerializer implements PrimitiveSerializer<RecommendationItem> {
  @override
  final Iterable<Type> types = const [RecommendationItem, _$RecommendationItem];

  @override
  final String wireName = r'RecommendationItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecommendationItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recipeId';
    yield serializers.serialize(
      object.recipeId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'thumbnailUrl';
    yield serializers.serialize(
      object.thumbnailUrl,
      specifiedType: const FullType(String),
    );
    yield r'missingCount';
    yield serializers.serialize(
      object.missingCount,
      specifiedType: const FullType(int),
    );
    yield r'requirementResults';
    yield serializers.serialize(
      object.requirementResults,
      specifiedType: const FullType(BuiltList, [FullType(RequirementResult)]),
    );
    if (object.sourceChannelName != null) {
      yield r'sourceChannelName';
      yield serializers.serialize(
        object.sourceChannelName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sourceChannelThumbnailUrl != null) {
      yield r'sourceChannelThumbnailUrl';
      yield serializers.serialize(
        object.sourceChannelThumbnailUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RecommendationItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecommendationItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recipeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.recipeId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'thumbnailUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.thumbnailUrl = valueDes;
          break;
        case r'missingCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.missingCount = valueDes;
          break;
        case r'requirementResults':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RequirementResult)]),
          ) as BuiltList<RequirementResult>;
          result.requirementResults.replace(valueDes);
          break;
        case r'sourceChannelName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceChannelName = valueDes;
          break;
        case r'sourceChannelThumbnailUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceChannelThumbnailUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecommendationItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecommendationItemBuilder();
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


