//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/missing_option.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'missing_requirement_result.g.dart';

/// MissingRequirementResult
///
/// Properties:
/// * [status] 
/// * [missingOptions] 
@BuiltValue()
abstract class MissingRequirementResult implements Built<MissingRequirementResult, MissingRequirementResultBuilder> {
  @BuiltValueField(wireName: r'status')
  MissingRequirementResultStatusEnum get status;
  // enum statusEnum {  MISSING,  };

  @BuiltValueField(wireName: r'missingOptions')
  BuiltList<MissingOption> get missingOptions;

  MissingRequirementResult._();

  factory MissingRequirementResult([void updates(MissingRequirementResultBuilder b)]) = _$MissingRequirementResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MissingRequirementResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MissingRequirementResult> get serializer => _$MissingRequirementResultSerializer();
}

class _$MissingRequirementResultSerializer implements PrimitiveSerializer<MissingRequirementResult> {
  @override
  final Iterable<Type> types = const [MissingRequirementResult, _$MissingRequirementResult];

  @override
  final String wireName = r'MissingRequirementResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MissingRequirementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MissingRequirementResultStatusEnum),
    );
    yield r'missingOptions';
    yield serializers.serialize(
      object.missingOptions,
      specifiedType: const FullType(BuiltList, [FullType(MissingOption)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MissingRequirementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MissingRequirementResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MissingRequirementResultStatusEnum),
          ) as MissingRequirementResultStatusEnum;
          result.status = valueDes;
          break;
        case r'missingOptions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MissingOption)]),
          ) as BuiltList<MissingOption>;
          result.missingOptions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MissingRequirementResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MissingRequirementResultBuilder();
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


class MissingRequirementResultStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MISSING')
  static const MissingRequirementResultStatusEnum MISSING = _$missingRequirementResultStatusEnum_MISSING;

  static Serializer<MissingRequirementResultStatusEnum> get serializer => _$missingRequirementResultStatusEnumSerializer;

  const MissingRequirementResultStatusEnum._(String name): super(name);

  static BuiltSet<MissingRequirementResultStatusEnum> get values => _$missingRequirementResultStatusEnumValues;
  static MissingRequirementResultStatusEnum valueOf(String name) => _$missingRequirementResultStatusEnumValueOf(name);
}

