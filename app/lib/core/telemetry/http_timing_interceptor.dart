import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HttpTimingInterceptor extends Interceptor {
  static const _telemetryPath = '/api/v1/telemetry/http-timing';

  HttpTimingInterceptor(this._dio);

  final Dio _dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isTelemetry(options)) {
      options.extra['_whipupStartedAt'] = Stopwatch()..start();
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final requestId = response.headers.value('x-request-id');
    if (requestId != null) debugPrint('HTTP requestId=$requestId');
    _report(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _report(err.requestOptions, err.response?.statusCode);
    handler.next(err);
  }

  void _report(RequestOptions options, int? statusCode) {
    if (_isTelemetry(options)) return;
    final stopwatch = options.extra.remove('_whipupStartedAt');
    if (stopwatch is! Stopwatch) return;
    stopwatch.stop();
    final route = _routeTemplate(options.uri.path);
    if (route == null) return;
    final outcome = statusCode == null
        ? 'NETWORK_ERROR'
        : statusCode >= 500
        ? 'SERVER_ERROR'
        : statusCode >= 400
        ? 'CLIENT_ERROR'
        : 'SUCCESS';
    unawaited(
      _send(route, options.method, outcome, stopwatch.elapsedMilliseconds),
    );
  }

  Future<void> _send(
    String route,
    String method,
    String outcome,
    int durationMs,
  ) async {
    try {
      await _dio.post<void>(
        _telemetryPath,
        data: {
          'route': route,
          'method': method,
          'outcome': outcome,
          'durationMs': durationMs.clamp(0, 60000),
        },
        options: Options(extra: const {'whipupTelemetry': true}),
      );
    } catch (_) {
      debugPrint('HTTP timing telemetry dropped');
    }
  }

  bool _isTelemetry(RequestOptions options) =>
      options.extra['whipupTelemetry'] == true ||
      options.path == _telemetryPath;

  String? _routeTemplate(String path) {
    if (path == '/api/v1/recipes/recommendations' ||
        path == '/api/v1/recipes/search' ||
        path == '/api/v1/auth/kakao' ||
        path == '/api/v1/me' ||
        path == '/api/v1/me/terms-consent' ||
        path == '/api/v1/me/onboarding' ||
        path == '/api/v1/me/daily-menu' ||
        path == '/api/v1/me/ingredients' ||
        path == '/api/v1/ingredients') {
      return path;
    }
    if (RegExp(r'^/api/v1/recipes/\d+$').hasMatch(path)) {
      return '/api/v1/recipes/{recipeId}';
    }
    if (RegExp(r'^/api/v1/me/daily-menu/\d+$').hasMatch(path)) {
      return '/api/v1/me/daily-menu/{recipeId}';
    }
    if (RegExp(r'^/api/v1/me/ingredients/\d+$').hasMatch(path)) {
      return '/api/v1/me/ingredients/{userIngredientId}';
    }
    return null;
  }
}
