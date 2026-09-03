# Fork Maintenance and Upstream Sync

## Repository relationships

- `origin`: `mayanksharma2026/youtube_explode_dart`
- `upstream`: `Hexer10/youtube_explode_dart`
- upstream default branch: `master`
- fork stable branch: `master`

The fork stable branch should contain reviewed changes only. Do not develop directly on it.

## Branch naming

- `fix/<scope>` — protocol, parser, or defect correction.
- `docs/<scope>` — documentation and maintenance records.
- `test/<scope>` — regression-only work.
- `ci/<scope>` — automation and workflows.
- `sync/upstream-YYYY-MM-DD` — upstream synchronisation.
- `research/<scope>` — temporary investigation; do not release from it.

## Upstream sync procedure

```bash
git remote add upstream https://github.com/Hexer10/youtube_explode_dart.git
git fetch --prune origin
git fetch --prune upstream
git switch -c sync/upstream-YYYY-MM-DD origin/master
git merge --no-ff upstream/master
```

Resolve conflicts by preserving both the upstream intent and documented fork decisions. Run the complete deterministic suite and targeted live tests for every fork patch touched by the merge. Open a PR into the fork's `master`; do not force-push `master`.

After merge, update the upstream baseline commit in `docs/maintenance-sources.yaml` and record any conflict resolution in the PR.

## Patch ownership

Each fork-only patch must have:

- a focused branch and PR;
- tests proving its local purpose;
- a source/attribution note;
- a fork changelog entry;
- a revalidation trigger;
- an upstream status: `not-submitted`, `submitted`, `accepted`, `rejected`, or `superseded`.

Do not delete a patch merely because upstream added something similar. Compare behaviour and tests, then either drop it in a dedicated sync PR or document why it remains.

## Upstream contribution workflow

1. Complete and review the change in this fork first.
2. Remove fork-specific operational wording from reusable code/PR text.
3. Rebase/cherry-pick only the focused commits onto a branch based on current upstream `master`.
4. Preserve original contributor attribution and source references.
5. Manually open the upstream PR.
6. Track its URL/status in the local PR or fork changelog.

An upstream rejection does not invalidate a production fork patch, but its reason must be reviewed and recorded.

## Dependency consumption

Production consumers must pin a fork release tag or full commit SHA:

```yaml
youtube_explode_dart:
  git:
    url: https://github.com/mayanksharma2026/youtube_explode_dart.git
    ref: <release-tag-or-full-commit-sha>
```

Do not consume `master`, a feature branch, or an external contributor fork in production.

## Keeping the diff small

- no repository-wide formatting in hotfixes;
- no unrelated dependency upgrades;
- no mixed parser and stream changes;
- no app policy inside general-purpose extractors;
- no generated files without their source change/tooling;
- use separate follow-up PRs for discoveries made during incident research.