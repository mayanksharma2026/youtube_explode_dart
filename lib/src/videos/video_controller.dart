import 'dart:convert';

import 'package:meta/meta.dart';

import '../../youtube_explode_dart.dart';
import '../reverse_engineering/pages/watch_page.dart';
import '../reverse_engineering/player/player_response.dart';

@internal
class VideoController {
  @protected
  final YoutubeHttpClient httpClient;

  VideoController(this.httpClient);

  Future<PlayerResponse> getPlayerResponse(
    VideoId videoId,
    YoutubeApiClient client, {
    WatchPage? watchPage,
  }) async {
    final rawContext = client.payload['context'];
    if (rawContext is! Map) {
      throw ArgumentError.value(
        client.payload,
        'client.payload',
        'The client payload must contain a context map.',
      );
    }
    final rawClientContext = rawContext['client'];
    if (rawClientContext is! Map) {
      throw ArgumentError.value(
        client.payload,
        'client.payload',
        'The client payload must contain a context.client map.',
      );
    }

    final payload = Map<String, dynamic>.from(client.payload);
    final context = Map<String, dynamic>.from(rawContext);
    final clientContext = Map<String, dynamic>.from(rawClientContext);
    context['client'] = clientContext;
    payload['context'] = context;

    final ytCfg = watchPage?.ytCfg;
    final body = <String, dynamic>{
      ...payload,
      'videoId': videoId.value,
      if (ytCfg?.containsKey('STS') ?? false)
        'playbackContext': {
          'contentPlaybackContext': {
            'html5Preference': 'HTML5_PREF_WANTS',
            'signatureTimestamp': ytCfg!['STS'].toString(),
          },
        },
    };

    if (client.clientName == 'IOS') {
      clientContext['visitorData'] =
          await _extractVisitorData(httpClient, client);
    }

    String? visitorData;
    final innerTubeContext = ytCfg?['INNERTUBE_CONTEXT'];
    if (innerTubeContext is Map) {
      final configuredClient = innerTubeContext['client'];
      if (configuredClient is Map &&
          configuredClient['visitorData'] is String) {
        visitorData = configuredClient['visitorData'] as String;
      }
    }

    final userAgent = client.mediaRequestHeaders['User-Agent'];
    final requestHeaders = <String, String>{
      if (userAgent != null) 'User-Agent': userAgent,
      'X-Youtube-Client-Name': client.clientHeaderName,
      'X-Youtube-Client-Version': client.clientVersion,
      if (visitorData != null) 'X-Goog-Visitor-Id': visitorData,
      'Origin': 'https://www.youtube.com',
      'Sec-Fetch-Mode': 'navigate',
      'Content-Type': 'application/json',
      if (watchPage != null) 'Cookie': watchPage.cookieString,
      for (final entry in client.headers.entries)
        entry.key: entry.value.toString(),
    };

    final content = await httpClient.postString(
      client.apiUrl,
      body: body,
      headers: requestHeaders,
    );
    return PlayerResponse.parse(content);
  }

  String? _visitorData;

  Future<String> _extractVisitorData(
    YoutubeHttpClient http,
    YoutubeApiClient client,
  ) async {
    if (_visitorData != null) {
      return _visitorData!;
    }

    final userAgent = client.mediaRequestHeaders['User-Agent'];
    var response = await http.getString(
      'https://www.youtube.com/sw.js_data',
      headers: {
        if (userAgent != null) 'User-Agent': userAgent,
        'Content-Type': 'application/json',
      },
    );

    if (response.startsWith(")]}'")) {
      response = response.substring(4);
    }

    final data = json.decode(response) as List<dynamic>;
    final value = data[0][2][0][0][13] as String;

    return _visitorData = value;
  }
}
