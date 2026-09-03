# Agent Guide

This repository is a maintained fork of `Hexer10/youtube_explode_dart` for production use. YouTube's private APIs and media-delivery rules change without notice, so maintenance must be evidence-driven and easy to review upstream.

## Read this first

Before changing code:

1. Reproduce the failure and capture the exact layer: watch page, InnerTube player response, manifest parsing, signature/n challenge, PO token, CDN request, HLS/DASH, or content restriction.
2. Read the nearest folder-level `AGENTS.md`. Folder guidance overrides or narrows this file for that subtree.
3. Read `docs/maintenance.md`, `docs/client-profiles.md`, and `docs/reference-repositories.md` for extraction/streaming failures.
4. Research upstream Dart issues/PRs, active forks, and maintained implementations in other languages before designing a fix.
5. Compare implementations. Do not copy a patch merely because it currently works.
6. Prefer the smallest protocol-correct change with explicit tests and diagnostics.

Folder guides currently exist at:

- `lib/src/videos/AGENTS.md` — InnerTube client profiles and video extraction.
- `lib/src/videos/streams/AGENTS.md` — stream resolution, validation, fallback and media transport.
- `test/AGENTS.md` — regression-test expectations for volatile YouTube behaviour.
- `docs/AGENTS.md` — keeping maintenance evidence and repository references current.

Do not create an `AGENTS.md` in every folder mechanically. Add one only when that subtree has rules that materially differ from its parent.

## Fork policy

- `Hexer10/youtube_explode_dart` remains the primary Dart upstream.
- Keep fork-specific changes small and independently reviewable.
- Do not mix parser refactors, client-profile changes, HTTP transport changes, and unrelated cleanup in one PR.
- Preserve public API compatibility unless a breaking change is explicitly justified.
- Do not silently discard failing stream classes to make a manifest appear healthy.
- Do not add speculative/random spoofing. Client identities and headers must have evidence from a real maintained implementation or reproducible protocol analysis.
- Do not weaken errors. A 403, token requirement, unavailable video, parser regression, or challenge failure must remain diagnosable.

## Research order for YouTube breakages

Use `docs/reference-repositories.md` as the maintained inventory. At minimum inspect:

1. This repository's upstream issues/PRs and recently active forks.
2. `yt-dlp/yt-dlp` for current InnerTube clients, PO-token policies, player changes and extractor behaviour.
3. `Tyrrrz/YoutubeExplode` for the canonical .NET design and stream-resolution behaviour.
4. `TeamNewPipe/NewPipeExtractor` for Android/Java extraction behaviour.
5. `LuanRT/YouTube.js` for TypeScript InnerTube behaviour.
6. Other maintained extractors listed in the reference inventory when relevant.

For each candidate fix record: observed failure, source implementation/issue, why its assumptions apply to Dart, alternatives considered, and how real media access was verified.

## Client-profile policy

YouTube client profiles are server-controlled compatibility inputs, not stable API contracts.

- Keep profiles centralized in `lib/src/videos/youtube_api_client.dart`.
- Do not scatter client JSON across call sites.
- Prefer deterministic known-good profiles over random identities.
- Do not rotate/randomize client versions or headers as an anti-detection technique without evidence; inconsistency can make requests less credible and harder to debug.
- Explicitly document known limitations such as PO-token requirements, authentication, JS-player requirements, HLS-only behaviour, or content categories that a client cannot access.
- When changing the default client, add a regression test that reaches the media CDN, not only the player API.

## Testing and review gate

Before opening a PR:

- Run `dart format --set-exit-if-changed .`.
- Run `dart analyze`.
- Run `dart test` locally where network tests are supported.
- For stream fixes, validate at least one audio-only and one video-only media request. A parsed manifest alone is not sufficient.
- Review the complete diff against the intended scope.
- Check for accidental public API changes, silent fallbacks, stale comments, copied secrets/tokens, excessive retries and unrelated formatting churn.
- If a network test cannot run in GitHub Actions because YouTube blocks hosted runners, state that clearly in the PR and provide the exact local verification performed.

## Pull-request workflow

PRs in this fork are intentionally mergeable in order by the repository owner.

1. Work on a dedicated branch.
2. Deep-review the branch before creating the PR.
3. Open the PR only against this fork unless the owner explicitly requests an upstream PR.
4. Keep the title suitable for upstream use: concise imperative/behavioural wording, no internal project names.
5. PR description must include problem, root cause/evidence, solution, alternatives rejected, tests, limitations/risks and upstream/reference links.
6. Do not auto-merge. Leave reviewed PRs ready for the owner to merge in the documented order.
7. If later contributing upstream, the owner will create/approve that submission separately.

## Documentation maintenance

A code fix is incomplete when it changes our understanding of YouTube behaviour but leaves the maintenance docs stale. Update the relevant documentation in the same PR or an ordered prerequisite PR.

Keep `docs/reference-repositories.md` factual: repository purpose, language, what to inspect, and last review date. Fork activity changes frequently; verify it rather than assuming an old fork remains maintained.
