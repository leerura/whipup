// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missing_requirement_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MissingRequirementResultStatusEnum
    _$missingRequirementResultStatusEnum_MISSING =
    const MissingRequirementResultStatusEnum._('MISSING');

MissingRequirementResultStatusEnum _$missingRequirementResultStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'MISSING':
      return _$missingRequirementResultStatusEnum_MISSING;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MissingRequirementResultStatusEnum>
    _$missingRequirementResultStatusEnumValues = BuiltSet<
        MissingRequirementResultStatusEnum>(const <MissingRequirementResultStatusEnum>[
  _$missingRequirementResultStatusEnum_MISSING,
]);

Serializer<MissingRequirementResultStatusEnum>
    _$missingRequirementResultStatusEnumSerializer =
    _$MissingRequirementResultStatusEnumSerializer();

class _$MissingRequirementResultStatusEnumSerializer
    implements PrimitiveSerializer<MissingRequirementResultStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MISSING': 'MISSING',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MISSING': 'MISSING',
  };

  @override
  final Iterable<Type> types = const <Type>[MissingRequirementResultStatusEnum];
  @override
  final String wireName = 'MissingRequirementResultStatusEnum';

  @override
  Object serialize(
          Serializers serializers, MissingRequirementResultStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MissingRequirementResultStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MissingRequirementResultStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MissingRequirementResult extends MissingRequirementResult {
  @override
  final MissingRequirementResultStatusEnum status;
  @override
  final BuiltList<MissingOption> missingOptions;

  factory _$MissingRequirementResult(
          [void Function(MissingRequirementResultBuilder)? updates]) =>
      (MissingRequirementResultBuilder()..update(updates))._build();

  _$MissingRequirementResult._(
      {required this.status, required this.missingOptions})
      : super._();
  @override
  MissingRequirementResult rebuild(
          void Function(MissingRequirementResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MissingRequirementResultBuilder toBuilder() =>
      MissingRequirementResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MissingRequirementResult &&
        status == other.status &&
        missingOptions == other.missingOptions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, missingOptions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MissingRequirementResult')
          ..add('status', status)
          ..add('missingOptions', missingOptions))
        .toString();
  }
}

class MissingRequirementResultBuilder
    implements
        Builder<MissingRequirementResult, MissingRequirementResultBuilder> {
  _$MissingRequirementResult? _$v;

  MissingRequirementResultStatusEnum? _status;
  MissingRequirementResultStatusEnum? get status => _$this._status;
  set status(MissingRequirementResultStatusEnum? status) =>
      _$this._status = status;

  ListBuilder<MissingOption>? _missingOptions;
  ListBuilder<MissingOption> get missingOptions =>
      _$this._missingOptions ??= ListBuilder<MissingOption>();
  set missingOptions(ListBuilder<MissingOption>? missingOptions) =>
      _$this._missingOptions = missingOptions;

  MissingRequirementResultBuilder() {
    MissingRequirementResult._defaults(this);
  }

  MissingRequirementResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _missingOptions = $v.missingOptions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MissingRequirementResult other) {
    _$v = other as _$MissingRequirementResult;
  }

  @override
  void update(void Function(MissingRequirementResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MissingRequirementResult build() => _build();

  _$MissingRequirementResult _build() {
    _$MissingRequirementResult _$result;
    try {
      _$result = _$v ??
          _$MissingRequirementResult._(
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'MissingRequirementResult', 'status'),
            missingOptions: missingOptions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'missingOptions';
        missingOptions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MissingRequirementResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
