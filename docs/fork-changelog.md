# Fork Changelog

This file records behaviour that differs from `Hexer10/youtube_explode_dart`. Keep the upstream `CHANGELOG.md` intact for upstream release history.

## Unreleased

### Maintenance

- Added repository- and folder-level agent guidance.
- Added a machine-readable maintenance source registry and comparative Dart fork survey.
- Added a phased incident/research/design workflow and client-profile status record.

### Proposed stream compatibility change

- Add an Apple Vision Pro `VISIONOS` client profile.
- Make VisionOS the primary anonymous/default stream client after live validation.
- Preserve client-specific media headers through validation, range downloads, fragments, HLS, and refresh.
- Add deterministic transport tests and live media-byte regressions.

The proposed stream change is tracked separately from this documentation PR until implementation and validation are complete.