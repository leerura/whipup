//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ingredient_variant_option.g.dart';

/// IngredientVariantOption
///
/// Properties:
/// * [variantId] 
/// * [name] 
@BuiltValue()
abstract class IngredientVariantOption implements Built<IngredientVariantOption, IngredientVariantOptionBuilder> {
  @BuiltValueField(wireName: r'variantId')
  int get variantId;

  @BuiltValueField(wireName: r'name')
  String get name;

  IngredientVariantOption._();

  factory IngredientVariantOption([void updates(IngredientVariantOptionBuilder b)]) = _$IngredientVariantOption;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IngredientVariantOptionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IngredientVariantOption> get serializer => _$IngredientVariantOptionSerializer();
}

class _$IngredientVariantOptionSerializer implements PrimitiveSerializer<IngredientVariantOption> {
  @override
  final Iterable<Type> types = const [IngredientVariantOption, _$IngredientVariantOption];

  @override
  final String wireName = r'IngredientVariantOption';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IngredientVariantOption object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'variantId';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IngredientVariantOption object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IngredientVariantOptionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'variantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.variantId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IngredientVariantOption deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IngredientVariantOptionBuilder();
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


