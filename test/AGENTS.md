# Test Agent Guide

Applies to `test/**`. Read the root `AGENTS.md` first.

## Network regressions

YouTube behaviour is remote and mutable. Tests for extraction fixes must exercise the layer that previously failed.

- A player-response regression should assert player behaviour.
- A stream/CDN 403 regression must read actual media bytes, not only assert that a manifest contains entries.
- For a new default client, cover audio-only and video-only when both are expected.
- For HLS/DASH fixes, exercise a media fragment where feasible.
- Keep representative video IDs stable and non-sensitive. Add a short comment when a fixture exists for a specific content category or failure mode.

GitHub-hosted runners may be blocked by YouTube. Existing `skipGH` behaviour is intentional. Do not delete a valuable network regression solely because hosted CI cannot execute it; keep deterministic unit tests in CI and document required local network verification in the PR.

## Test quality

- Avoid assertions tied to an exact number of formats unless the count is itself the contract.
- Prefer semantic assertions: non-empty expected stream class, readable bytes, expected exception type, preserved metadata.
- Do not make tests pass by swallowing network errors or broadly retrying indefinitely.
- Every production bug fix should have a regression test when the failure can be reproduced safely.
