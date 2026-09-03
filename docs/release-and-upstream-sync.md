# Release and upstream sync

This fork should remain a small, reviewable layer over `Hexer10/youtube_explode_dart`. Keep upstream integration and fork-specific compatibility fixes separate.

## Git remotes

Recommended local setup:

```bash
git clone https://github.com/mayanksharma2026/youtube_explode_dart.git
cd youtube_explode_dart
git remote add upstream https://github.com/Hexer10/youtube_explode_dart.git
git remote -v
```

Expected roles:

- `origin`: this maintained fork;
- `upstream`: the original Dart repository.

## Syncing `master`

Do not mix an upstream sync with a YouTube incident fix.

```bash
git fetch --prune upstream
git checkout master
git pull --ff-only origin master
git merge --ff-only upstream/master
git push origin master
```

If fast-forward is not possible, stop and inspect why the fork's `master` diverged. Do not resolve broad conflicts inside an incident branch.

After syncing:

```bash
dart pub get
dart analyze
dart test
```

Then open a separate compatibility branch from the updated `master` and rebase/cherry-pick the narrow fork commits as needed.

## Fork-specific branches

Use descriptive branches such as:

```text
fix/visionos-client-maintenance
fix/youtube-player-parser-<date>
chore/sync-upstream-<version-or-date>
```

One branch should represent one coherent decision. Avoid permanent `production` branches that accumulate undocumented patches.

## Consumer dependency

During review, a consumer may temporarily point to a feature branch. Production must pin an immutable commit or reviewed tag:

```yaml
dependencies:
  youtube_explode_dart:
    git:
      url: https://github.com/mayanksharma2026/youtube_explode_dart.git
      ref: <reviewed-commit-sha-or-release-tag>
```

Do not use:

```yaml
ref: master
```

A moving branch makes builds non-reproducible and can deliver an unvalidated client/profile change without an application release.

## Version and tag convention

Until this fork is intentionally published as a separate package, retain the upstream package identity and use Git tags to identify reviewed fork releases.

Suggested tags:

```text
v3.1.0-fork.1
v3.1.0-fork.2
```

For a later upstream base:

```text
v<upstream-version>-fork.<revision>
```

Each tag should point to a commit that passed deterministic CI and the relevant manual YouTube smoke tests. Do not move or reuse a published tag.

If the package is ever published independently, decide the package name, semantic-version strategy, ownership and user-facing support policy in a separate ADR. Do not publish a modified package under another maintainer's identity by default.

## Release checklist

1. Branch is based on the intended upstream commit.
2. Diff contains only the intended compatibility change and its tests/docs.
3. `dart pub get` succeeds.
4. Changed Dart files are formatted without reformatting unrelated files.
5. `dart analyze` succeeds.
6. `dart test` succeeds.
7. Focused manual stream validation succeeds from a representative network.
8. Current profile/limitation documentation is accurate.
9. Pull request records evidence, non-goals, risk and rollback.
10. Consumer integration pins the merged commit/tag.
11. The previous known-good pin is retained for rollback.

## Upstreaming a fork fix

Where useful, propose the narrow generic fix to `Hexer10/youtube_explode_dart`:

- remove application-specific policy;
- retain deterministic and focused tests;
- explain current YouTube evidence;
- keep attribution to prior proposals;
- avoid coupling the upstream PR to this fork's release process.

If upstream merges an equivalent fix:

1. sync upstream into this fork;
2. compare behaviour and tests;
3. remove duplicate fork code in a dedicated PR;
4. keep fork documentation that remains operationally relevant;
5. release a new immutable tag and update consumers.

## Rollback

Rollback by changing the consumer's pinned commit/tag, not by rewriting repository history. If a profile stops working, preserve the failed release for diagnosis and release a focused successor.
