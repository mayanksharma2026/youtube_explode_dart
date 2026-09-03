# Reverse Engineering and Transport Agent Guide

This file extends the root [`AGENTS.md`](../../../AGENTS.md) for `lib/src/reverse_engineering/`.

## Scope

This subtree owns HTTP transport, watch/player page parsing, DASH/HLS parsing, JS challenge integration, heuristics, and low-level response models.

## Transport rules

- Preserve caller-provided headers on every request path, including retries, range requests, fragments, playlists, and segments.
- Default headers must never overwrite an explicit caller header.
- Use bounded retry with meaningful classification. Respect 429 and do not convert it into aggressive retries.
- Preserve original exception/stack trace when retry/fallback is exhausted.
- Validate the operation that matters: use a small real media range for a playback incident rather than relying only on HEAD.
- Avoid printing full request URLs for signed `googlevideo` resources; query parameters may be sensitive or short-lived.

## Parser rules

- Add captured, sanitised fixtures for deterministic response-shape changes.
- Parse each item defensively so one malformed entry does not discard an entire page, but do not silently swallow page-level corruption.
- Prefer typed helpers and explicit null handling over broad `catch (_) {}` blocks.
- Keep app-policy filtering (for example, excluding members-only content) outside general-purpose parsing unless the public API explicitly defines it.

## Challenges and tokens

- Signature/`n` challenge solving and PO-token support are separate concerns.
- Do not claim that a client is token-free solely because one URL worked.
- Do not implement credential, cookie, or token collection without an explicit, reviewed public API and security design.
- Compare current `yt-dlp`, EJS, and other mature implementations before changing challenge logic.