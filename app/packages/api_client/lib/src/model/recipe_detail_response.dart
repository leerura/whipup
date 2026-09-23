//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/recipe_step.dart';
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/recipe_ingredient.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe_detail_response.g.dart';

/// RecipeDetailResponse
///
/// Properties:
/// * [recipeId] 
/// * [name] 
/// * [shortsReference] 
/// * [thumbnailUrl] 
/// * [missingCount] 
/// * [ingredients] 
/// * [steps] 
@BuiltValue()
abstract class RecipeDetailResponse implements Built<RecipeDetailResponse, RecipeDetailResponseBuilder> {
  @BuiltValueField(wireName: r'recipeId')
  int get recipeId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'shortsReference')
  String get shortsReference;

  @BuiltValueField(wireName: r'thumbnailUrl')
  String get thumbnailUrl;

  @BuiltValueField(wireName: r'missingCount')
  int get missingCount;

  @BuiltValueField(wireName: r'ingredients')
  BuiltList<RecipeIngredient> get ingredients;

  @BuiltValueField(wireName: r'steps')
  BuiltList<RecipeStep> get steps;

  RecipeDetailResponse._();

  factory RecipeDetailResponse([void updates(RecipeDetailResponseBuilder b)]) = _$RecipeDetailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecipeDetailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecipeDetailResponse> get serializer => _$RecipeDetailResponseSerializer();
}

class _$RecipeDetailResponseSerializer implements PrimitiveSerializer<RecipeDetailResponse> {
  @override
  final Iterable<Type> types = const [RecipeDetailResponse, _$RecipeDetailResponse];

  @override
  final String wireName = r'RecipeDetailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecipeDetailResponse object, {
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
    yield r'shortsReference';
    yield serializers.serialize(
      object.shortsReference,
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
    yield r'ingredients';
    yield serializers.serialize(
      object.ingredients,
      specifiedType: const FullType(BuiltList, [FullType(RecipeIngredient)]),
    );
    yield r'steps';
    yield serializers.serialize(
      object.steps,
      specifiedType: const FullType(BuiltList, [FullType(RecipeStep)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecipeDetailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecipeDetailResponseBuilder result,
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
        case r'shortsReference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shortsReference = valueDes;
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
        case r'ingredients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RecipeIngredient)]),
          ) as BuiltList<RecipeIngredient>;
          result.ingredients.replace(valueDes);
          break;
        case r'steps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RecipeStep)]),
          ) as BuiltList<RecipeStep>;
          result.steps.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecipeDetailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecipeDetailResponseBuilder();
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


