import 'package:flutter/foundation.dart';

class YoutubeEmbedRequest {
  const YoutubeEmbedRequest._();

  static const _applicationIds = <TargetPlatform, String>{
    TargetPlatform.android: 'com.example.app',
    TargetPlatform.iOS: 'com.leerura.whipup',
  };

  static Uri uriForVideo(String videoId) => Uri.https(
    'www.youtube.com',
    '/embed/$videoId',
    const {'autoplay': '1', 'playsinline': '1', 'rel': '0'},
  );

  static Map<String, String>? headersForPlatform(TargetPlatform platform) {
    final applicationId = _applicationIds[platform];
    if (applicationId == null) return null;
    return {'Referer': 'https://$applicationId'};
  }
}
