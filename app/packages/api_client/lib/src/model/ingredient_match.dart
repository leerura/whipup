//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ingredient_match.g.dart';

/// IngredientMatch
///
/// Properties:
/// * [type] 
/// * [requiredName] 
/// * [ownedName] 
@BuiltValue()
abstract class IngredientMatch implements Built<IngredientMatch, IngredientMatchBuilder> {
  @BuiltValueField(wireName: r'type')
  IngredientMatchTypeEnum get type;
  // enum typeEnum {  DIRECT,  PREPARATION,  SUBSTITUTE,  };

  @BuiltValueField(wireName: r'requiredName')
  String get requiredName;

  @BuiltValueField(wireName: r'ownedName')
  String get ownedName;

  IngredientMatch._();

  factory IngredientMatch([void updates(IngredientMatchBuilder b)]) = _$IngredientMatch;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IngredientMatchBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IngredientMatch> get serializer => _$IngredientMatchSerializer();
}

class _$IngredientMatchSerializer implements PrimitiveSerializer<IngredientMatch> {
  @override
  final Iterable<Type> types = const [IngredientMatch, _$IngredientMatch];

  @override
  final String wireName = r'IngredientMatch';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IngredientMatch object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(IngredientMatchTypeEnum),
    );
    yield r'requiredName';
    yield serializers.serialize(
      object.requiredName,
      specifiedType: const FullType(String),
    );
    yield r'ownedName';
    yield serializers.serialize(
      object.ownedName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IngredientMatch object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IngredientMatchBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IngredientMatchTypeEnum),
          ) as IngredientMatchTypeEnum;
          result.type = valueDes;
          break;
        case r'requiredName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requiredName = valueDes;
          break;
        case r'ownedName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownedName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IngredientMatch deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IngredientMatchBuilder();
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


class IngredientMatchTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DIRECT')
  static const IngredientMatchTypeEnum DIRECT = _$ingredientMatchTypeEnum_DIRECT;
  @BuiltValueEnumConst(wireName: r'PREPARATION')
  static const IngredientMatchTypeEnum PREPARATION = _$ingredientMatchTypeEnum_PREPARATION;
  @BuiltValueEnumConst(wireName: r'SUBSTITUTE')
  static const IngredientMatchTypeEnum SUBSTITUTE = _$ingredientMatchTypeEnum_SUBSTITUTE;

  static Serializer<IngredientMatchTypeEnum> get serializer => _$ingredientMatchTypeEnumSerializer;

  const IngredientMatchTypeEnum._(String name): super(name);

  static BuiltSet<IngredientMatchTypeEnum> get values => _$ingredientMatchTypeEnumValues;
  static IngredientMatchTypeEnum valueOf(String name) => _$ingredientMatchTypeEnumValueOf(name);
}

