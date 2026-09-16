# Regular maintenance: 2026-09-16 UTC

## Baseline

- Maintenance started: 2026-09-16T19:22:20Z. This filename uses UTC; the local India date is 2026-09-17.
- Repository/default base: `mayanksharma2026/youtube_explode_dart`, `master`.
- Base HEAD: `b1cef42590420b0b8dd1707f37c1cd9598eaf19c`; tree: `38b205bd41e7fbda3fe4f983b08592a423ea7da3`.
- Package: `youtube_explode_dart` 3.1.0; Dart constraint: `>=3.0.0 <4.0.0`.
- Baseline [Dart CI run 35139611516](https://github.com/mayanksharma2026/youtube_explode_dart/actions/runs/35139611516): success. Job 104940540328 reports dependency installation, formatting, analysis and the configured deterministic tests successful. This is not evidence for unrestricted `dart test` or live playback.
- Open PR and issue lists were empty at baseline. PR #12 is already merged and fixes Chameleon tracking to `main`; do not repeat that change.
- No existing local checkout was available. Git clone failed with `Could not resolve host: github.com`; no unrelated working tree was modified. The authorized workstation returned `No devices available`. Read-only GitHub connector access works. Changes will use a new branch from the exact base SHA through GitHub, not a simulated local origin fetch.
- Exact local copies of the registry and Python tool/tests were verified against GitHub blob hashes. Baseline `python -m unittest -v tool.test_source_watch`: 9 passed. Python compilation passed. The local workspace is a partial audit workspace, not a full Dart checkout.
- Local `dart pub get`, `dart format --output=none --set-exit-if-changed .`, `dart analyze`, and `dart test` each return exit 127, `dart: command not found`. No local Dart result is claimed.

## Instructions and scope resolution

Read root `AGENTS.md` and `agent.md`, `.github/AGENTS.md`, `docs/AGENTS.md`, all maintenance documents listed in the request, ADR 0001, `test/AGENTS.md`, `tool/AGENTS.md`, and both videos/reverse-engineering guides. Root, docs and tool rules were re-read for this plan gate.

The source registry's `branch` is the explicitly tracked branch, not necessarily the default. The docs instruction to record a default branch must not overwrite an intentionally tracked PR branch: Lydonator's default remains `master`, while PR #389's reviewed implementation lives on `add-visionos-client`. Record both facts rather than inventing a default-branch fallback.

The missing full checkout, Dart SDK and live network gates are not waived. This run may implement deterministic maintenance-metadata corrections and documentation, but must leave its PR Draft while mandatory validation is incomplete. No production Dart or watcher implementation change is authorized by this plan.

## Canonical upstream status

Canonical upstream: `Hexer10/youtube_explode_dart`, `master`.
Previous and current SHA: `44a39a65d8e274806247d52af8f0bacd77691d38` (2026-05-09, `dartfmt`). GitHub comparison from this SHA to the base reports the fork **18 ahead, 0 behind**, with this same merge base. Upstream synchronization is unnecessary. Any future sync belongs in a separate PR under `docs/fork-maintenance.md`.

The existing fork already implements a VisionOS profile/default, classified Android/TV compatibility fallback, and request-scoped copies of client context. These are not new changes in this cycle. No fork patch is shown to be superseded by a new canonical commit.

## Source intelligence

The complete registry was parsed with its own `parse_registry`; it contains **24 sources**. All 24 configured refs were resolved using GitHub connector GET requests. The following inventory was compiled at **2026-09-16T19:49:44Z** from this run's reads; the review timestamp applies to the metadata inventory, not a claim of live protocol validation or an exhaustive code audit of every repository.

`current` means exact recorded equality; `changed` means a mismatch, not necessarily forward movement. Initial counts: **12 current, 9 changed, 3 unreviewed**. After resolving the two provenance defects below, there are **8 genuine forward commit ranges**; Lydonator is a wrong-branch comparison, and Jameszhou needs its malformed old SHA corrected before comparison.

| Repository | Registered role | Configured branch at baseline | Previously recorded SHA | Resolved branch HEAD | Status |
| --- | --- | --- | --- | --- | --- |
| `Hexer10/youtube_explode_dart` | upstream | `master` | `44a39a65d8e274806247d52af8f0bacd77691d38` | `44a39a65d8e274806247d52af8f0bacd77691d38` | current |
| `yt-dlp/yt-dlp` | primary-protocol-reference | `master` | `bbc809a1161d3bfca51fa36f59dda35556ee85a0` | `c7fb478d21e9e59524befbe23f7801bb267fb880` | changed |
| `Tyrrrz/YoutubeExplode` | architecture-and-protocol-reference | `prime` | `5d7f8343e73ee8361474a9113e983dce2e8af2f3` | `5d7f8343e73ee8361474a9113e983dce2e8af2f3` | current |
| `TeamNewPipe/NewPipeExtractor` | independent-extractor-reference | `dev` | `13a655fe53e0c3065f88725fc1fb594c3ede0169` | `8584a0d636ce6b8371d2c5c83dbe7f01a3d21d59` | changed |
| `LuanRT/YouTube.js` | innertube-reference | `main` | `a480854c501406cf55c9eb7ad5b540ab36a65b56` | `2b80e3ef35f658bb2af573aa5f84b79d928e58d0` | changed |
| `iv-org/invidious` | independent-service-reference | `master` | `b3a3f3a6df47d090c22c2f16bb8128688020538d` | `c88230067b7a3abbb569ac0938bf8d897c8340be` | changed |
| `Brainicism/bgutil-ytdlp-pot-provider` | po-token-specialist-reference | `master` | `09f2f0a7cbd0d091b3b59178b36fe827d9094ec6` | `37169ee2656e08c5c2e5dc9df4c598c0cb4c88a8` | changed |
| `lydonator/youtube_explode_dart` | focused-fix-source | `master` | `f6c104c8a0efe3e7bb9e3f859ca4addc45ad5926` | `44a39a65d8e274806247d52af8f0bacd77691d38` | changed |
| `justacalico/youtube_explode_dart` | active-fork | `master` | `c80de2735c18be0cccc283fe840b48f1b183b4e1` | `c80de2735c18be0cccc283fe840b48f1b183b4e1` | current |
| `its-ashutosh-pathak/youtube_explode_dart` | active-fork | `master` | `edad2760cc7998bcc18013dc9880c052ad32598f` | `edad2760cc7998bcc18013dc9880c052ad32598f` | current |
| `vargasgustavo/youtube_explode_dart` | mirror-of-active-fix | `fix-visionos-403` | `edad2760cc7998bcc18013dc9880c052ad32598f` | `edad2760cc7998bcc18013dc9880c052ad32598f` | current |
| `gmstyle/youtube_explode_dart` | active-fork | `master` | `fe43c513ea35c2352f00b2ce650083c81c3e4a57` | `fe43c513ea35c2352f00b2ce650083c81c3e4a57` | current |
| `onyxmusic/youtube_explode_dart` | active-fork | `master` | `ada5cb6758388421c931ebf10f63e1a1cf2acfa5` | `ada5cb6758388421c931ebf10f63e1a1cf2acfa5` | current |
| `Bikram-Kumar/youtube_explode_dart` | active-fork | `master` | `6f28a8bf0f00c1ef7073c335bafe48f8bab05edc` | `6f28a8bf0f00c1ef7073c335bafe48f8bab05edc` | current |
| `jameszhou123/youtube_explode_dart` | parser-focused-fork | `master` | `cbe63502884da2fa0f0f09a9784fa831ab5867` | `a1ce972191d13a257e21394bcb4bd4268b4a2b75` | changed |
| `hamza72x/youtube_explode_dart` | playlist-parser-fork | `hoytoba/playlist-lockup-fix` | `86cd5a97b6bad4e4907d04d8c167ab3b6ad943b0` | `86cd5a97b6bad4e4907d04d8c167ab3b6ad943b0` | current |
| `isacRU11/youtube_explode_dart` | parser-fork | `master` | `75a7292284851c210fc7909ab6644cef058cfb16` | `75a7292284851c210fc7909ab6644cef058cfb16` | current |
| `luskan/youtube_explode_dart` | maintenance-and-caption-reference | `master` | `f34c7d1858ded3de6cc4e979d1f33f6b1522b5d5` | `f34c7d1858ded3de6cc4e979d1f33f6b1522b5d5` | current |
| `jngapp/youtube_explode_dart` | client-version-watch | `master` | `6b3c58ec0b959599ef2d22653ca99c8ae382689b` | `6b3c58ec0b959599ef2d22653ca99c8ae382689b` | current |
| `gokadzev/Musify` | production-downstream-and-embedded-fork | `master` | `0285d0b63398317faa41c12d74388d204b1955a2` | `a594f7c5c2c61d851b22b23fad1630cb1852b403` | changed |
| `souravkaushik-dev/chameleon` | downstream-signal | `main` | `d20b589a6ad82b3486f3b88a7a8be0c487b0d147` | `9360b48dc4f08ab14329a57da6b2d23f9f4ab48a` | changed |
| `KRTirtho/youtube_explode_dart` | historical-maintained-fork | `master` | `not recorded` | `7bf4605f520c5f6f545c94dd22bea7edacfae9c7` | unreviewed |
| `krishnapalsendhav/youtube_explode_dart_plus` | historical-feature-fork | `master` | `not recorded` | `d12103820918b8730877ece4a194cc180a8dec16` | unreviewed |
| `5alafawyyy/youtube_explode_dart_plus` | historical-modernisation-fork | `main` | `not recorded` | `10ebf3906b911b619d86c3c8d814a76055fafbee` | unreviewed |

### Review depth, ranges and provenance

All unchanged entries received branch/head verification; their historical implementation reviews are not re-dated. The three watch-only repositories remain unreviewed implementation references. No external code was executed and no external repository was modified.

For changed entries, the range is `previous...current` using the full SHAs in the inventory, except the explicit Lydonator/Jameszhou corrections below. Commit summaries and changed-path inventories were inspected. Focused patches were read where named in the evidence table; large downstream ranges are not claimed to have received a full code audit.

| Source | Range review and exact scope | Disposition of reviewed SHA |
| --- | --- | --- |
| yt-dlp | 1 commit; full PR #17684 diff in `_base.py` and `_video.py` | Preserve historical checkpoint; record this scoped review here. |
| NewPipeExtractor | 1 commit; only `gradle/libs.versions.toml`, protobuf-javalite 4.36.0 to 4.36.1 | No YouTube extractor delta; preserve checkpoint. |
| YouTube.js | 3 commits; show-tab/feed/lockup changes and attribution metadata; PR #1260 diff and current LockupView/Feed inspected | Feature additions remain deferred; preserve checkpoint. |
| Invidious | 10 commits; transport/header PRs #6038 and #6040 read in full; remaining build/dependency/ID-validation changes classified from commit/path metadata | Not a complete implementation review of all 10 commits; preserve checkpoint. |
| bgutil provider | 2 commits since checkpoint; PR #262 diff and official 2.0.0 release/security notes reviewed | No provider integration or port; preserve checkpoint. |
| Lydonator | `master` is upstream baseline. PR #389 identifies `add-visionos-client`, verified at `f6c104c8a0efe3e7bb9e3f859ca4addc45ad5926` | Correct branch only; retain reviewed SHA/date. |
| Jameszhou | Invalid stored 38-character SHA returns HTTP 422. Prefix `cbe6350` resolves to `cbe63502884da2fa0afc0f09a9784fa831ab5867`; its historical patch was inspected. Corrected-old to current is 2 commits; current About/header fix read in full | Correct historical typo only, not advance to current; retain historical date. |
| Musify | 23 commits; no changes under `packages/youtube_explode_dart`; app audio-selection commit `1db94fcdbd195f4c4c4b66ad5d9ee00f8d9d4b1b` inspected in full | Consumer-policy signal, not a library protocol update; preserve checkpoint. |
| Chameleon | 18 commits; large app/embedded-package addition. Selected embedded `stream_client.dart` probe/default logic inspected at current HEAD | Partial focused review only; preserve checkpoint. |

Issue/PR searches covered canonical upstream and the changed-source issue queues. Relevant source statements include Invidious #5971/#6036/#6041, provider #242/#265, YouTube.js #1261 and NewPipe #1546. These are external reports or feature requests, not local reproductions. Searches were bounded, not an assertion that every historical discussion was read. Canonical PR #391 is closed, unmerged, and carries the same `f6c104c8a0efe3e7bb9e3f859ca4addc45ad5926` as #389; it is not independent confirmation. Ashutosh and Vargas likewise share `edad2760cc7998bcc18013dc9880c052ad32598f`.

### Actual source-watch run

Ran `python tool/source_watch.py --registry docs/maintenance-sources.yaml --output-dir source-watch-report`. It wrote both supported reports at **2026-09-16T19:33:55Z**, then exited **1**: 24 errors, all DNS failures (`Temporary failure in name resolution`). This is an environment failure, not 24 deleted repositories or a passing report. The connector inventory above is a separate read-only recovery of source intelligence, not a substituted successful CLI run. Re-run the documented CLI from a network-enabled environment before closing that gate.

## Findings and decisions

| Decision | Exact evidence and date | Affected layer / observation | Independent confirmation, competing explanation, risk and rationale |
| --- | --- | --- | --- |
| ADOPT | [Hexer10 PR #389](https://github.com/Hexer10/youtube_explode_dart/pull/389), head `f6c104c8a0efe3e7bb9e3f859ca4addc45ad5926`, created 2026-08-21; branch read this run | Maintenance registry polls the wrong Lydonator branch | PR metadata and explicit branch ref agree. `master` having the upstream SHA is not a rollback of the feature branch. Correct only the configured branch. Low risk; regression must fail against old registry. |
| ADOPT | [Jameszhou historical commit](https://github.com/jameszhou123/youtube_explode_dart/commit/cbe63502884da2fa0afc0f09a9784fa831ab5867), 2026-07-14 | Historical reviewed SHA has two missing characters and cannot resolve | Full invalid lookup fails; short-prefix lookup resolves the historical search patch. Correcting provenance is not approving the two newer commits. Add full-SHA validation to tests of the actual registry, not a new restriction on parser fixtures. |
| ADAPT | Fork base `b1cef42590420b0b8dd1707f37c1cd9598eaf19c`; source audit 2026-09-16 | Documentation describes VisionOS as merely proposed although the default/profile already exist | Separate implemented behavior from still-unimplemented media affinity and missing fresh live evidence. Preserve ADR history with an appended audit. No runtime change or new playback guarantee. |
| NO ACTION | [yt-dlp PR #17684](https://github.com/yt-dlp/yt-dlp/pull/17684), `c7fb478d21e9e59524befbe23f7801bb267fb880`, 2026-09-16 | Safari UA for `WEB_EMBEDDED_PLAYER` and HLS quality preference | This package has no corresponding embedded-player profile. An unrelated VisionOS UA change would conflate identities. No local reproduction; do not port. |
| NO ACTION | NewPipe `8584a0d636ce6b8371d2c5c83dbe7f01a3d21d59`, 2026-09-04 | Java dependency-only change | No YouTube-path change and no equivalent Dart dependency. No production reason to change this fork. |
| DEFER | YouTube.js `d252b36f7e0bf5926a52a589a73d4aa6392a9683` / [#1260](https://github.com/LuanRT/YouTube.js/pull/1260), 2026-09-13; `2b80e3ef35f658bb2af573aa5f84b79d928e58d0` / #1262, 2026-09-16; attribution `ef3afbe435edc86ba3357b6fa951548ee3d46053`, 2026-09-09 | New show-tab/lockup/attribution features | These do not prove a defect in an existing Dart contract. Require a supported feature decision, exact response fixtures and public API review. |
| DEFER | [Invidious #6038](https://github.com/iv-org/invidious/pull/6038), `c88230067b7a3abbb569ac0938bf8d897c8340be`, 2026-09-16; [#6040](https://github.com/iv-org/invidious/pull/6040), `47756e0d1e53683c8c2341ca59bc54371b15b647`, 2026-09-15 | Per-host thumbnail headers/cookie isolation and JSON client/login headers | Independent transport implementation, but not proof that identical headers belong on Dart media requests. Cookie privacy, numeric client identity and host boundaries need separate tests. Do not copy global headers or account assumptions. |
| DEFER | [Jameszhou channel fix](https://github.com/jameszhou123/youtube_explode_dart/commit/a1ce972191d13a257e21394bcb4bd4268b4a2b75), 2026-09-07 | Channel About metadata fallback and subscriber header layout | Plausible response-shape compatibility gap, not reproduced locally. English substring matching and nullable legacy metadata require fixture/locale/contract tests. Independent exact-shape confirmation remains open. |
| REJECT | Jameszhou `1d885e1f2de917d24fd5287b0974cf22c440245b`, 2026-09-07 | Combined Streams-tab/isLive/API/filtering change | Commit explicitly hand-patches generated code and drops scheduled items. No wholesale import; any useful behavior needs a separate design and supported regeneration. |
| NO ACTION | Musify `1db94fcdbd195f4c4c4b66ad5d9ee00f8d9d4b1b`, 2026-09-08; current `a594f7c5c2c61d851b22b23fad1630cb1852b403`, 2026-09-14 | App-level audio compatibility/quality selection | No embedded-package delta. App codec preference must not silently remove library stream types. Consumer report is not independent protocol confirmation. |
| DEFER / REJECT import | Chameleon `9360b48dc4f08ab14329a57da6b2d23f9f4ab48a`, 2026-09-04; historical Musify affinity evidence in existing survey | Producing-client headers passed to HEAD, combined with VisionOS/Android VR defaults and TV fallback | Header-lifecycle concept is relevant; completeness of downstream implementation is not established. Reject combined defaults/import. Require deterministic lifecycle regression plus actual media bytes before adapting narrowly. |
| DEFER integration | [bgutil 2.0.0 release](https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/tag/2.0.0), `37169ee2656e08c5c2e5dc9df4c598c0cb4c88a8`, published 2026-09-08T00:11:44Z; [#262](https://github.com/Brainicism/bgutil-ytdlp-pot-provider/pull/262), `d36dac9b8ca458ee440f5885864e8bffce46efbf`, 2026-09-04 | Security release references GHSA-qpv9-8xfj-xx9m and changes provider exposure defaults | This fork has no provider integration. Record the advisory for future integration/deployment review; do not add a service or claim a package vulnerability/fix. The release range includes security work predating this registry checkpoint. |
| REJECT | Invidious #6039 proposal; shared Dart patches #389/#391 and Ashutosh/Vargas, reviewed 2026-09-16 | Fingerprint changes, duplicate confirmation and blind imports | No random/stealth fingerprints, no mirror counted as independent evidence, no wholesale imports/cherry-picks. |

### Existing implementation limitations, not new fixes

At the base SHA, `lib/src/videos/streams/stream_client.dart` already defaults to VisionOS, adds Safari only for an available solver without explicit clients, and uses classified Android then TV compatibility fallback. Explicit lists are not extended by this maintenance run.

`lib/src/videos/video_controller.dart` copies request-scoped maps and sends the profile user agent, but its client-name header is symbolic; numerical protocol identity remains a dedicated review concern. `lib/src/reverse_engineering/youtube_http_client.dart` accepts headers yet does not apply them to ordinary range/fragment requests; HLS/refresh also need producing-client affinity review. Refresh calls default `getManifest`, and existing error/retry handling must be tested before any lifecycle rewrite. The manifest HEAD probe has no producing-client headers. These code-level gaps are not equivalent to a freshly reproduced YouTube failure, and this PR does not repair or endorse them.

Independent Python, Java, TypeScript and Crystal references were compared as distinct implementations; shared Dart commits were de-duplicated. No protocol change is approved solely by one fork's successful manifest/HEAD claim.

## Implementation scope and design

In scope: correct the two source-provenance fields; add deterministic registry regressions; publish this review and accurately distinguish existing implementation from proposed transport work.

Expected paths: this plan, `docs/maintenance-sources.yaml`, `tool/test_source_watch.py`, `docs/fork-survey.md`, `docs/client-profiles.md`, `docs/fork-changelog.md`, and an append-only audit in `docs/decisions/0001-visionos-default-client.md`.

Out of scope: `lib/`, generated files, SDK/dependency/lockfiles, workflow changes, new clients, parser fixes, provider integration, release tags and merges. Public API, request lifecycle, client ordering, fallback/error behavior and consumer compatibility remain unchanged. No new hidden fallback, stream filtering, network retries or logging is introduced. The watcher implementation remains read-only and unchanged.

Registry history: keep per-source review timestamps/checkpoints, except correcting the demonstrably malformed historical SHA. Update the overall registry-audit timestamp and explain that it is not a blanket re-review of every source implementation. Current HEADs and actual review depth live in this plan; unreviewed watch entries remain unreviewed.

## Testing strategy

Before metadata correction, add the narrowest deterministic tests to the existing `ParseRegistryTest`:

1. Lydonator is present exactly once and tracks PR #389's verified `add-visionos-client` branch. It must fail against `master`.
2. Every non-empty reviewed SHA in the actual registry is exactly 40 hexadecimal characters. The current 38-character Jameszhou value must fail. Keep abbreviated synthetic parser fixtures supported.

Run the complete source-watch suite before and after correction, retaining intended failures. Then run Python compilation and a whitespace/diff audit. Tests must not call the network or pin moving HEADs. A future intentionally changed tracked branch must update its regression with evidence.

Deterministic Dart gates: retry the commands required by the root guide when a full checkout/SDK becomes available; record current exit-127 limitations. GitHub's existing PR workflows provide additional remote checks, not proof of missing local/full-suite gates. No CI policy will be weakened.

Live/media tests: not run in this cycle; no new runtime fix is claimed. Any deferred media change must first cover producing headers on probes/ranges/fragments/HLS, caller-client preservation on refresh, bounded retries, response cancellation/errors and resource closure, then actual audio/video bytes plus muxed/HLS and known unavailable/private failure cases where applicable. Record UTC, environment, public IDs, profile and outcome without signed URLs or sensitive data.

Source-watch CLI network result remains failed due DNS; connector metadata success is reported separately. Require a successful network report in a reachable environment to close the maintenance execution gate.

## Risks and attribution

Main risks are false source freshness, misleading historical status, branch deletion/merge, stale fingerprints, hidden fallback, symbolic/numeric identity mismatch, media/header affinity, unbounded pre-existing refresh, privacy leakage and mistaking hosted-network blocking for a product defect. This scope changes none of those runtime paths. The docs must not overstate health or coverage.

No third-party implementation or fixture is copied. Exact repository/commit/PR attribution is retained for evidence. A deferred port requires source-specific licence review and preserved attribution before implementation; no licence compatibility conclusion is inferred from reading a public repository.

## Documentation impact

Update registry provenance/audit date, append the new fork-survey review, separate current default implementation from historical protocol observations in client profiles, correct the fork changelog, and append ADR implementation status without rewriting its historical rationale. README, upstream-source instructions, release process and agent policy require no behavior change; their existing links lead to the updated records. Keep upstream `CHANGELOG.md` untouched.

## Rollback and revalidation

Rollback is a normal revert of the metadata/test/documentation commits, with no runtime migration or release required; never reset/force-push a stable branch. The audit record explains why restoring the old metadata would reopen the watcher defects.

Revalidate when canonical HEAD moves; PR #389 merges or its branch disappears; source heads move; new exact channel response fixtures reproduce the deferred parser issue; a public-content media-byte check fails; required stream types disappear; client/token policy changes; or provider integration is proposed after reviewing its current security advisory. Any upstream sync remains a separate PR.

## Acceptance criteria

- A1: Inventory contains all 24 dynamically parsed registrations, exact old/current refs, configured branches, roles, statuses and review scope; shared commits are de-duplicated.
- A2: Canonical divergence is recorded as 18 ahead / 0 behind; no upstream synchronization or external write occurs.
- A3: Both registry regressions demonstrably fail before correction and pass after it; all existing tests remain unchanged in strength.
- A4: Only the two justified provenance values and overall audit metadata change in the registry; historical per-source review dates and watch-only status are preserved.
- A5: Client/default documentation matches base code, ADR history is retained, and full media affinity/live playback is explicitly unverified.
- A6: No production Dart, watcher implementation, dependency, generated code, workflow or public API change appears in the remote diff; no sensitive data is committed.
- A7: Python suite, compilation and changed-file whitespace checks pass. Missing Dart/full-checkout/network/live evidence remains explicit; do not mark overall verification green.
- A8: Create a Draft PR, inspect the entire remote diff and actual CI/comments at its final HEAD, correct in-scope findings, and post a maintainer self-review without approving or merging it.

## Open assumptions and validation steps

- A correct-looking source SHA is not proof of changed-code correctness: keep historical checkpoints until scoped implementation review and required regressions are complete.
- Server health is unknown here: validate fresh actual bytes from a reachable Dart environment before any default/transport claim or release.
- A branch can move during the run: pin the inventory's exact observations, and check PR base/head again before final review; refresh source intelligence on the next trigger.
- Local full validation is unavailable: obtain an authorized online workstation/full checkout and Dart SDK, rerun the failed CLI and required Dart commands, and record results before ready-for-review promotion.

## Plan Verification

Verification: **2026-09-16T19:52:36Z**. Separate critical self-review pass; not an independent human approval.

Reviewer findings: both proposed metadata changes reproduce concrete provenance defects at the correct layer. Exact refs and PR metadata agree. All 24 rows match the parsed registry; the invalid historical value is retained in the inventory. Shared commits are explicitly de-duplicated. The proposed tests exercise actual registry configuration, not a preceding network step. No production behavior, client ordering, resource affinity, public API, dependencies, generated files or fallback changes are authorized. No external implementation is copied; any future adaptation still needs its own licence and regression review. Rollback and affected documentation are explicit.

Revisions made during review: restricted approval to metadata/tests/documentation; distinguished nine raw mismatches from eight genuine forward ranges; preserved per-source historical checkpoints instead of stamping fetched heads as reviewed; separated implemented VisionOS/default behavior from incomplete transport work; kept the failed network CLI and unavailable Dart gates visible. The root, docs and tool guides were re-read. Test and registry files remained byte-identical to the baseline throughout this gate.

Remaining assumptions: current server health, complete downstream implementation correctness and full local Dart validation remain unresolved, with validation steps above. These block runtime changes and ready-for-review promotion, not the two deterministic metadata corrections.

Final status: **VERIFIED** for this bounded maintenance plan. Overall execution/merge readiness is not verified and the PR must remain Draft while mandatory gates are blocked.
