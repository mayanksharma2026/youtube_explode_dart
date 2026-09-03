# Video Extraction Agent Guide

Applies to `lib/src/videos/**`. Read the root `AGENTS.md` first. For `streams/**`, also read `streams/AGENTS.md`.

## Responsibilities

This subtree owns video metadata, InnerTube client profiles, stream extraction and related video APIs. Changes here can make YouTube return a valid player response while producing unusable media URLs, so player success is not proof of stream success.

## InnerTube client changes

- Define profiles only in `youtube_api_client.dart`.
- Before adding/updating a profile, compare current definitions in `yt-dlp` and at least one other maintained extractor when available.
- Record client name/version, device/OS identity, endpoint, headers, PO-token policy, JS-player/signature requirements and known content limitations in `docs/client-profiles.md`.
- Keep identity fields internally coherent. Do not invent random user agents, device models or versions to evade detection.
- Treat a client as healthy only after its returned media URL is actually readable.
- A profile that requires a PO token must not be described as token-free merely because the player endpoint succeeds.

## Default-client changes

Changing the implicit default in `StreamClient.getManifest` is a behaviour change. Require:

- evidence that the previous default is failing;
- explicit test coverage for the replacement;
- media-byte validation for audio and video where the profile provides them;
- documented known limitations and fallback behaviour;
- no unrelated parser/transport changes in the same PR unless required by the root cause.

Current fork context (2026-09): VisionOS was adopted after Android SDK-less/Android VR/iOS direct media URLs began returning 403 under newer GVS PO-token enforcement. Revalidate this statement when maintaining the profile; do not assume it remains true indefinitely.
