//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'daily_menu_request.g.dart';

/// DailyMenuRequest
///
/// Properties:
/// * [recipeId] 
@BuiltValue()
abstract class DailyMenuRequest implements Built<DailyMenuRequest, DailyMenuRequestBuilder> {
  @BuiltValueField(wireName: r'recipeId')
  int get recipeId;

  DailyMenuRequest._();

  factory DailyMenuRequest([void updates(DailyMenuRequestBuilder b)]) = _$DailyMenuRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DailyMenuRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DailyMenuRequest> get serializer => _$DailyMenuRequestSerializer();
}

class _$DailyMenuRequestSerializer implements PrimitiveSerializer<DailyMenuRequest> {
  @override
  final Iterable<Type> types = const [DailyMenuRequest, _$DailyMenuRequest];

  @override
  final String wireName = r'DailyMenuRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DailyMenuRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recipeId';
    yield serializers.serialize(
      object.recipeId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DailyMenuRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DailyMenuRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recipeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.recipeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DailyMenuRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DailyMenuRequestBuilder();
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


