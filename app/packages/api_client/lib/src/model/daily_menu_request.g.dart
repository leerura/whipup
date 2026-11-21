// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_menu_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DailyMenuRequest extends DailyMenuRequest {
  @override
  final int recipeId;

  factory _$DailyMenuRequest(
          [void Function(DailyMenuRequestBuilder)? updates]) =>
      (DailyMenuRequestBuilder()..update(updates))._build();

  _$DailyMenuRequest._({required this.recipeId}) : super._();
  @override
  DailyMenuRequest rebuild(void Function(DailyMenuRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DailyMenuRequestBuilder toBuilder() =>
      DailyMenuRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DailyMenuRequest && recipeId == other.recipeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DailyMenuRequest')
          ..add('recipeId', recipeId))
        .toString();
  }
}

class DailyMenuRequestBuilder
    implements Builder<DailyMenuRequest, DailyMenuRequestBuilder> {
  _$DailyMenuRequest? _$v;

  int? _recipeId;
  int? get recipeId => _$this._recipeId;
  set recipeId(int? recipeId) => _$this._recipeId = recipeId;

  DailyMenuRequestBuilder() {
    DailyMenuRequest._defaults(this);
  }

  DailyMenuRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recipeId = $v.recipeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DailyMenuRequest other) {
    _$v = other as _$DailyMenuRequest;
  }

  @override
  void update(void Function(DailyMenuRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DailyMenuRequest build() => _build();

  _$DailyMenuRequest _build() {
    final _$result = _$v ??
        _$DailyMenuRequest._(
          recipeId: BuiltValueNullFieldError.checkNotNull(
              recipeId, r'DailyMenuRequest', 'recipeId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
