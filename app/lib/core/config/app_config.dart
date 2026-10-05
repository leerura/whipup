import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'local_config.dart';

abstract final class AppConfig {
  static String? _apiBaseUrl;
  static Future<void>? _initialization;

  static String get apiBaseUrl {
    final baseUrl = _apiBaseUrl;
    if (baseUrl == null) {
      throw StateError(
        'AppConfig.initialize() must complete before creating the API client.',
      );
    }
    return baseUrl;
  }

  static Future<void> initialize() => _initialization ??= _initialize();

  static Future<void> _initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final device = await DeviceInfoPlugin().iosInfo;
      if (device.isPhysicalDevice) {
        final baseUrl = LocalConfig.deviceApiBaseUrl.trim();
        if (baseUrl.isEmpty) {
          throw StateError(
            'Set LocalConfig.deviceApiBaseUrl in '
            'app/lib/core/config/local_config.dart to the Windows LAN backend URL.',
          );
        }
        final uri = Uri.tryParse(baseUrl);
        if (uri == null ||
            (uri.scheme != 'http' && uri.scheme != 'https') ||
            uri.host.isEmpty ||
            uri.host.toLowerCase() == 'localhost' ||
            uri.host.startsWith('127.') ||
            uri.host == '::1' ||
            uri.hasQuery ||
            uri.hasFragment ||
            uri.userInfo.isNotEmpty ||
            (uri.path.isNotEmpty && uri.path != '/')) {
          throw StateError(
            'LocalConfig.deviceApiBaseUrl must be an HTTP(S) backend URL '
            'with a LAN host and no API path, query, or credentials.',
          );
        }
        _apiBaseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
        return;
      }
    }
    _apiBaseUrl = 'http://localhost:8080';
  }

  static const kakaoNativeAppKey = '67b2557d18e0f70f51523f7c4f37bc53';
}
