# InnerTube Client Profiles

Last reviewed: 2026-09-04.

This file records compatibility assumptions used by this fork. YouTube controls these behaviours remotely; revalidate before relying on an old status.

| Profile | Role in this fork | Observed concern / requirement |
| --- | --- | --- |
| `visionOs` | Preferred explicit compatibility profile for the 2026 media-403 incident | At review time returned fetchable direct media without a GVS PO token and did not require JS signature solving. Known ecosystem limitation: VisionOS may not cover every content category (notably made-for-kids in some extractors). |
| `androidSdkless` | Existing upstream default; retained while adoption remains explicit | Direct non-muxed media became unreliable/403 under 2026 PO-token changes. Do not assume token-free operation. |
| `androidVr` | Explicit/legacy compatibility profile | 2026 ecosystem reports show GVS PO-token enforcement and direct media 403s. |
| `ios` | Explicit/legacy compatibility profile | Player responses can succeed while direct media requires newer token handling and returns 403 without it. |
| `safari` | Additional profile when a JS solver is configured | Web/Safari behaviour can involve JS challenges and evolving PO-token/session policy. |
| `tv` | Existing final fallback for some restricted cases | May require signature deciphering depending on returned streams. Keep fallback bounded and observable. |

## VisionOS identity

The current profile is intentionally deterministic:

- client name: `VISIONOS`
- client version: `1.02`
- device make: `Apple`
- device model: `RealityDevice17,1`
- OS: `visionOS`
- OS version: `26.5.23O471`
- browser-like user agent matching the known VisionOS profile

These values were adopted from independently maintained extractor research and the Dart PR that reproduced the 403 incident. Do not "freshen" individual fields independently. A coherent old identity is preferable to an invented mixture of versions unless testing shows YouTube rejects it.

## How to promote a new default profile

A candidate default must have:

1. corroboration from a maintained extractor or reproducible protocol analysis;
2. a coherent client/device/OS identity;
3. documented PO-token, authentication and JS-player requirements;
4. a normal-video manifest containing expected stream classes;
5. an actual readable audio media request;
6. an actual readable video media request when provided;
7. documented content limitations;
8. bounded fallback behaviour;
9. a regression test that fails under the previous broken behaviour.

Changing the library-wide implicit default should be a separate reviewed decision from merely adding a working client profile. This keeps a compatibility patch easier to upstream and lets consumers opt in explicitly while evidence is still evolving.

## Why not randomize profiles?

Random client versions, user agents, device models or headers can create combinations no real YouTube client emits. They also make failures nondeterministic and complicate debugging. This fork treats realism, consistency and rapid profile replacement as more robust than uncontrolled spoof rotation.

If future evidence demonstrates server-side bucketing that legitimately requires controlled variation, implement it as a named strategy with bounded inputs, telemetry/logging and tests—not ad-hoc randomness.
