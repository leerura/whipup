// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecipeStep extends RecipeStep {
  @override
  final int order;
  @override
  final String content;

  factory _$RecipeStep([void Function(RecipeStepBuilder)? updates]) =>
      (RecipeStepBuilder()..update(updates))._build();

  _$RecipeStep._({required this.order, required this.content}) : super._();
  @override
  RecipeStep rebuild(void Function(RecipeStepBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecipeStepBuilder toBuilder() => RecipeStepBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecipeStep &&
        order == other.order &&
        content == other.content;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, order.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecipeStep')
          ..add('order', order)
          ..add('content', content))
        .toString();
  }
}

class RecipeStepBuilder implements Builder<RecipeStep, RecipeStepBuilder> {
  _$RecipeStep? _$v;

  int? _order;
  int? get order => _$this._order;
  set order(int? order) => _$this._order = order;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  RecipeStepBuilder() {
    RecipeStep._defaults(this);
  }

  RecipeStepBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _order = $v.order;
      _content = $v.content;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecipeStep other) {
    _$v = other as _$RecipeStep;
  }

  @override
  void update(void Function(RecipeStepBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecipeStep build() => _build();

  _$RecipeStep _build() {
    final _$result = _$v ??
        _$RecipeStep._(
          order: BuiltValueNullFieldError.checkNotNull(
              order, r'RecipeStep', 'order'),
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'RecipeStep', 'content'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
