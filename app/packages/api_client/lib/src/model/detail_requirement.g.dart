// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_requirement.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DetailRequirementStatusEnum _$detailRequirementStatusEnum_MISSING =
    const DetailRequirementStatusEnum._('MISSING');

DetailRequirementStatusEnum _$detailRequirementStatusEnumValueOf(String name) {
  switch (name) {
    case 'MISSING':
      return _$detailRequirementStatusEnum_MISSING;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DetailRequirementStatusEnum>
    _$detailRequirementStatusEnumValues =
    BuiltSet<DetailRequirementStatusEnum>(const <DetailRequirementStatusEnum>[
  _$detailRequirementStatusEnum_MISSING,
]);

Serializer<DetailRequirementStatusEnum>
    _$detailRequirementStatusEnumSerializer =
    _$DetailRequirementStatusEnumSerializer();

class _$DetailRequirementStatusEnumSerializer
    implements PrimitiveSerializer<DetailRequirementStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MISSING': 'MISSING',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MISSING': 'MISSING',
  };

  @override
  final Iterable<Type> types = const <Type>[DetailRequirementStatusEnum];
  @override
  final String wireName = 'DetailRequirementStatusEnum';

  @override
  Object serialize(Serializers serializers, DetailRequirementStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DetailRequirementStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DetailRequirementStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DetailRequirement extends DetailRequirement {
  @override
  final OneOf oneOf;

  factory _$DetailRequirement(
          [void Function(DetailRequirementBuilder)? updates]) =>
      (DetailRequirementBuilder()..update(updates))._build();

  _$DetailRequirement._({required this.oneOf}) : super._();
  @override
  DetailRequirement rebuild(void Function(DetailRequirementBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DetailRequirementBuilder toBuilder() =>
      DetailRequirementBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DetailRequirement && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'DetailRequirement')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class DetailRequirementBuilder
    implements Builder<DetailRequirement, DetailRequirementBuilder> {
  _$DetailRequirement? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  DetailRequirementBuilder() {
    DetailRequirement._defaults(this);
  }

  DetailRequirementBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DetailRequirement other) {
    _$v = other as _$DetailRequirement;
  }

  @override
  void update(void Function(DetailRequirementBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DetailRequirement build() => _build();

  _$DetailRequirement _build() {
    final _$result = _$v ??
        _$DetailRequirement._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'DetailRequirement', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
