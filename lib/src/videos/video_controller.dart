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
      VideoId videoId, YoutubeApiClient client,
      {WatchPage? watchPage}) async {
    final payload = client.payload;
    assert(payload['context'] != null, 'client must contain a context');
    assert(payload['context']!['client'] != null,
        'client must contain a context.client');

    // Client profiles are shared static objects. Copy the request-scoped maps
    // before adding visitor data so a request can never mutate the profile.
    final context = Map<String, dynamic>.from(
      payload['context'] as Map<String, dynamic>,
    );
    final clientContext = Map<String, dynamic>.from(
      context['client'] as Map<String, dynamic>,
    );
    context['client'] = clientContext;

    final userAgent = clientContext['userAgent'] as String?;
    final clientName = clientContext['clientName'] as String?;
    final ytCfg = watchPage?.ytCfg;

    var visitorData = _getVisitorDataFromWatchPage(ytCfg);
    if ((visitorData == null || visitorData.isEmpty) &&
        _shouldResolveVisitorData(clientName) &&
        userAgent != null) {
      visitorData = await _extractVisitorData(httpClient, userAgent);
    }
    if (visitorData != null && visitorData.isNotEmpty) {
      clientContext['visitorData'] = visitorData;
    }

    final body = {
      ...payload,
      'context': context,
      'videoId': videoId.value,
      if (ytCfg?.containsKey('STS') ?? false)
        'playbackContext': {
          'contentPlaybackContext': {
            'html5Preference': 'HTML5_PREF_WANTS',
            'signatureTimestamp': ytCfg!['STS'].toString()
          }
        }
    };

    final content = await httpClient.postString(
      client.apiUrl,
      body: body,
      headers: {
        if (userAgent != null) 'User-Agent': userAgent,
        if (clientName != null) 'X-Youtube-Client-Name': clientName,
        'X-Youtube-Client-Version': clientContext['clientVersion'].toString(),
        if (visitorData != null && visitorData.isNotEmpty)
          'X-Goog-Visitor-Id': visitorData,
        'Origin': 'https://www.youtube.com',
        'Sec-Fetch-Mode': 'navigate',
        'Content-Type': 'application/json',
        if (watchPage != null) 'Cookie': watchPage.cookieString,
        ...client.headers,
      },
    );
    return PlayerResponse.parse(content);
  }

  String? _visitorData;

  bool _shouldResolveVisitorData(String? clientName) =>
      clientName == 'VISIONOS' ||
      clientName == 'ANDROID' ||
      clientName == 'IOS';

  String? _getVisitorDataFromWatchPage(Map<String, dynamic>? ytCfg) {
    final innertubeContext = ytCfg?['INNERTUBE_CONTEXT'];
    if (innertubeContext is! Map) return null;

    final client = innertubeContext['client'];
    if (client is! Map) return null;

    final value = client['visitorData'];
    return value is String && value.isNotEmpty ? value : null;
  }

  Future<String> _extractVisitorData(
      YoutubeHttpClient http, String userAgent) async {
    if (_visitorData != null) {
      return _visitorData!;
    }

    var response =
        await http.getString('https://www.youtube.com/sw.js_data', headers: {
      'User-Agent': userAgent,
      'Content-Type': 'application/json',
    });

    if (response.startsWith(")]}'")) {
      response = response.substring(4);
    }

    final data = json.decode(response) as List<dynamic>;
    final value = data[0][2][0][0][13];
    if (value is! String || value.isEmpty) {
      throw YoutubeExplodeException('Failed to resolve visitor data.');
    }

    return _visitorData = value;
  }
}
