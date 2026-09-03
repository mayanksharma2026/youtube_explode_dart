# Test Agent Guide

This file extends the root [`AGENTS.md`](../AGENTS.md) for `test/`.

## Test classes

### Deterministic tests

- No live network, account state, local timezone, or random video IDs.
- Use small sanitised fixtures and fake HTTP clients.
- Assert request method, URL/range, headers, status handling, and emitted bytes for transport changes.
- A regression should fail for the specific previous defect.

### Live YouTube tests

- Clearly label and isolate them.
- Use stable, public, non-sensitive video IDs.
- Set finite timeouts.
- Skip only in environments known to be blocked; do not weaken assertions globally.
- For media incidents, read real bytes from at least one audio-only and one video-only stream where available.
- Do not commit signed media URLs or response data containing identifiers/tokens.

## Review standard

A client-profile test that only checks `manifest.isNotEmpty` is insufficient for a CDN 403 incident. Verify an actual byte chunk and preserve a deterministic unit test for any local transport bug discovered during the incident.