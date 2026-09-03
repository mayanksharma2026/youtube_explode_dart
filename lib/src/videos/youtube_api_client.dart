class YoutubeApiClient {
  final Map<String, dynamic> payload;
  final String apiUrl;

  /// Headers used for the InnerTube player request.
  final Map<String, dynamic> headers;

  /// Numeric `X-Youtube-Client-Name` value when it is known.
  ///
  /// Older profiles may leave this unset to preserve their existing request
  /// behaviour. New profiles should set it from a dated protocol reference.
  final int? clientId;

  /// Additional headers required when fetching media resources created by
  /// this client. The profile user agent is added automatically.
  final Map<String, String> mediaHeaders;

  const YoutubeApiClient(
    this.payload,
    this.apiUrl, {
    this.headers = const {},
    this.clientId,
    this.mediaHeaders = const {},
  });

  YoutubeApiClient.fromJson(Map<String, dynamic> json)
      : payload = Map<String, dynamic>.from(json['payload'] as Map),
        apiUrl = json['apiUrl'] as String,
        headers = Map<String, dynamic>.from(
          (json['headers'] as Map?) ?? const {},
        ),
        clientId = json['clientId'] as int?,
        mediaHeaders = Map<String, String>.from(
          (json['mediaHeaders'] as Map?) ?? const {},
        );

  Map<String, dynamic> toJson() => {
        'payload': payload,
        'apiUrl': apiUrl,
        'headers': headers,
        if (clientId != null) 'clientId': clientId,
        if (mediaHeaders.isNotEmpty) 'mediaHeaders': mediaHeaders,
      };

  Map<String, dynamic> get _clientContext =>
      payload['context']['client'] as Map<String, dynamic>;

  /// InnerTube client name used in the request body.
  String get clientName => _clientContext['clientName'] as String;

  /// InnerTube client version used in the request body.
  String get clientVersion => _clientContext['clientVersion'] as String;

  /// Value sent through the `X-Youtube-Client-Name` header.
  String get clientHeaderName => (clientId ?? clientName).toString();

  /// Headers to preserve when validating or downloading media URLs minted by
  /// this client.
  ///
  /// Player-only headers are deliberately not copied here. Supplying headers
  /// such as `Content-Type`, cookies, or origin data to media hosts without
  /// evidence can create a mismatched request identity.
  Map<String, String> get mediaRequestHeaders {
    final userAgent = _clientContext['userAgent'];
    return {
      if (userAgent is String && userAgent.isNotEmpty)
        'User-Agent': userAgent,
      ...mediaHeaders,
    };
  }

  // Client profiles are undocumented, server-controlled compatibility data.
  // Before changing one, follow docs/maintenance-workflow.md and update
  // docs/client-profiles.md with an exact, dated source revision.

  /// Has limited streams but doesn't require signature deciphering.
  ///
  /// Direct media access for this profile was observed requiring additional
  /// PO-token handling during the 2026-08 incident. Retained for explicit
  /// compatibility testing; it is not the anonymous default in this fork.
  static final ios = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'IOS',
        'clientVersion': '20.10.4',
        'deviceMake': 'Apple',
        'deviceModel': 'iPhone16,2',
        'userAgent':
            'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
        'hl': 'en',
        'platform': 'MOBILE',
        'osName': 'IOS',
        'osVersion': '18.1.0.22B83',
        'timeZone': 'UTC',
        'gl': 'US',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false');

  /// Provides muxed streams but can require a PO token for direct media URLs.
  static const android = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID',
        'clientVersion': '20.10.38',
        'androidSdkVersion': 30,
        'userAgent':
            'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
        'osName': 'Android',
        'osVersion': '11',
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  /// Android client without `androidSdkVersion`.
  ///
  /// This was a historical workaround for audio/video 403 responses. During
  /// the 2026-08 incident, its non-muxed media URLs were no longer reliably
  /// fetchable. It remains available for explicit testing and compatibility.
  static const androidSdkless = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID',
        'clientVersion': '20.10.38',
        'userAgent':
            'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
        'osName': 'Android',
        'osVersion': '11',
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  /// Has limited streams and historically worked only for music.
  static const androidMusic = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID_MUSIC',
        'clientVersion': '2.16.032',
        'androidSdkVersion': 31,
        'userAgent':
            'com.google.android.youtube/19.29.1  (Linux; U; Android 11) gzip',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://music.youtube.com/youtubei/v1/player?key=AIzaSyAOghZGza2MQSZkY_zfZ370N-PUdXEo8AI&prettyPrint=false');

  /// Provides high-quality videos, not only VR content.
  ///
  /// Current reference implementations reported all formats from the then
  /// current Android VR profile returning 403 from 2026-08-17. Do not restore
  /// it as an automatic fallback without new media-byte evidence.
  static const androidVr = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID_VR',
        'clientVersion': '1.56.21',
        'deviceModel': 'Quest 3',
        'osVersion': '12',
        'osName': 'Android',
        'androidSdkVersion': '32',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  /// Apple Vision Pro compatibility profile.
  ///
  /// Added after YouTube expanded GVS PO-token enforcement for the profiles
  /// previously used by this package. At the reviewed 2026-09-03 revision,
  /// mature reference implementations used `VISIONOS` as the anonymous,
  /// no-JavaScript client and did not configure a GVS PO-token requirement.
  /// Made-for-kids content may be unavailable with this profile.
  ///
  /// This is a dated compatibility observation, not a permanent API contract.
  /// Revalidate real audio/video bytes before changing this identity.
  static const visionOs = YoutubeApiClient(
    {
      'context': {
        'client': {
          'clientName': 'VISIONOS',
          'clientVersion': '1.02',
          'deviceMake': 'Apple',
          'deviceModel': 'RealityDevice17,1',
          'osName': 'visionOS',
          'osVersion': '26.5.23O471',
          'userAgent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 '
              '(KHTML, like Gecko) Version/26.0 Safari/605.1.15',
          'hl': 'en',
          'timeZone': 'UTC',
          'utcOffsetMinutes': 0,
        },
      },
    },
    'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
    clientId: 101,
  );

  /// Provides high-quality muxed streams through an HLS manifest.
  /// The streams are in m3u8 format.
  static const safari = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'WEB',
        'clientVersion': '2.20250312.04.00',
        'userAgent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15,gzip(gfe)',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  /// Existing restricted-content fallback with separate limitations.
  static const tv = YoutubeApiClient(
    {
      'context': {
        'client': {
          'deviceMake': '',
          'deviceModel': '',
          'userAgent':
              'Mozilla/5.0 (ChromiumStylePlatform) Cobalt/Version,gzip(gfe)',
          'clientName': 'TVHTML5',
          'clientVersion': '7.20251105.10.00',
          'hl': 'en',
          'timeZone': 'UTC',
          'gl': 'US',
          'utcOffsetMinutes': 0,
          'originalUrl': 'https://www.youtube.com/tv',
          'theme': 'CLASSIC',
          'platform': 'DESKTOP',
          'clientFormFactor': 'UNKNOWN_FORM_FACTOR',
          'webpSupport': false,
          'configInfo': {},
          'tvAppInfo': {'appQuality': 'TV_APP_QUALITY_FULL_ANIMATION'},
          'acceptHeader':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
        'user': {'lockedSafetyMode': false},
        'request': {'useSsl': true},
      },
      'contentCheckOk': true,
      'racyCheckOk': true,
    },
    'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
    headers: {
      'Sec-Fetch-Mode': 'navigate',
      'Content-Type': 'application/json',
      'Origin': 'https://www.youtube.com',
    },
  );

  static const mediaConnect = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'MEDIA_CONNECT_FRONTEND',
        'clientVersion': '0.1',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  /// Sometimes includes low-quality streams, for example 144p12.
  static const mweb = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'MWEB',
        'clientVersion': '2.20240726.01.00',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  @Deprecated('Youtube always requires authentication for this client')
  static const webCreator = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'WEB_CREATOR',
        'clientVersion': '1.20240723.03.00',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  /// Provides low-quality muxed streams for some restricted videos but
  /// requires signature deciphering and fails when embedding is disabled.
  @Deprecated('Youtube always requires authentication for this client')
  static const tvSimplyEmbedded = YoutubeApiClient(
    {
      'context': {
        'client': {
          'clientName': 'TVHTML5_SIMPLY_EMBEDDED_PLAYER',
          'clientVersion': '2.0',
          'hl': 'en',
          'timeZone': 'UTC',
          'gl': 'US',
          'utcOffsetMinutes': 0,
        },
      },
      'thirdParty': {'embedUrl': 'https://www.youtube.com/'},
      'contentCheckOk': true,
      'racyCheckOk': true,
    },
    'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
    headers: {
      'Sec-Fetch-Mode': 'navigate',
      'Content-Type': 'application/json',
      'Origin': 'https://www.youtube.com',
    },
  );
}
