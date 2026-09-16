# Fork Changelog

This file records behaviour that differs from `Hexer10/youtube_explode_dart`. Keep the upstream `CHANGELOG.md` intact for upstream release history.

## Unreleased

### Maintenance

- Added repository- and folder-level agent guidance.
- Added a machine-readable maintenance source registry and comparative Dart fork survey.
- Added a phased incident/research/design workflow and client-profile status record.
- Added a dependency-free, read-only source-intelligence tool and weekly/manual workflow that compares registered reviewed revisions with current GitHub branch heads and publishes Markdown/JSON reports.
- On 2026-09-16, refreshed all 24 registered source heads, corrected Lydonator's tracked PR branch and Jameszhou's malformed historical revision, and added deterministic provenance regressions. Historical per-source review dates/checkpoints remain preserved rather than automatically advancing to fetched heads. See the [verified maintenance plan](maintenance-plans/2026-09-16-regular-maintenance.md) for review scope and blocked validation gates.

### Stream compatibility already present at the audited base

The 2026-09-16 source audit of `b1cef42590420b0b8dd1707f37c1cd9598eaf19c` found these changes already implemented; they are not new runtime changes in this maintenance PR:

- Apple Vision Pro `VISIONOS` profile and primary default when callers omit `ytClients`.
- Classified Android/TV compatibility fallback and solver-dependent Safari selection without extending explicit caller lists.
- Request-scoped client-context copies before adding request data.

### Outstanding stream compatibility work

- Preserve client-specific media headers through validation, range downloads, fragments, HLS, and refresh.
- Add deterministic transport tests and live media-byte regressions.

The transport work remains separate and incomplete. This documentation correction does not establish fresh playback health, complete media-header affinity, or successful local Dart/live-byte validation. No release or tag is created by this maintenance cycle.