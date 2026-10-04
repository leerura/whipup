//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'missing_substitute.g.dart';

/// MissingSubstitute
///
/// Properties:
/// * [name] 
@BuiltValue()
abstract class MissingSubstitute implements Built<MissingSubstitute, MissingSubstituteBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  MissingSubstitute._();

  factory MissingSubstitute([void updates(MissingSubstituteBuilder b)]) = _$MissingSubstitute;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MissingSubstituteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MissingSubstitute> get serializer => _$MissingSubstituteSerializer();
}

class _$MissingSubstituteSerializer implements PrimitiveSerializer<MissingSubstitute> {
  @override
  final Iterable<Type> types = const [MissingSubstitute, _$MissingSubstitute];

  @override
  final String wireName = r'MissingSubstitute';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MissingSubstitute object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MissingSubstitute object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MissingSubstituteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MissingSubstitute deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MissingSubstituteBuilder();
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


