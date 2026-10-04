//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'detail_ingredient_display.g.dart';

/// DetailIngredientDisplay
///
/// Properties:
/// * [displayName] 
/// * [rawText] 
/// * [amount] 
/// * [unit] 
@BuiltValue()
abstract class DetailIngredientDisplay implements Built<DetailIngredientDisplay, DetailIngredientDisplayBuilder> {
  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'rawText')
  String get rawText;

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'unit')
  String? get unit;

  DetailIngredientDisplay._();

  factory DetailIngredientDisplay([void updates(DetailIngredientDisplayBuilder b)]) = _$DetailIngredientDisplay;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DetailIngredientDisplayBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DetailIngredientDisplay> get serializer => _$DetailIngredientDisplaySerializer();
}

class _$DetailIngredientDisplaySerializer implements PrimitiveSerializer<DetailIngredientDisplay> {
  @override
  final Iterable<Type> types = const [DetailIngredientDisplay, _$DetailIngredientDisplay];

  @override
  final String wireName = r'DetailIngredientDisplay';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DetailIngredientDisplay object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'rawText';
    yield serializers.serialize(
      object.rawText,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    DetailIngredientDisplay object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DetailIngredientDisplayBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'rawText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rawText = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DetailIngredientDisplay deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DetailIngredientDisplayBuilder();
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


