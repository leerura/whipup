//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/ingredient_match.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'satisfied_requirement_result.g.dart';

/// SatisfiedRequirementResult
///
/// Properties:
/// * [status] 
/// * [matches] 
@BuiltValue()
abstract class SatisfiedRequirementResult implements Built<SatisfiedRequirementResult, SatisfiedRequirementResultBuilder> {
  @BuiltValueField(wireName: r'status')
  SatisfiedRequirementResultStatusEnum get status;
  // enum statusEnum {  SATISFIED,  };

  @BuiltValueField(wireName: r'matches')
  BuiltList<IngredientMatch> get matches;

  SatisfiedRequirementResult._();

  factory SatisfiedRequirementResult([void updates(SatisfiedRequirementResultBuilder b)]) = _$SatisfiedRequirementResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SatisfiedRequirementResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SatisfiedRequirementResult> get serializer => _$SatisfiedRequirementResultSerializer();
}

class _$SatisfiedRequirementResultSerializer implements PrimitiveSerializer<SatisfiedRequirementResult> {
  @override
  final Iterable<Type> types = const [SatisfiedRequirementResult, _$SatisfiedRequirementResult];

  @override
  final String wireName = r'SatisfiedRequirementResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SatisfiedRequirementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(SatisfiedRequirementResultStatusEnum),
    );
    yield r'matches';
    yield serializers.serialize(
      object.matches,
      specifiedType: const FullType(BuiltList, [FullType(IngredientMatch)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SatisfiedRequirementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SatisfiedRequirementResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SatisfiedRequirementResultStatusEnum),
          ) as SatisfiedRequirementResultStatusEnum;
          result.status = valueDes;
          break;
        case r'matches':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(IngredientMatch)]),
          ) as BuiltList<IngredientMatch>;
          result.matches.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SatisfiedRequirementResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SatisfiedRequirementResultBuilder();
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


class SatisfiedRequirementResultStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SATISFIED')
  static const SatisfiedRequirementResultStatusEnum SATISFIED = _$satisfiedRequirementResultStatusEnum_SATISFIED;

  static Serializer<SatisfiedRequirementResultStatusEnum> get serializer => _$satisfiedRequirementResultStatusEnumSerializer;

  const SatisfiedRequirementResultStatusEnum._(String name): super(name);

  static BuiltSet<SatisfiedRequirementResultStatusEnum> get values => _$satisfiedRequirementResultStatusEnumValues;
  static SatisfiedRequirementResultStatusEnum valueOf(String name) => _$satisfiedRequirementResultStatusEnumValueOf(name);
}

