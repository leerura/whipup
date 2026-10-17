//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/detail_requirement_option.dart';
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/ingredient_match.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'satisfied_detail_requirement.g.dart';

/// SatisfiedDetailRequirement
///
/// Properties:
/// * [status] 
/// * [options] 
/// * [matches] 
@BuiltValue()
abstract class SatisfiedDetailRequirement implements Built<SatisfiedDetailRequirement, SatisfiedDetailRequirementBuilder> {
  @BuiltValueField(wireName: r'status')
  SatisfiedDetailRequirementStatusEnum get status;
  // enum statusEnum {  SATISFIED,  };

  @BuiltValueField(wireName: r'options')
  BuiltList<DetailRequirementOption> get options;

  @BuiltValueField(wireName: r'matches')
  BuiltList<IngredientMatch> get matches;

  SatisfiedDetailRequirement._();

  factory SatisfiedDetailRequirement([void updates(SatisfiedDetailRequirementBuilder b)]) = _$SatisfiedDetailRequirement;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SatisfiedDetailRequirementBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SatisfiedDetailRequirement> get serializer => _$SatisfiedDetailRequirementSerializer();
}

class _$SatisfiedDetailRequirementSerializer implements PrimitiveSerializer<SatisfiedDetailRequirement> {
  @override
  final Iterable<Type> types = const [SatisfiedDetailRequirement, _$SatisfiedDetailRequirement];

  @override
  final String wireName = r'SatisfiedDetailRequirement';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SatisfiedDetailRequirement object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(SatisfiedDetailRequirementStatusEnum),
    );
    yield r'options';
    yield serializers.serialize(
      object.options,
      specifiedType: const FullType(BuiltList, [FullType(DetailRequirementOption)]),
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
    SatisfiedDetailRequirement object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SatisfiedDetailRequirementBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SatisfiedDetailRequirementStatusEnum),
          ) as SatisfiedDetailRequirementStatusEnum;
          result.status = valueDes;
          break;
        case r'options':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DetailRequirementOption)]),
          ) as BuiltList<DetailRequirementOption>;
          result.options.replace(valueDes);
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
  SatisfiedDetailRequirement deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SatisfiedDetailRequirementBuilder();
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


class SatisfiedDetailRequirementStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SATISFIED')
  static const SatisfiedDetailRequirementStatusEnum SATISFIED = _$satisfiedDetailRequirementStatusEnum_SATISFIED;

  static Serializer<SatisfiedDetailRequirementStatusEnum> get serializer => _$satisfiedDetailRequirementStatusEnumSerializer;

  const SatisfiedDetailRequirementStatusEnum._(String name): super(name);

  static BuiltSet<SatisfiedDetailRequirementStatusEnum> get values => _$satisfiedDetailRequirementStatusEnumValues;
  static SatisfiedDetailRequirementStatusEnum valueOf(String name) => _$satisfiedDetailRequirementStatusEnumValueOf(name);
}

