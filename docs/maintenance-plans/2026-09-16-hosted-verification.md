# Hosted verification supplement — 2026-09-16 UTC

This is a dated supplement to the [regular maintenance plan](2026-09-16-regular-maintenance.md), not a new runtime proposal. It supersedes the earlier **missing successful network-report evidence** limitation. It does **not** turn the failing full Dart gates into passes or establish playback health.

## Plan Verification for this supplement

Verified at **2026-09-16T20:12:43Z** in a separate critical maintainer self-review. Re-read `docs/AGENTS.md`; root instructions remain unchanged. Scope is one additional verification record within the existing documentation-only maintenance scope. Preserve the concurrently authored plan and its dated local failures rather than overwrite them. No production, test, source registry, dependency, generated-code, workflow or API change is authorized by this supplement. Status: **VERIFIED** for adding this evidence record.

The isolated validation workflow had its own verified plan before creation and is on `ci/maintenance-validation-2026-09-16-1952`. That helper branch/workflow must not be merged into the maintenance PR.

## Exact revisions and environment

- Base: `b1cef42590420b0b8dd1707f37c1cd9598eaf19c`.
- Tested maintenance implementation: `ec780369e229cb5f224117332e02ef3f4b3dfd13`.
- Subsequent plan-verification record: `6874a68a08d614a7ab8a516c32b37cd8c57b16cb`; its only change is the plan's Implementation Verification section, not tested runtime/input files.
- Validation workflow revision: `467ac3740f452000e7cc1249aa8b84e7fd14570d`.
- [Actual execution run 35144591231](https://github.com/mayanksharma2026/youtube_explode_dart/actions/runs/35144591231).
- Environment: Ubuntu GitHub-hosted Linux runner, Dart **3.13.4**, Python **3.13.15**; read-only repository permissions, exact-SHA checkout and finite timeouts.
- Base command window: **2026-09-16T20:07:14.209211Z–20:07:57.044080Z**.
- Implementation command window: **2026-09-16T20:07:11.063170Z–20:07:55.400282Z**.

These are actual hosted executions, not replayed connector responses. Initial local DNS resolution and absent-Dart failures in the plan remain accurate historical records for that local environment.

## Implementation Verification

| Command | Untouched base | Maintenance implementation |
| --- | --- | --- |
| `dart pub get` | PASS, exit 0 | PASS, exit 0 |
| `dart format --output=none --set-exit-if-changed .` | PASS, exit 0 | PASS, exit 0 |
| `dart analyze` | FAIL, exit 3 | FAIL, exit 3 |
| `dart test` | FAIL, exit 1 | FAIL, exit 1 |
| `dart test --reporter=json` — supplementary diagnostic run | 100 passed / 65 skipped / 17 failed, exit 1 | Same counts and failed-file set, exit 1 |
| `python -m unittest -v tool.test_source_watch` | 9 passed | 11 passed |
| `python -m py_compile tool/source_watch.py tool/test_source_watch.py` | PASS | PASS |
| `git diff --check b1cef42590420b0b8dd1707f37c1cd9598eaf19c HEAD` | PASS | PASS |
| `python tool/source_watch.py --registry docs/maintenance-sources.yaml --output-dir source-watch-report` | PASS | PASS |
| Source-watch input immutability check | PASS | PASS |

The original requested Dart commands were run unchanged. The JSON reporter command is a separate supplementary execution used to retain safe diagnostics, not a replacement or a fabricated result for the original invocation. The workflow propagates failed commands and correctly concludes **failure**.

### Baseline failures, not maintenance regressions

Both revisions report the same **41 analyzer locations/codes**: unresolved Flutter imports/types in `example/video_download_flutter/lib/main.dart`, associated override diagnostics, and an existing unused-variable warning in `example/example.dart`. A Dart-only root dependency installation does not establish a configured Flutter example environment.

The supplementary full-test runs have identical counts and failing-file sets:

- `test/channel_test.dart`
- `test/playlist_test.dart`
- `test/search_test.dart`
- `test/video_test.dart`

Safe error categories include `NoSuchMethodError` and `VideoUnavailableException`. This evidence does not establish the root cause of every failing test. Do not claim they are all hosted-network blocks or infer production playback health. No assertion, skipped-test policy or runtime behavior was changed to make these checks pass.

### Source report and regression verification

Base report generated **2026-09-16T20:08:07Z**: 24 sources, 12 current, 9 changed, 3 unreviewed, **0 errors**.

Corrected implementation report generated **2026-09-16T20:08:04Z**: 24 sources, 13 current, 8 changed, 3 unreviewed, **0 errors**. Current revisions match the plan's observations; the Lydonator branch correction removes the false comparison. Historical reviewed checkpoints are not advanced merely because the network report succeeds.

The independent review also reconstructed the exact remote test and registry bytes and verified their Git blob hashes before running them:

- Tests: `51829a7e6c0c776436d55a33def146dc1c092374`.
- Corrected registry: `2450b6ae5dfa6abfed35e248afc636222346eed0`.

Against the original registry, exactly the two added tests fail: incorrect Lydonator branch and malformed Jameszhou revision. All original nine tests pass. Against the corrected registry, all eleven pass. A separate AST comparison confirms every original test/helper function is unchanged. Parsed registry comparison finds only the two justified provenance corrections plus the explicitly scoped overall audit timestamp; policies, ordering and per-source review dates remain unchanged.

## Retained evidence

Downloaded artifact bytes were SHA-256 verified:

| Artifact | SHA-256 |
| --- | --- |
| [Base results and source report](https://github.com/mayanksharma2026/youtube_explode_dart/actions/runs/35144591231/artifacts/10466890654) | `fcec2d58bf31384d848fe25c742136b02b05cdcb11279b28aa425b3a447019dc` |
| [Implementation results and source report](https://github.com/mayanksharma2026/youtube_explode_dart/actions/runs/35144591231/artifacts/10466384192) | `b210d01e9f2643a32b4ae3ffe4d9c695132f25fb56c5dbb71d194195eeeb555f` |

Artifacts have finite retention; this committed record preserves the material results afterward. Only safe command status/count/path diagnostics and supported source reports are retained. Raw live-request output, signed media URLs and account/session data are not retained in these artifacts or this record.

## PR CI and acceptance-criteria update

At PR head `6874a68a08d614a7ab8a516c32b37cd8c57b16cb`, GitHub reported the existing [Dart CI](https://github.com/mayanksharma2026/youtube_explode_dart/actions/runs/35144923853) and [Source intelligence watch deterministic checks](https://github.com/mayanksharma2026/youtube_explode_dart/actions/runs/35144923831) successful. Those narrower PR checks are not the full Dart or network report gates. A subsequent documentation-only commit must receive its own remote diff/check review; the final self-review comment pins that exact head.

The plan's A1–A6 findings remain unchanged. **A7 now has successful actual network-report, full-formatting and dependency-resolution evidence, but full analysis and full tests remain failed.** A8 is completed only by the final remote PR review and exact-head self-review comment. No independent human approval or merge is implied.

## Remaining blockers and revalidation

Overall complete-validation/readiness status remains **BLOCKED / Draft**. Diagnose the pre-existing full-test failures from safe exact-response fixtures, and configure/validate the Flutter example when requiring repository-wide analysis. These are separate from the verified provenance correction; do not hide them with scoped green CI or unrelated changes in this maintenance PR.

No targeted successful live/media-byte matrix was performed. Any future runtime/transport change still requires the repository's deterministic lifecycle coverage and actual audio/video bytes from a suitable environment. Re-run source intelligence when source heads or configured branches change. This supplement changes neither package behavior nor release state, and can be reverted independently without a runtime rollback.
