// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'satisfied_requirement_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SatisfiedRequirementResultStatusEnum
    _$satisfiedRequirementResultStatusEnum_SATISFIED =
    const SatisfiedRequirementResultStatusEnum._('SATISFIED');

SatisfiedRequirementResultStatusEnum
    _$satisfiedRequirementResultStatusEnumValueOf(String name) {
  switch (name) {
    case 'SATISFIED':
      return _$satisfiedRequirementResultStatusEnum_SATISFIED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SatisfiedRequirementResultStatusEnum>
    _$satisfiedRequirementResultStatusEnumValues = BuiltSet<
        SatisfiedRequirementResultStatusEnum>(const <SatisfiedRequirementResultStatusEnum>[
  _$satisfiedRequirementResultStatusEnum_SATISFIED,
]);

Serializer<SatisfiedRequirementResultStatusEnum>
    _$satisfiedRequirementResultStatusEnumSerializer =
    _$SatisfiedRequirementResultStatusEnumSerializer();

class _$SatisfiedRequirementResultStatusEnumSerializer
    implements PrimitiveSerializer<SatisfiedRequirementResultStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SATISFIED': 'SATISFIED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SATISFIED': 'SATISFIED',
  };

  @override
  final Iterable<Type> types = const <Type>[
    SatisfiedRequirementResultStatusEnum
  ];
  @override
  final String wireName = 'SatisfiedRequirementResultStatusEnum';

  @override
  Object serialize(
          Serializers serializers, SatisfiedRequirementResultStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SatisfiedRequirementResultStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SatisfiedRequirementResultStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SatisfiedRequirementResult extends SatisfiedRequirementResult {
  @override
  final SatisfiedRequirementResultStatusEnum status;
  @override
  final BuiltList<IngredientMatch> matches;

  factory _$SatisfiedRequirementResult(
          [void Function(SatisfiedRequirementResultBuilder)? updates]) =>
      (SatisfiedRequirementResultBuilder()..update(updates))._build();

  _$SatisfiedRequirementResult._({required this.status, required this.matches})
      : super._();
  @override
  SatisfiedRequirementResult rebuild(
          void Function(SatisfiedRequirementResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SatisfiedRequirementResultBuilder toBuilder() =>
      SatisfiedRequirementResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SatisfiedRequirementResult &&
        status == other.status &&
        matches == other.matches;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, matches.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SatisfiedRequirementResult')
          ..add('status', status)
          ..add('matches', matches))
        .toString();
  }
}

class SatisfiedRequirementResultBuilder
    implements
        Builder<SatisfiedRequirementResult, SatisfiedRequirementResultBuilder> {
  _$SatisfiedRequirementResult? _$v;

  SatisfiedRequirementResultStatusEnum? _status;
  SatisfiedRequirementResultStatusEnum? get status => _$this._status;
  set status(SatisfiedRequirementResultStatusEnum? status) =>
      _$this._status = status;

  ListBuilder<IngredientMatch>? _matches;
  ListBuilder<IngredientMatch> get matches =>
      _$this._matches ??= ListBuilder<IngredientMatch>();
  set matches(ListBuilder<IngredientMatch>? matches) =>
      _$this._matches = matches;

  SatisfiedRequirementResultBuilder() {
    SatisfiedRequirementResult._defaults(this);
  }

  SatisfiedRequirementResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _matches = $v.matches.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SatisfiedRequirementResult other) {
    _$v = other as _$SatisfiedRequirementResult;
  }

  @override
  void update(void Function(SatisfiedRequirementResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SatisfiedRequirementResult build() => _build();

  _$SatisfiedRequirementResult _build() {
    _$SatisfiedRequirementResult _$result;
    try {
      _$result = _$v ??
          _$SatisfiedRequirementResult._(
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'SatisfiedRequirementResult', 'status'),
            matches: matches.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'matches';
        matches.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SatisfiedRequirementResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
