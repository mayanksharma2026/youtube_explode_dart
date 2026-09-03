import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 || arguments.single.trim().isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/verify_visionos.dart <public-video-id-or-url>',
    );
    exitCode = 64;
    return;
  }

  final input = arguments.single.trim();
  final yt = YoutubeExplode();

  try {
    final stopwatch = Stopwatch()..start();
    final manifest = await yt.videos.streams
        .getManifest(
          input,
          ytClients: const [YoutubeApiClient.visionOs],
        )
        .timeout(const Duration(seconds: 60));

    if (manifest.audioOnly.isEmpty) {
      throw StateError('VisionOS returned no audio-only streams.');
    }
    if (manifest.videoOnly.isEmpty) {
      throw StateError('VisionOS returned no video-only streams.');
    }

    final selectedAudio = manifest.audioOnly.first;
    final firstChunk = await yt.videos.streams
        .get(selectedAudio)
        .first
        .timeout(const Duration(seconds: 30));

    if (firstChunk.isEmpty) {
      throw StateError('The selected audio stream returned an empty chunk.');
    }

    stopwatch.stop();
    stdout
      ..writeln('VisionOS verification passed.')
      ..writeln('input=$input')
      ..writeln('audioOnly=${manifest.audioOnly.length}')
      ..writeln('videoOnly=${manifest.videoOnly.length}')
      ..writeln('muxed=${manifest.muxed.length}')
      ..writeln('hls=${manifest.hls.length}')
      ..writeln('selectedAudioItag=${selectedAudio.tag}')
      ..writeln('firstChunkBytes=${firstChunk.length}')
      ..writeln('elapsedMs=${stopwatch.elapsedMilliseconds}');
  } catch (error, stackTrace) {
    stderr
      ..writeln('VisionOS verification failed: $error')
      ..writeln(stackTrace);
    exitCode = 1;
  } finally {
    yt.close();
  }
}
