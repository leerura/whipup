//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owned_ingredient_selection.g.dart';

/// OwnedIngredientSelection
///
/// Properties:
/// * [ingredientId] 
@BuiltValue()
abstract class OwnedIngredientSelection implements Built<OwnedIngredientSelection, OwnedIngredientSelectionBuilder> {
  @BuiltValueField(wireName: r'ingredientId')
  int get ingredientId;

  OwnedIngredientSelection._();

  factory OwnedIngredientSelection([void updates(OwnedIngredientSelectionBuilder b)]) = _$OwnedIngredientSelection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnedIngredientSelectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnedIngredientSelection> get serializer => _$OwnedIngredientSelectionSerializer();
}

class _$OwnedIngredientSelectionSerializer implements PrimitiveSerializer<OwnedIngredientSelection> {
  @override
  final Iterable<Type> types = const [OwnedIngredientSelection, _$OwnedIngredientSelection];

  @override
  final String wireName = r'OwnedIngredientSelection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnedIngredientSelection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ingredientId';
    yield serializers.serialize(
      object.ingredientId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnedIngredientSelection object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OwnedIngredientSelectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ingredientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ingredientId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnedIngredientSelection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnedIngredientSelectionBuilder();
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


