//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/missing_ingredient.dart';
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
/// * [missingIngredients] 
@BuiltValue()
abstract class RecommendationItem implements Built<RecommendationItem, RecommendationItemBuilder> {
  @BuiltValueField(wireName: r'recipeId')
  int get recipeId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'thumbnailUrl')
  String get thumbnailUrl;

  @BuiltValueField(wireName: r'missingCount')
  RecommendationItemMissingCountEnum get missingCount;
  // enum missingCountEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'missingIngredients')
  BuiltList<MissingIngredient> get missingIngredients;

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
      specifiedType: const FullType(RecommendationItemMissingCountEnum),
    );
    yield r'missingIngredients';
    yield serializers.serialize(
      object.missingIngredients,
      specifiedType: const FullType(BuiltList, [FullType(MissingIngredient)]),
    );
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
            specifiedType: const FullType(RecommendationItemMissingCountEnum),
          ) as RecommendationItemMissingCountEnum;
          result.missingCount = valueDes;
          break;
        case r'missingIngredients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MissingIngredient)]),
          ) as BuiltList<MissingIngredient>;
          result.missingIngredients.replace(valueDes);
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

class RecommendationItemMissingCountEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const RecommendationItemMissingCountEnum number0 = _$recommendationItemMissingCountEnum_number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const RecommendationItemMissingCountEnum number1 = _$recommendationItemMissingCountEnum_number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const RecommendationItemMissingCountEnum number2 = _$recommendationItemMissingCountEnum_number2;

  static Serializer<RecommendationItemMissingCountEnum> get serializer => _$recommendationItemMissingCountEnumSerializer;

  const RecommendationItemMissingCountEnum._(String name): super(name);

  static BuiltSet<RecommendationItemMissingCountEnum> get values => _$recommendationItemMissingCountEnumValues;
  static RecommendationItemMissingCountEnum valueOf(String name) => _$recommendationItemMissingCountEnumValueOf(name);
}

