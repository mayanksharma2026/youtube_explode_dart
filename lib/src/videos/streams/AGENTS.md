# Stream Resolution Agent Guide

Applies to `lib/src/videos/streams/**`. Read `../../../AGENTS.md` conceptually via the repository root `AGENTS.md`, then `../AGENTS.md`.

## Core invariant

A stream is usable only when the media transport is usable. A successful watch page, player response, DASH/HLS parse, or populated `StreamManifest` is not enough.

## Failure classification

Before changing code, identify whether the failure is:

- player API/playability;
- signature or `n` challenge;
- PO-token requirement;
- stale/invalid client identity;
- CDN HTTP 403/4xx;
- range-request or request-header behaviour;
- DASH/HLS parsing;
- fragment handling;
- content-specific restriction;
- transient/rate-limit/network behaviour.

Do not solve one category by suppressing another category's error.

## Validation

For direct streams, prefer a small real media read/range request when testing reachability. Preserve required per-stream headers if YouTube supplies them. HEAD can be useful as a probe but must not be assumed equivalent to the actual GET/range request for every client/CDN behaviour.

For HLS/DASH, validate the manifest and at least one media fragment where practical.

## Fallbacks

- Fallbacks must be deterministic and evidence-backed.
- Avoid trying a long list of known-broken clients on every request; it increases latency and can amplify throttling/rate limiting.
- Do not silently remove audio-only/video-only streams when their URLs fail and return a partial manifest as if the request succeeded.
- Preserve the most useful root-cause error when all candidates fail.
- Content-specific fallback (for example a profile that cannot access a known content category) is preferable to broad blind retries when evidence supports it.

## Review questions

Before approving a stream change ask:

1. Does this fix the actual media request or only manifest generation?
2. Does it preserve request headers/range semantics?
3. Does it introduce extra network requests on the healthy path?
4. Could it hide a 403 or token/challenge failure?
5. Is fallback bounded and observable?
6. Is the behaviour represented by an integration regression test?
