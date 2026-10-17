// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missing_substitute.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MissingSubstitute extends MissingSubstitute {
  @override
  final String name;

  factory _$MissingSubstitute(
          [void Function(MissingSubstituteBuilder)? updates]) =>
      (MissingSubstituteBuilder()..update(updates))._build();

  _$MissingSubstitute._({required this.name}) : super._();
  @override
  MissingSubstitute rebuild(void Function(MissingSubstituteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MissingSubstituteBuilder toBuilder() =>
      MissingSubstituteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MissingSubstitute && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MissingSubstitute')
          ..add('name', name))
        .toString();
  }
}

class MissingSubstituteBuilder
    implements Builder<MissingSubstitute, MissingSubstituteBuilder> {
  _$MissingSubstitute? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  MissingSubstituteBuilder() {
    MissingSubstitute._defaults(this);
  }

  MissingSubstituteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MissingSubstitute other) {
    _$v = other as _$MissingSubstitute;
  }

  @override
  void update(void Function(MissingSubstituteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MissingSubstitute build() => _build();

  _$MissingSubstitute _build() {
    final _$result = _$v ??
        _$MissingSubstitute._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MissingSubstitute', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
