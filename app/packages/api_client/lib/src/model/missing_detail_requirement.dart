//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/detail_requirement_option.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'missing_detail_requirement.g.dart';

/// MissingDetailRequirement
///
/// Properties:
/// * [status] 
/// * [options] 
@BuiltValue()
abstract class MissingDetailRequirement implements Built<MissingDetailRequirement, MissingDetailRequirementBuilder> {
  @BuiltValueField(wireName: r'status')
  MissingDetailRequirementStatusEnum get status;
  // enum statusEnum {  MISSING,  };

  @BuiltValueField(wireName: r'options')
  BuiltList<DetailRequirementOption> get options;

  MissingDetailRequirement._();

  factory MissingDetailRequirement([void updates(MissingDetailRequirementBuilder b)]) = _$MissingDetailRequirement;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MissingDetailRequirementBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MissingDetailRequirement> get serializer => _$MissingDetailRequirementSerializer();
}

class _$MissingDetailRequirementSerializer implements PrimitiveSerializer<MissingDetailRequirement> {
  @override
  final Iterable<Type> types = const [MissingDetailRequirement, _$MissingDetailRequirement];

  @override
  final String wireName = r'MissingDetailRequirement';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MissingDetailRequirement object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MissingDetailRequirementStatusEnum),
    );
    yield r'options';
    yield serializers.serialize(
      object.options,
      specifiedType: const FullType(BuiltList, [FullType(DetailRequirementOption)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MissingDetailRequirement object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MissingDetailRequirementBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MissingDetailRequirementStatusEnum),
          ) as MissingDetailRequirementStatusEnum;
          result.status = valueDes;
          break;
        case r'options':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DetailRequirementOption)]),
          ) as BuiltList<DetailRequirementOption>;
          result.options.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MissingDetailRequirement deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MissingDetailRequirementBuilder();
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


class MissingDetailRequirementStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MISSING')
  static const MissingDetailRequirementStatusEnum MISSING = _$missingDetailRequirementStatusEnum_MISSING;

  static Serializer<MissingDetailRequirementStatusEnum> get serializer => _$missingDetailRequirementStatusEnumSerializer;

  const MissingDetailRequirementStatusEnum._(String name): super(name);

  static BuiltSet<MissingDetailRequirementStatusEnum> get values => _$missingDetailRequirementStatusEnumValues;
  static MissingDetailRequirementStatusEnum valueOf(String name) => _$missingDetailRequirementStatusEnumValueOf(name);
}

