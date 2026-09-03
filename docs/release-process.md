# Fork Release Process

This fork is consumed from Git. It must not accidentally publish the upstream package name to pub.dev.

## Versioning

Use SemVer-compatible fork prerelease tags based on the upstream package version:

- `v3.1.0-fork.1`
- `v3.1.0-fork.2`

Increment the upstream base when the fork synchronises to a newer upstream release. Increment the fork suffix for local releases on the same base.

Do not create a release tag until the corresponding commit is merged into the fork stable branch.

## Release checklist

### Source and scope

- upstream baseline recorded;
- fork PRs included are listed;
- each patch has tests, documentation, attribution, and rollback;
- source registry and client profile status are current;
- no unresolved secrets or signed URLs appear in the diff/logs.

### Deterministic validation

```bash
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze
dart test
```

### Live validation

Run from a normal developer/production-like network, not a GitHub-hosted runner known to be blocked. Record UTC time, region at a coarse level, Dart version, and sample categories. Verify actual bytes for required stream types.

### Package review

```bash
dart pub publish --dry-run
```

The dry run is for package integrity only; do not publish under the upstream package name.

### Release notes

Include:

- upstream base and fork commit;
- user-visible fixes;
- client/default/fallback status;
- tests performed;
- known limitations;
- migration notes and exact dependency ref;
- rollback ref;
- upstream PR status where applicable.

## Tag and consume

Create an annotated tag after merge:

```bash
git tag -a v3.1.0-fork.1 -m "youtube_explode_dart fork release 3.1.0-fork.1"
git push origin v3.1.0-fork.1
```

Consumers update to the exact tag, run their own playback/download smoke tests, and retain the previous working tag for rollback.

## Rollback

Rollback by pinning the previous release tag/SHA. Do not rewrite or move a published tag. If a release is bad, document it and create the next fork suffix.

## Post-release monitoring

Track failure by operation and status class without storing signed URLs or credentials:

- player request failure;
- manifest/playlist failure;
- media probe failure;
- media download failure;
- 403 versus 429 versus parse/challenge error;
- client profile and package commit.

A material regression opens a new incident and triggers profile/source revalidation.