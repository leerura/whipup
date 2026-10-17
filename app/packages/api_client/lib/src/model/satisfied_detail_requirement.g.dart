// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'satisfied_detail_requirement.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SatisfiedDetailRequirementStatusEnum
    _$satisfiedDetailRequirementStatusEnum_SATISFIED =
    const SatisfiedDetailRequirementStatusEnum._('SATISFIED');

SatisfiedDetailRequirementStatusEnum
    _$satisfiedDetailRequirementStatusEnumValueOf(String name) {
  switch (name) {
    case 'SATISFIED':
      return _$satisfiedDetailRequirementStatusEnum_SATISFIED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SatisfiedDetailRequirementStatusEnum>
    _$satisfiedDetailRequirementStatusEnumValues = BuiltSet<
        SatisfiedDetailRequirementStatusEnum>(const <SatisfiedDetailRequirementStatusEnum>[
  _$satisfiedDetailRequirementStatusEnum_SATISFIED,
]);

Serializer<SatisfiedDetailRequirementStatusEnum>
    _$satisfiedDetailRequirementStatusEnumSerializer =
    _$SatisfiedDetailRequirementStatusEnumSerializer();

class _$SatisfiedDetailRequirementStatusEnumSerializer
    implements PrimitiveSerializer<SatisfiedDetailRequirementStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SATISFIED': 'SATISFIED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SATISFIED': 'SATISFIED',
  };

  @override
  final Iterable<Type> types = const <Type>[
    SatisfiedDetailRequirementStatusEnum
  ];
  @override
  final String wireName = 'SatisfiedDetailRequirementStatusEnum';

  @override
  Object serialize(
          Serializers serializers, SatisfiedDetailRequirementStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SatisfiedDetailRequirementStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SatisfiedDetailRequirementStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SatisfiedDetailRequirement extends SatisfiedDetailRequirement {
  @override
  final SatisfiedDetailRequirementStatusEnum status;
  @override
  final BuiltList<DetailRequirementOption> options;
  @override
  final BuiltList<IngredientMatch> matches;

  factory _$SatisfiedDetailRequirement(
          [void Function(SatisfiedDetailRequirementBuilder)? updates]) =>
      (SatisfiedDetailRequirementBuilder()..update(updates))._build();

  _$SatisfiedDetailRequirement._(
      {required this.status, required this.options, required this.matches})
      : super._();
  @override
  SatisfiedDetailRequirement rebuild(
          void Function(SatisfiedDetailRequirementBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SatisfiedDetailRequirementBuilder toBuilder() =>
      SatisfiedDetailRequirementBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SatisfiedDetailRequirement &&
        status == other.status &&
        options == other.options &&
        matches == other.matches;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jc(_$hash, matches.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SatisfiedDetailRequirement')
          ..add('status', status)
          ..add('options', options)
          ..add('matches', matches))
        .toString();
  }
}

class SatisfiedDetailRequirementBuilder
    implements
        Builder<SatisfiedDetailRequirement, SatisfiedDetailRequirementBuilder> {
  _$SatisfiedDetailRequirement? _$v;

  SatisfiedDetailRequirementStatusEnum? _status;
  SatisfiedDetailRequirementStatusEnum? get status => _$this._status;
  set status(SatisfiedDetailRequirementStatusEnum? status) =>
      _$this._status = status;

  ListBuilder<DetailRequirementOption>? _options;
  ListBuilder<DetailRequirementOption> get options =>
      _$this._options ??= ListBuilder<DetailRequirementOption>();
  set options(ListBuilder<DetailRequirementOption>? options) =>
      _$this._options = options;

  ListBuilder<IngredientMatch>? _matches;
  ListBuilder<IngredientMatch> get matches =>
      _$this._matches ??= ListBuilder<IngredientMatch>();
  set matches(ListBuilder<IngredientMatch>? matches) =>
      _$this._matches = matches;

  SatisfiedDetailRequirementBuilder() {
    SatisfiedDetailRequirement._defaults(this);
  }

  SatisfiedDetailRequirementBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _options = $v.options.toBuilder();
      _matches = $v.matches.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SatisfiedDetailRequirement other) {
    _$v = other as _$SatisfiedDetailRequirement;
  }

  @override
  void update(void Function(SatisfiedDetailRequirementBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SatisfiedDetailRequirement build() => _build();

  _$SatisfiedDetailRequirement _build() {
    _$SatisfiedDetailRequirement _$result;
    try {
      _$result = _$v ??
          _$SatisfiedDetailRequirement._(
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'SatisfiedDetailRequirement', 'status'),
            options: options.build(),
            matches: matches.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        options.build();
        _$failedField = 'matches';
        matches.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SatisfiedDetailRequirement', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
