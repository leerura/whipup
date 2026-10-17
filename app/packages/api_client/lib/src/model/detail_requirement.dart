//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/detail_requirement_option.dart';
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/ingredient_match.dart';
import 'package:api_client/src/model/satisfied_detail_requirement.dart';
import 'package:api_client/src/model/missing_detail_requirement.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'detail_requirement.g.dart';

/// DetailRequirement
///
/// Properties:
/// * [status] 
/// * [options] 
/// * [matches] 
@BuiltValue()
abstract class DetailRequirement implements Built<DetailRequirement, DetailRequirementBuilder> {
  /// One Of [MissingDetailRequirement], [SatisfiedDetailRequirement]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'status';

  static const Map<String, Type> discriminatorMapping = {
    r'MISSING': MissingDetailRequirement,
    r'SATISFIED': SatisfiedDetailRequirement,
  };

  DetailRequirement._();

  factory DetailRequirement([void updates(DetailRequirementBuilder b)]) = _$DetailRequirement;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DetailRequirementBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DetailRequirement> get serializer => _$DetailRequirementSerializer();
}

extension DetailRequirementDiscriminatorExt on DetailRequirement {
    String? get discriminatorValue {
        if (this is MissingDetailRequirement) {
            return r'MISSING';
        }
        if (this is SatisfiedDetailRequirement) {
            return r'SATISFIED';
        }
        return null;
    }
}
extension DetailRequirementBuilderDiscriminatorExt on DetailRequirementBuilder {
    String? get discriminatorValue {
        if (this is MissingDetailRequirementBuilder) {
            return r'MISSING';
        }
        if (this is SatisfiedDetailRequirementBuilder) {
            return r'SATISFIED';
        }
        return null;
    }
}

class _$DetailRequirementSerializer implements PrimitiveSerializer<DetailRequirement> {
  @override
  final Iterable<Type> types = const [DetailRequirement, _$DetailRequirement];

  @override
  final String wireName = r'DetailRequirement';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DetailRequirement object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    DetailRequirement object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  DetailRequirement deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DetailRequirementBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(DetailRequirement.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [MissingDetailRequirement, SatisfiedDetailRequirement, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'MISSING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(MissingDetailRequirement),
        ) as MissingDetailRequirement;
        oneOfType = MissingDetailRequirement;
        break;
      case r'SATISFIED':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(SatisfiedDetailRequirement),
        ) as SatisfiedDetailRequirement;
        oneOfType = SatisfiedDetailRequirement;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}


class DetailRequirementStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MISSING')
  static const DetailRequirementStatusEnum MISSING = _$detailRequirementStatusEnum_MISSING;

  static Serializer<DetailRequirementStatusEnum> get serializer => _$detailRequirementStatusEnumSerializer;

  const DetailRequirementStatusEnum._(String name): super(name);

  static BuiltSet<DetailRequirementStatusEnum> get values => _$detailRequirementStatusEnumValues;
  static DetailRequirementStatusEnum valueOf(String name) => _$detailRequirementStatusEnumValueOf(name);
}

