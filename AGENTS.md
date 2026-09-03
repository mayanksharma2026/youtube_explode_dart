# Repository Agent Guide

This is the canonical instruction file for coding agents working in this fork of `youtube_explode_dart`.

## Instruction hierarchy

Read this file first. Before editing a subtree, also read the nearest folder-level `AGENTS.md`:

- [`.github/AGENTS.md`](.github/AGENTS.md) — workflows, issue forms, and pull-request standards.
- [`docs/AGENTS.md`](docs/AGENTS.md) — evidence, source registry, dates, and decision records.
- [`lib/src/videos/AGENTS.md`](lib/src/videos/AGENTS.md) — player profiles, video APIs, manifests, and stream selection.
- [`lib/src/reverse_engineering/AGENTS.md`](lib/src/reverse_engineering/AGENTS.md) — HTTP, pages, manifests, and challenge solving.
- [`test/AGENTS.md`](test/AGENTS.md) — deterministic and live regression tests.
- [`tool/AGENTS.md`](tool/AGENTS.md) — read-only source intelligence, registry parsing, and report automation.

All folders without a local guide inherit this file and the nearest parent guide. Do not add an `AGENTS.md` to every leaf folder. Add one only when a subtree has materially different rules.

A lowercase [`agent.md`](agent.md) exists only as a compatibility pointer.

## Repository purpose

The upstream project is [`Hexer10/youtube_explode_dart`](https://github.com/Hexer10/youtube_explode_dart). This fork exists to:

1. keep production consumers operational when YouTube changes an undocumented interface;
2. carry small, auditable compatibility fixes while upstream review is pending;
3. make future failures reproducible and researchable by humans and coding agents;
4. upstream generally useful fixes whenever practical.

The package uses undocumented YouTube web and player interfaces. Client identities, response shapes, signature transforms, PO-token requirements, signed media URLs, and rate limits are server-controlled and may change without notice.

## Current compatibility context

As of 2026-09-03, Android VR, iOS, and Android SDK-less profiles were returning manifests whose direct media URLs commonly failed with HTTP 403 after YouTube expanded GVS PO-token enforcement. The current remediation work evaluates the Apple Vision Pro `VISIONOS` profile and correct client-to-media request affinity.

Relevant context:

- Incident: <https://github.com/Hexer10/youtube_explode_dart/issues/386>
- Candidate PRs: <https://github.com/Hexer10/youtube_explode_dart/pull/388>, <https://github.com/Hexer10/youtube_explode_dart/pull/389>, and <https://github.com/Hexer10/youtube_explode_dart/pull/390>
- Decision record: [`docs/decisions/0001-visionos-default-client.md`](docs/decisions/0001-visionos-default-client.md)
- Source registry: [`docs/maintenance-sources.yaml`](docs/maintenance-sources.yaml)
- Human-readable source guide: [`docs/upstream-sources.md`](docs/upstream-sources.md)
- Dart fork survey: [`docs/fork-survey.md`](docs/fork-survey.md)
- Read-only source watcher: [`docs/source-watch.md`](docs/source-watch.md)

Do not treat any working client profile as permanent.

## Architecture map

- `lib/youtube_explode_dart.dart`: public package entry point.
- `lib/src/videos/`: video metadata, InnerTube client profiles, manifests, and stream APIs.
- `lib/src/reverse_engineering/`: transport, watch/player pages, manifests, heuristics, and JS challenge integration.
- `lib/src/search/`, `lib/src/channels/`, `lib/src/playlists/`: feature-specific parsers and continuation flows.
- `test/`: unit tests plus opt-in live YouTube tests.
- `tool/`: dependency-free, read-only source intelligence and its deterministic tests.
- `docs/`: operations, incident response, source map, fork survey, profile status, release process, and decisions.

## Non-negotiable engineering rules

1. **Prefer the smallest evidence-backed patch.** Do not combine a client-profile fix with parser rewrites, retry changes, unrelated dependency updates, or repository-wide formatting.
2. **Research before porting.** Check upstream Dart issues/PRs, maintained Dart forks, production downstream copies, and mature implementations in other languages before designing a fix.
3. **Compare; do not blindly copy.** Reproduce the failure, identify the protocol layer, compare independent implementations, review licensing and attribution, and adapt the smallest correct design to this codebase.
4. **Do not invent or randomise fingerprints.** Do not rotate random client versions, devices, user agents, headers, request order, delays, or IPs to evade detection. Random incoherent identities are fragile and can trigger additional enforcement. Use deterministic, internally consistent profiles that are supported by evidence.
5. **Use health-based compatibility, not stealth.** Prefer explicit profiles, real media validation, bounded retry/backoff, clear observability, and a documented fallback policy. Respect HTTP 429 and other service limits.
6. **A parsed manifest is not proof of playback.** When the incident concerns CDN access, a regression must fetch actual media bytes or a byte range.
7. **Preserve client affinity.** Player requests, manifest requests, content-length probes, byte-range downloads, fragments, and HLS segments must use the headers required by the client that minted the URL.
8. **Do not silently discard failed stream types.** Do not hide inaccessible audio-only or video-only streams by returning muxed streams only. Surface the failure and let fallback policy decide.
9. **Explicit caller choices win.** When `ytClients` is supplied, do not append hidden clients or reorder the list.
10. **Do not log secrets.** Never print cookies, authorization headers, visitor data, PO tokens, account identifiers, signed media URLs, or full request bodies containing them.
11. **Do not weaken transport security.** No TLS bypass, certificate suppression, open proxy injection, credential scraping, or anti-abuse circumvention.
12. **Preserve public API compatibility unless deliberately versioned.** Avoid deleting profiles simply because they are temporarily unhealthy.
13. **Keep fork-only changes easy to rebase.** Protocol hotfixes must have narrow diffs and clear provenance.
14. **State uncertainty precisely.** Write “observed on 2026-09-03” rather than “never requires a token”.
15. **Automation reports; maintainers decide.** Source monitoring may compare registered revisions and produce artefacts, but must never cherry-pick, merge, modify the registry, or open protocol changes automatically.

## Required workflow for a YouTube breakage

### 1. Capture the incident

Use the YouTube breakage issue form or the same structure in a PR if Issues are unavailable. Record:

- exact UTC date/time;
- package commit/tag, Dart/Flutter version, platform, and network environment;
- public reproducible video IDs;
- operation, selected client profile(s), status code, and exception;
- whether player/manifest parsing succeeded;
- whether a real media byte-range succeeded;
- redacted logs and observed scope.

### 2. Classify before editing

Determine which layer failed:

- watch-page or initial-data parsing;
- InnerTube player request or client identity;
- playability status;
- signature or `n` challenge;
- PO-token policy;
- DASH/HLS parsing;
- direct `googlevideo` access and request headers;
- continuation/search/channel response shape;
- rate limiting or IP reputation.

Do not label every 403 as rate limiting. Distinguish 403, 429, authentication, geo restriction, unavailable content, and challenge failure.

### 3. Review the source registry

Read [`docs/maintenance-sources.yaml`](docs/maintenance-sources.yaml), [`docs/upstream-sources.md`](docs/upstream-sources.md), [`docs/fork-survey.md`](docs/fork-survey.md), and the latest source-watch report when available. Refresh stale commit references and add newly relevant maintained forks.

Run the read-only source comparison when useful:

```bash
python -m unittest -v tool.test_source_watch
python tool/source_watch.py \
  --registry docs/maintenance-sources.yaml \
  --output-dir source-watch-report
```

At minimum, compare:

- `yt-dlp/yt-dlp` for client definitions, PO-token policy, player extraction, and EJS integration;
- `Tyrrrz/YoutubeExplode` for the C# architecture and protocol fixes;
- `TeamNewPipe/NewPipeExtractor` for Java extractor behaviour;
- `LuanRT/YouTube.js` for TypeScript InnerTube behaviour;
- maintained Dart forks and production embedded copies listed in the registry.

Use exact commits or permanent links in the issue/PR. A downstream app can confirm impact but is not, by itself, a protocol source of truth. A changed source-watch head is a queue item for analysis, not an approved fix.

### 4. Write the failing regression first

For deterministic parsing defects, add a fixture/unit test. For live protocol failures, add a narrowly named, time-bounded live test with stable public IDs. The test must prove the failing layer rather than a preceding step.

### 5. Implement the minimum coherent change

Port the behaviour, not the syntax. Preserve coherent client metadata, required headers, token assumptions, and request lifecycle. Keep unrelated improvements in separate PRs.

### 6. Validate

Run:

```bash
dart pub get
dart analyze
dart test
```

For client/stream changes, also run the targeted live test locally and verify actual media bytes. Test normal video, audio-only, video-only, and a known failure case. Add live/HLS, age-restricted, members-only, geo-restricted, or made-for-kids coverage only when relevant and reliably reproducible.

### 7. Document and release

Update the affected records:

- `docs/client-profiles.md` for client or policy changes;
- `docs/maintenance-sources.yaml` and `docs/fork-survey.md` when sources change;
- `docs/decisions/` for defaults, fallback, public API, or architecture decisions;
- `docs/fork-changelog.md` for user-visible fork behaviour;
- `README.md` for installation, defaults, or limitations.

Follow [`docs/release-process.md`](docs/release-process.md). Consumers must pin a release tag or full commit SHA, not a moving branch.

## Testing policy

- Unit tests must not depend on live network access, local time, random videos, or account state.
- Live tests must be isolated, clearly named, finite, and skipped where hosted runners are known to be blocked.
- Never weaken an assertion merely to accommodate an unexplained server change.
- Never commit signed stream URLs; they expire and may contain tracking data.
- A media-access fix is incomplete unless at least one test reads real bytes.
- Source-watch network access must be outside deterministic unit tests and must never execute downloaded code.

## Pull-request standard

A protocol PR must explain:

- user-visible failure and first known date;
- root-cause evidence and competing hypotheses considered;
- upstream, fork, downstream, and cross-language implementations reviewed;
- why the selected design is safer than alternatives;
- tests before/after, affected clients/platforms, risks, rollback, and revalidation trigger;
- documentation updated and attribution retained.

Do not merge because one video plays once. Review the complete diff for unrelated changes and test a small matrix of videos and stream types.

## Upstream sync

Do not force-push a stable/release branch. Sync upstream through a dedicated branch and PR. Preserve upstream commits and attribution where practical. See [`docs/fork-maintenance.md`](docs/fork-maintenance.md).

## Definition of done

Code, tests, documentation, source registry, agent guidance, changelog, and PR description must agree. Any unresolved assumption must have a concrete validation step.