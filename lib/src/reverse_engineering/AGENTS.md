# Reverse-engineering guidance

Read the repository-level [`AGENTS.md`](../../../AGENTS.md) first. This file applies to `lib/src/reverse_engineering/` and its descendants.

## Responsibility of this subtree

This subtree owns the low-level interaction with YouTube pages and internal APIs: HTTP request construction, watch/player pages, response models, challenge handling, parsers, retries and transport details. Changes here can affect every public feature, not only streams.

## Required evidence

Before changing a request payload, header, endpoint, parser or challenge path, establish:

- the exact failing request and response status/body shape;
- the client profile used by the request;
- whether the failure is deterministic, content-specific, session-specific, region-specific or rate-related;
- the equivalent current behaviour in at least one mature extractor;
- whether the proposed fields form one coherent real client identity.

Link the relevant source or commit in the pull request and in an ADR when the change is cross-cutting.

## Request construction rules

- Do not mix fields copied from different client families. Client name, version, user agent, device, OS, API host, key and headers must make sense together.
- Do not update a generic WEB payload merely because a stream-specific client failed.
- Add visitor data, cookies, authentication, PO tokens or playback context only when the endpoint and client require them and the lifecycle is understood.
- Never generate, persist or log sensitive session values casually.
- Preserve caller-supplied headers and explicit client payloads unless the API contract requires controlled augmentation.
- Avoid global mutable client state. Concurrent calls must not leak identity or session material into one another.

## Challenge and signature rules

Treat these as separate mechanisms:

- signature (`s`) deciphering;
- `n` parameter transformation;
- player PO tokens;
- GVS/media PO tokens;
- subtitle PO tokens;
- cookies/authenticated sessions.

Do not describe one mechanism as fixing another without packet-level evidence. A client that currently avoids one challenge may acquire that requirement later.

When modifying solver integration:

- keep bulk and individual fallback behaviour bounded;
- preserve the original exception and stack trace when all paths fail;
- do not retry deterministic parser or contract failures as if they were transient;
- add fixtures for parsing/transform logic independently of live YouTube tests.

## Parser rules

- Prefer tolerant parsing only when it preserves semantic correctness.
- Do not silently convert malformed required data into an empty collection.
- Include a minimal redacted fixture that reproduces every parser regression.
- Keep HTML/JSON fixture content as small as possible and remove identifiers, cookies and signed URLs that are not required by the test.
- Account for alternate response branches explicitly rather than relying on unchecked map indexing.

## Retry and transport rules

- Retry only failures that can reasonably be transient.
- Keep attempts, delays and total elapsed time bounded.
- Do not multiply retries across nested layers without calculating the worst-case request count.
- Honour cancellation/closure behaviour of the underlying HTTP client.
- Do not treat HTTP 403 as universally transient; for media URLs it often indicates a client/token/session contract failure.
- Avoid logging full request URLs when query parameters may contain signatures or tokens.

## Tests required by change type

| Change | Minimum coverage |
| --- | --- |
| JSON/HTML parser | deterministic fixture test |
| Header or payload merge | deterministic request-construction test |
| Signature/`n` logic | deterministic known-input test plus failure case |
| New client-related request path | payload test and focused live smoke test |
| Retry behaviour | attempt-count, terminal-error and timeout tests |

Live tests supplement deterministic tests; they do not replace them.

## Scope control

If a client profile alone fixes the incident, change the profile under `lib/src/videos/` rather than broad request construction here. Do not combine an unrelated watch-page parser refresh, generic WEB version update or live-stream change with a client-profile patch.
