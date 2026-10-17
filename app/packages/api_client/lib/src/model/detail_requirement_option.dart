//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/detail_ingredient_display.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'detail_requirement_option.g.dart';

/// DetailRequirementOption
///
/// Properties:
/// * [displayName] 
/// * [rawText] 
/// * [amount] 
/// * [unit] 
/// * [substitutes] 
@BuiltValue()
abstract class DetailRequirementOption implements Built<DetailRequirementOption, DetailRequirementOptionBuilder> {
  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'rawText')
  String get rawText;

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'unit')
  String? get unit;

  @BuiltValueField(wireName: r'substitutes')
  BuiltList<DetailIngredientDisplay> get substitutes;

  DetailRequirementOption._();

  factory DetailRequirementOption([void updates(DetailRequirementOptionBuilder b)]) = _$DetailRequirementOption;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DetailRequirementOptionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DetailRequirementOption> get serializer => _$DetailRequirementOptionSerializer();
}

class _$DetailRequirementOptionSerializer implements PrimitiveSerializer<DetailRequirementOption> {
  @override
  final Iterable<Type> types = const [DetailRequirementOption, _$DetailRequirementOption];

  @override
  final String wireName = r'DetailRequirementOption';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DetailRequirementOption object, {
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
    yield r'substitutes';
    yield serializers.serialize(
      object.substitutes,
      specifiedType: const FullType(BuiltList, [FullType(DetailIngredientDisplay)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DetailRequirementOption object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DetailRequirementOptionBuilder result,
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
        case r'substitutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DetailIngredientDisplay)]),
          ) as BuiltList<DetailIngredientDisplay>;
          result.substitutes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DetailRequirementOption deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DetailRequirementOptionBuilder();
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


