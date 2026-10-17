//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/ingredient_variant_option.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ingredient_group.g.dart';

/// IngredientGroup
///
/// Properties:
/// * [name] 
/// * [items] 
@BuiltValue()
abstract class IngredientGroup implements Built<IngredientGroup, IngredientGroupBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'items')
  BuiltList<IngredientVariantOption> get items;

  IngredientGroup._();

  factory IngredientGroup([void updates(IngredientGroupBuilder b)]) = _$IngredientGroup;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IngredientGroupBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IngredientGroup> get serializer => _$IngredientGroupSerializer();
}

class _$IngredientGroupSerializer implements PrimitiveSerializer<IngredientGroup> {
  @override
  final Iterable<Type> types = const [IngredientGroup, _$IngredientGroup];

  @override
  final String wireName = r'IngredientGroup';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IngredientGroup object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(IngredientVariantOption)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IngredientGroup object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IngredientGroupBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(IngredientVariantOption)]),
          ) as BuiltList<IngredientVariantOption>;
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
  IngredientGroup deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IngredientGroupBuilder();
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


