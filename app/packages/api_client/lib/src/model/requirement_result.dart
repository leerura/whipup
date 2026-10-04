//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/missing_requirement_result.dart';
import 'package:api_client/src/model/missing_option.dart';
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/ingredient_match.dart';
import 'package:api_client/src/model/satisfied_requirement_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'requirement_result.g.dart';

/// RequirementResult
///
/// Properties:
/// * [status] 
/// * [matches] 
/// * [missingOptions] 
@BuiltValue()
abstract class RequirementResult implements Built<RequirementResult, RequirementResultBuilder> {
  /// One Of [MissingRequirementResult], [SatisfiedRequirementResult]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'status';

  static const Map<String, Type> discriminatorMapping = {
    r'MISSING': MissingRequirementResult,
    r'SATISFIED': SatisfiedRequirementResult,
  };

  RequirementResult._();

  factory RequirementResult([void updates(RequirementResultBuilder b)]) = _$RequirementResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RequirementResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RequirementResult> get serializer => _$RequirementResultSerializer();
}

extension RequirementResultDiscriminatorExt on RequirementResult {
    String? get discriminatorValue {
        if (this is MissingRequirementResult) {
            return r'MISSING';
        }
        if (this is SatisfiedRequirementResult) {
            return r'SATISFIED';
        }
        return null;
    }
}
extension RequirementResultBuilderDiscriminatorExt on RequirementResultBuilder {
    String? get discriminatorValue {
        if (this is MissingRequirementResultBuilder) {
            return r'MISSING';
        }
        if (this is SatisfiedRequirementResultBuilder) {
            return r'SATISFIED';
        }
        return null;
    }
}

class _$RequirementResultSerializer implements PrimitiveSerializer<RequirementResult> {
  @override
  final Iterable<Type> types = const [RequirementResult, _$RequirementResult];

  @override
  final String wireName = r'RequirementResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RequirementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    RequirementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  RequirementResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RequirementResultBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(RequirementResult.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [MissingRequirementResult, SatisfiedRequirementResult, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'MISSING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(MissingRequirementResult),
        ) as MissingRequirementResult;
        oneOfType = MissingRequirementResult;
        break;
      case r'SATISFIED':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(SatisfiedRequirementResult),
        ) as SatisfiedRequirementResult;
        oneOfType = SatisfiedRequirementResult;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}


class RequirementResultStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MISSING')
  static const RequirementResultStatusEnum MISSING = _$requirementResultStatusEnum_MISSING;

  static Serializer<RequirementResultStatusEnum> get serializer => _$requirementResultStatusEnumSerializer;

  const RequirementResultStatusEnum._(String name): super(name);

  static BuiltSet<RequirementResultStatusEnum> get values => _$requirementResultStatusEnumValues;
  static RequirementResultStatusEnum valueOf(String name) => _$requirementResultStatusEnumValueOf(name);
}

