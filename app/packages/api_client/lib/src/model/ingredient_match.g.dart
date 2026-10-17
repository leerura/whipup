// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_match.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IngredientMatchTypeEnum _$ingredientMatchTypeEnum_DIRECT =
    const IngredientMatchTypeEnum._('DIRECT');
const IngredientMatchTypeEnum _$ingredientMatchTypeEnum_PREPARATION =
    const IngredientMatchTypeEnum._('PREPARATION');
const IngredientMatchTypeEnum _$ingredientMatchTypeEnum_SUBSTITUTE =
    const IngredientMatchTypeEnum._('SUBSTITUTE');

IngredientMatchTypeEnum _$ingredientMatchTypeEnumValueOf(String name) {
  switch (name) {
    case 'DIRECT':
      return _$ingredientMatchTypeEnum_DIRECT;
    case 'PREPARATION':
      return _$ingredientMatchTypeEnum_PREPARATION;
    case 'SUBSTITUTE':
      return _$ingredientMatchTypeEnum_SUBSTITUTE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IngredientMatchTypeEnum> _$ingredientMatchTypeEnumValues =
    BuiltSet<IngredientMatchTypeEnum>(const <IngredientMatchTypeEnum>[
  _$ingredientMatchTypeEnum_DIRECT,
  _$ingredientMatchTypeEnum_PREPARATION,
  _$ingredientMatchTypeEnum_SUBSTITUTE,
]);

Serializer<IngredientMatchTypeEnum> _$ingredientMatchTypeEnumSerializer =
    _$IngredientMatchTypeEnumSerializer();

class _$IngredientMatchTypeEnumSerializer
    implements PrimitiveSerializer<IngredientMatchTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DIRECT': 'DIRECT',
    'PREPARATION': 'PREPARATION',
    'SUBSTITUTE': 'SUBSTITUTE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DIRECT': 'DIRECT',
    'PREPARATION': 'PREPARATION',
    'SUBSTITUTE': 'SUBSTITUTE',
  };

  @override
  final Iterable<Type> types = const <Type>[IngredientMatchTypeEnum];
  @override
  final String wireName = 'IngredientMatchTypeEnum';

  @override
  Object serialize(Serializers serializers, IngredientMatchTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IngredientMatchTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IngredientMatchTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IngredientMatch extends IngredientMatch {
  @override
  final IngredientMatchTypeEnum type;
  @override
  final String requiredName;
  @override
  final String ownedName;

  factory _$IngredientMatch([void Function(IngredientMatchBuilder)? updates]) =>
      (IngredientMatchBuilder()..update(updates))._build();

  _$IngredientMatch._(
      {required this.type, required this.requiredName, required this.ownedName})
      : super._();
  @override
  IngredientMatch rebuild(void Function(IngredientMatchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IngredientMatchBuilder toBuilder() => IngredientMatchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IngredientMatch &&
        type == other.type &&
        requiredName == other.requiredName &&
        ownedName == other.ownedName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, requiredName.hashCode);
    _$hash = $jc(_$hash, ownedName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IngredientMatch')
          ..add('type', type)
          ..add('requiredName', requiredName)
          ..add('ownedName', ownedName))
        .toString();
  }
}

class IngredientMatchBuilder
    implements Builder<IngredientMatch, IngredientMatchBuilder> {
  _$IngredientMatch? _$v;

  IngredientMatchTypeEnum? _type;
  IngredientMatchTypeEnum? get type => _$this._type;
  set type(IngredientMatchTypeEnum? type) => _$this._type = type;

  String? _requiredName;
  String? get requiredName => _$this._requiredName;
  set requiredName(String? requiredName) => _$this._requiredName = requiredName;

  String? _ownedName;
  String? get ownedName => _$this._ownedName;
  set ownedName(String? ownedName) => _$this._ownedName = ownedName;

  IngredientMatchBuilder() {
    IngredientMatch._defaults(this);
  }

  IngredientMatchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _requiredName = $v.requiredName;
      _ownedName = $v.ownedName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IngredientMatch other) {
    _$v = other as _$IngredientMatch;
  }

  @override
  void update(void Function(IngredientMatchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IngredientMatch build() => _build();

  _$IngredientMatch _build() {
    final _$result = _$v ??
        _$IngredientMatch._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'IngredientMatch', 'type'),
          requiredName: BuiltValueNullFieldError.checkNotNull(
              requiredName, r'IngredientMatch', 'requiredName'),
          ownedName: BuiltValueNullFieldError.checkNotNull(
              ownedName, r'IngredientMatch', 'ownedName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
