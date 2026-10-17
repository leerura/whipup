// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missing_detail_requirement.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MissingDetailRequirementStatusEnum
    _$missingDetailRequirementStatusEnum_MISSING =
    const MissingDetailRequirementStatusEnum._('MISSING');

MissingDetailRequirementStatusEnum _$missingDetailRequirementStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'MISSING':
      return _$missingDetailRequirementStatusEnum_MISSING;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MissingDetailRequirementStatusEnum>
    _$missingDetailRequirementStatusEnumValues = BuiltSet<
        MissingDetailRequirementStatusEnum>(const <MissingDetailRequirementStatusEnum>[
  _$missingDetailRequirementStatusEnum_MISSING,
]);

Serializer<MissingDetailRequirementStatusEnum>
    _$missingDetailRequirementStatusEnumSerializer =
    _$MissingDetailRequirementStatusEnumSerializer();

class _$MissingDetailRequirementStatusEnumSerializer
    implements PrimitiveSerializer<MissingDetailRequirementStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MISSING': 'MISSING',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MISSING': 'MISSING',
  };

  @override
  final Iterable<Type> types = const <Type>[MissingDetailRequirementStatusEnum];
  @override
  final String wireName = 'MissingDetailRequirementStatusEnum';

  @override
  Object serialize(
          Serializers serializers, MissingDetailRequirementStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MissingDetailRequirementStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MissingDetailRequirementStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MissingDetailRequirement extends MissingDetailRequirement {
  @override
  final MissingDetailRequirementStatusEnum status;
  @override
  final BuiltList<DetailRequirementOption> options;

  factory _$MissingDetailRequirement(
          [void Function(MissingDetailRequirementBuilder)? updates]) =>
      (MissingDetailRequirementBuilder()..update(updates))._build();

  _$MissingDetailRequirement._({required this.status, required this.options})
      : super._();
  @override
  MissingDetailRequirement rebuild(
          void Function(MissingDetailRequirementBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MissingDetailRequirementBuilder toBuilder() =>
      MissingDetailRequirementBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MissingDetailRequirement &&
        status == other.status &&
        options == other.options;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MissingDetailRequirement')
          ..add('status', status)
          ..add('options', options))
        .toString();
  }
}

class MissingDetailRequirementBuilder
    implements
        Builder<MissingDetailRequirement, MissingDetailRequirementBuilder> {
  _$MissingDetailRequirement? _$v;

  MissingDetailRequirementStatusEnum? _status;
  MissingDetailRequirementStatusEnum? get status => _$this._status;
  set status(MissingDetailRequirementStatusEnum? status) =>
      _$this._status = status;

  ListBuilder<DetailRequirementOption>? _options;
  ListBuilder<DetailRequirementOption> get options =>
      _$this._options ??= ListBuilder<DetailRequirementOption>();
  set options(ListBuilder<DetailRequirementOption>? options) =>
      _$this._options = options;

  MissingDetailRequirementBuilder() {
    MissingDetailRequirement._defaults(this);
  }

  MissingDetailRequirementBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _options = $v.options.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MissingDetailRequirement other) {
    _$v = other as _$MissingDetailRequirement;
  }

  @override
  void update(void Function(MissingDetailRequirementBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MissingDetailRequirement build() => _build();

  _$MissingDetailRequirement _build() {
    _$MissingDetailRequirement _$result;
    try {
      _$result = _$v ??
          _$MissingDetailRequirement._(
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'MissingDetailRequirement', 'status'),
            options: options.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        options.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MissingDetailRequirement', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
