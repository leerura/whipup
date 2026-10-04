//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:api_client/src/model/missing_substitute.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'missing_option.g.dart';

/// MissingOption
///
/// Properties:
/// * [requiredName] 
/// * [substitutes] 
@BuiltValue()
abstract class MissingOption implements Built<MissingOption, MissingOptionBuilder> {
  @BuiltValueField(wireName: r'requiredName')
  String get requiredName;

  @BuiltValueField(wireName: r'substitutes')
  BuiltList<MissingSubstitute> get substitutes;

  MissingOption._();

  factory MissingOption([void updates(MissingOptionBuilder b)]) = _$MissingOption;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MissingOptionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MissingOption> get serializer => _$MissingOptionSerializer();
}

class _$MissingOptionSerializer implements PrimitiveSerializer<MissingOption> {
  @override
  final Iterable<Type> types = const [MissingOption, _$MissingOption];

  @override
  final String wireName = r'MissingOption';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MissingOption object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'requiredName';
    yield serializers.serialize(
      object.requiredName,
      specifiedType: const FullType(String),
    );
    yield r'substitutes';
    yield serializers.serialize(
      object.substitutes,
      specifiedType: const FullType(BuiltList, [FullType(MissingSubstitute)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MissingOption object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MissingOptionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'requiredName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requiredName = valueDes;
          break;
        case r'substitutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MissingSubstitute)]),
          ) as BuiltList<MissingSubstitute>;
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
  MissingOption deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MissingOptionBuilder();
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


