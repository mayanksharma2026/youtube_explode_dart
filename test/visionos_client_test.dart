import 'package:test/test.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'data.dart';
import 'skip_gh.dart';

void main() {
  group('YoutubeApiClient.visionOs', () {
    test('uses a coherent VisionOS InnerTube identity', () {
      const client = YoutubeApiClient.visionOs;
      final context = Map<String, dynamic>.from(
        client.payload['context'] as Map,
      );
      final identity = Map<String, dynamic>.from(
        context['client'] as Map,
      );

      expect(identity['clientName'], 'VISIONOS');
      expect(identity['clientVersion'], '1.02');
      expect(identity['deviceMake'], 'Apple');
      expect(identity['deviceModel'], 'RealityDevice17,1');
      expect(identity['osName'], 'visionOS');
      expect(identity['osVersion'], '26.5.23O471');
      expect(identity['hl'], 'en');
      expect(identity['timeZone'], 'UTC');
      expect(identity['utcOffsetMinutes'], 0);
      expect(
        identity['userAgent'],
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) '
        'Version/26.0 Safari/605.1.15',
      );
      expect(
        client.apiUrl,
        'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
      );
      expect(client.headers, isEmpty);
    });

    test(
      'resolves adaptive audio and video streams',
      () async {
        final yt = YoutubeExplode();
        addTearDown(yt.close);

        final manifest = await yt.videos.streams.getManifest(
          VideoIdData.normal.id,
          ytClients: const [YoutubeApiClient.visionOs],
        );

        expect(manifest.audioOnly, isNotEmpty);
        expect(manifest.videoOnly, isNotEmpty);
      },
      skip: skipGH,
      timeout: const Timeout(Duration(seconds: 90)),
    );

    test(
      'downloads media bytes from a resolved audio stream',
      () async {
        final yt = YoutubeExplode();
        addTearDown(yt.close);

        final manifest = await yt.videos.streams.getManifest(
          VideoIdData.normal.id,
          ytClients: const [YoutubeApiClient.visionOs],
        );
        expect(manifest.audioOnly, isNotEmpty);

        final firstChunk = await yt.videos.streams
            .get(manifest.audioOnly.first)
            .first
            .timeout(const Duration(seconds: 30));

        expect(firstChunk, isNotEmpty);
      },
      skip: skipGH,
      timeout: const Timeout(Duration(seconds: 120)),
    );
  });
}
