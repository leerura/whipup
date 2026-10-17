// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirement_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RequirementResultStatusEnum _$requirementResultStatusEnum_MISSING =
    const RequirementResultStatusEnum._('MISSING');

RequirementResultStatusEnum _$requirementResultStatusEnumValueOf(String name) {
  switch (name) {
    case 'MISSING':
      return _$requirementResultStatusEnum_MISSING;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RequirementResultStatusEnum>
    _$requirementResultStatusEnumValues =
    BuiltSet<RequirementResultStatusEnum>(const <RequirementResultStatusEnum>[
  _$requirementResultStatusEnum_MISSING,
]);

Serializer<RequirementResultStatusEnum>
    _$requirementResultStatusEnumSerializer =
    _$RequirementResultStatusEnumSerializer();

class _$RequirementResultStatusEnumSerializer
    implements PrimitiveSerializer<RequirementResultStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MISSING': 'MISSING',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MISSING': 'MISSING',
  };

  @override
  final Iterable<Type> types = const <Type>[RequirementResultStatusEnum];
  @override
  final String wireName = 'RequirementResultStatusEnum';

  @override
  Object serialize(Serializers serializers, RequirementResultStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RequirementResultStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RequirementResultStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RequirementResult extends RequirementResult {
  @override
  final OneOf oneOf;

  factory _$RequirementResult(
          [void Function(RequirementResultBuilder)? updates]) =>
      (RequirementResultBuilder()..update(updates))._build();

  _$RequirementResult._({required this.oneOf}) : super._();
  @override
  RequirementResult rebuild(void Function(RequirementResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RequirementResultBuilder toBuilder() =>
      RequirementResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RequirementResult && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RequirementResult')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class RequirementResultBuilder
    implements Builder<RequirementResult, RequirementResultBuilder> {
  _$RequirementResult? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  RequirementResultBuilder() {
    RequirementResult._defaults(this);
  }

  RequirementResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RequirementResult other) {
    _$v = other as _$RequirementResult;
  }

  @override
  void update(void Function(RequirementResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RequirementResult build() => _build();

  _$RequirementResult _build() {
    final _$result = _$v ??
        _$RequirementResult._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'RequirementResult', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
