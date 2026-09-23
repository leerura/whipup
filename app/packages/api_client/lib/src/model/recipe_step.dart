//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe_step.g.dart';

/// RecipeStep
///
/// Properties:
/// * [order] 
/// * [content] 
@BuiltValue()
abstract class RecipeStep implements Built<RecipeStep, RecipeStepBuilder> {
  @BuiltValueField(wireName: r'order')
  int get order;

  @BuiltValueField(wireName: r'content')
  String get content;

  RecipeStep._();

  factory RecipeStep([void updates(RecipeStepBuilder b)]) = _$RecipeStep;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecipeStepBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecipeStep> get serializer => _$RecipeStepSerializer();
}

class _$RecipeStepSerializer implements PrimitiveSerializer<RecipeStep> {
  @override
  final Iterable<Type> types = const [RecipeStep, _$RecipeStep];

  @override
  final String wireName = r'RecipeStep';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecipeStep object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'order';
    yield serializers.serialize(
      object.order,
      specifiedType: const FullType(int),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecipeStep object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecipeStepBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.order = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecipeStep deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecipeStepBuilder();
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


