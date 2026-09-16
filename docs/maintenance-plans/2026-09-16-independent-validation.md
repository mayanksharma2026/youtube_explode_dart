# Independent validation plan — 2026-09-16 UTC

## Baseline and scope

Recorded at 2026-09-16T19:57:43Z. Repository: `mayanksharma2026/youtube_explode_dart`; default branch `master`; base `b1cef42590420b0b8dd1707f37c1cd9598eaf19c`; package 3.1.0; Dart `>=3.0.0 <4.0.0`.

Root, GitHub, docs, tool, test, video and reverse-engineering instructions and the maintenance runbooks were read. The baseline Dart CI run 35139611516 passes its scoped deterministic gate. Exact local source-watch files pass 9 tests. Local GitHub DNS resolution and Dart execution are unavailable; the remote workstation has no connected device.

During this maintenance session, `docs/regular-maintenance-2026-09-16` acquired concurrent commit `05b303d2958569a8aa88a4794f24044333d63cb1`, containing a different verified maintenance plan. Attempts to create that branch/file were rejected, and the existing work was inspected rather than overwritten. No concurrent commit is claimed as authored by this validation pass. The independently gathered source observations agree on 24 sources, canonical upstream unchanged at `44a39a65d8e274806247d52af8f0bacd77691d38`, and baseline divergence 18 ahead / 0 behind.

This separate branch exists only to obtain reproducible execution evidence. It is not a competing maintenance implementation and must not be merged. Do not modify the concurrent maintenance branch, default branch, external repositories, library behavior, dependencies or test assertions.

## Proposed implementation

Create one finite GitHub Actions workflow on this isolated branch, triggered only by pushes to this exact branch. Reuse the existing immutable checkout, Dart setup, Python setup and artifact-upload action pins. Set `permissions: contents: read` and finite job/step/process timeouts. Checkout only exact base/maintenance commits from this fork; verify and record the checked-out SHA.

Run the requested Dart commands (`dart pub get`, `dart format --output=none --set-exit-if-changed .`, `dart analyze`, `dart test`) plus `git diff --check` against the base. Preserve every command's actual return code and fail the quality step if any command fails. Full Dart output is captured in memory, not printed or uploaded; retain only safe command/status/count/path diagnostics to avoid leaking live request data. No failure is converted to a pass.

Run the unchanged deterministic source-watch tests and Python compilation separately. Run the unchanged documented network report command separately with the ordinary read-only GitHub token, provided only to that step. The source watcher must not execute monitored repositories, update its registry or import patches. Retain supported source reports and safe validation summaries as artifacts, never raw request logs or tokens.

First validate the exact base. A later workflow-only update may add the exact reviewed maintenance HEAD to the matrix after reading its remote diff; never follow a moving branch implicitly. Record all run IDs, tested SHAs and outcomes. Network or permission failures remain explicit blockers. No proxy, TLS bypass, extra fallback, custom fingerprint or weakened test is allowed.

## Acceptance and rollback

- Workflow writes either succeed through authorized tools or their exact rejection is reported; permissions are not bypassed.
- Artifact records identify the exact commit, UTC time, environment and every command result.
- Baseline failures are distinct from maintenance regressions; ordinary PR CI remains unchanged.
- The network report is a real execution of the repository command, not connector-response replay.
- No production/library change, external source execution, publish or merge occurs.
- The helper workflow is excluded from the final maintenance PR. The validation branch may be removed independently; run/artifact links provide provenance.

## Risks and open assumptions

GitHub workflow-write permission and runner/network availability are unconfirmed until attempted. Full Dart checks may expose pre-existing failures or hosted YouTube restrictions. Do not treat those as new product defects, claim playback health, or waive Draft/readiness requirements. The concurrent maintenance branch may continue moving: inspect and pin each new tested revision, and never overwrite active work.

## Plan Verification

Verification: 2026-09-16T19:57:43Z, separate critical maintainer self-review. Checked least privilege, immutable action pins, finite execution, safe output handling, failure propagation, exact-revision checkout and isolation from the concurrent branch. Revised the initial approach to avoid a competing maintenance PR after discovering concurrent work. No production change is justified or authorized. The empty runtime diff preserves public APIs, caller client ordering, media affinity and failure visibility.

Final status: **VERIFIED** for isolated validation only. This is not a claim that execution checks have passed or that an independent human approved the maintenance changes.
