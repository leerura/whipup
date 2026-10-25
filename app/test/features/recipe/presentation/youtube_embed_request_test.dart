import 'package:app/features/recipe/presentation/youtube_embed_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YoutubeEmbedRequest', () {
    test('uses the registered Android application ID as Referer', () {
      expect(YoutubeEmbedRequest.headersForPlatform(TargetPlatform.android), {
        'Referer': 'https://com.example.app',
      });
    });

    test('uses the registered Apple bundle ID as Referer', () {
      expect(YoutubeEmbedRequest.headersForPlatform(TargetPlatform.iOS), {
        'Referer': 'https://com.leerura.whipup',
      });
    });

    test('keeps the inline autoplay embed parameters', () {
      final uri = YoutubeEmbedRequest.uriForVideo('abc123');

      expect(
        uri.toString(),
        'https://www.youtube.com/embed/abc123?autoplay=1&playsinline=1&rel=0',
      );
    });

    test('does not invent an application identity for other platforms', () {
      expect(
        YoutubeEmbedRequest.headersForPlatform(TargetPlatform.linux),
        isNull,
      );
    });
  });
}
