//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe_ingredient.g.dart';

/// RecipeIngredient
///
/// Properties:
/// * [recipeIngredientId] 
/// * [ingredientId] 
/// * [displayName] 
/// * [amount] 
/// * [unit] 
/// * [displayOrder] 
/// * [owned] 
@BuiltValue()
abstract class RecipeIngredient implements Built<RecipeIngredient, RecipeIngredientBuilder> {
  @BuiltValueField(wireName: r'recipeIngredientId')
  int get recipeIngredientId;

  @BuiltValueField(wireName: r'ingredientId')
  int get ingredientId;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'unit')
  String? get unit;

  @BuiltValueField(wireName: r'displayOrder')
  int get displayOrder;

  @BuiltValueField(wireName: r'owned')
  bool get owned;

  RecipeIngredient._();

  factory RecipeIngredient([void updates(RecipeIngredientBuilder b)]) = _$RecipeIngredient;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecipeIngredientBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecipeIngredient> get serializer => _$RecipeIngredientSerializer();
}

class _$RecipeIngredientSerializer implements PrimitiveSerializer<RecipeIngredient> {
  @override
  final Iterable<Type> types = const [RecipeIngredient, _$RecipeIngredient];

  @override
  final String wireName = r'RecipeIngredient';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecipeIngredient object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recipeIngredientId';
    yield serializers.serialize(
      object.recipeIngredientId,
      specifiedType: const FullType(int),
    );
    yield r'ingredientId';
    yield serializers.serialize(
      object.ingredientId,
      specifiedType: const FullType(int),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.unit != null) {
      yield r'unit';
      yield serializers.serialize(
        object.unit,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'displayOrder';
    yield serializers.serialize(
      object.displayOrder,
      specifiedType: const FullType(int),
    );
    yield r'owned';
    yield serializers.serialize(
      object.owned,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecipeIngredient object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecipeIngredientBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recipeIngredientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.recipeIngredientId = valueDes;
          break;
        case r'ingredientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ingredientId = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.amount = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unit = valueDes;
          break;
        case r'displayOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.displayOrder = valueDes;
          break;
        case r'owned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.owned = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecipeIngredient deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecipeIngredientBuilder();
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

