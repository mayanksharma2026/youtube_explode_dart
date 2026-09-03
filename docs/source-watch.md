# Source Intelligence Watch

The source-intelligence watch gives maintainers and coding agents an early, read-only view of changes in the upstream project, maintained Dart forks, production downstream copies, and cross-language references recorded in [`maintenance-sources.yaml`](maintenance-sources.yaml).

It is deliberately **not** an automatic patching system. A new external commit is only a signal to investigate.

## Workflow

`.github/workflows/source-watch.yml` runs:

- weekly on Monday at 03:17 UTC;
- manually through `workflow_dispatch` after the workflow is present on the default branch;
- deterministic parser/report tests on pull requests that change the registry, tool, or workflow.

Scheduled/manual runs:

1. validate the constrained registry parser;
2. request the current head for each registered repository and branch through the GitHub API;
3. compare it with `reviewed_commit`;
4. write `source-intelligence.md` and `source-intelligence.json`;
5. publish the Markdown report to the workflow summary;
6. upload both files as a workflow artifact.

The workflow has `contents: read` permission only. It does not push commits, update the registry, create issues, or open pull requests.

## Status meanings

| Status | Meaning | Required action |
| --- | --- | --- |
| `current` | The tracked branch still points to the reviewed SHA. | None. |
| `changed` | The branch head moved. | Compare commits, classify the subsystem, reproduce relevant behaviour, and update the registry only after review. |
| `unreviewed` | The source is tracked but has no reviewed SHA. | Perform an initial review before relying on it. |
| `error` | Repository/branch lookup failed. | Check rename/deletion, branch drift, rate limiting, or temporary API failure. |

A `changed` status does not fail the workflow. An `error` does, while still uploading the report through an `always()` step.

## Running locally

```bash
python -m unittest -v tool.test_source_watch
python tool/source_watch.py \
  --registry docs/maintenance-sources.yaml \
  --output-dir source-watch-report
```

Set `GITHUB_TOKEN` to increase API rate limits. The token requires no write permission.

## Agent review procedure

When the report shows a changed source:

1. read root and subtree `AGENTS.md` files;
2. fetch the exact old and new commits;
3. inspect commit messages, changed paths, issues, PRs, and tests;
4. determine whether repositories share the same patch and avoid double-counting mirrors;
5. classify findings as authoritative protocol evidence, independent corroboration, downstream signal, app policy, or risky workaround;
6. reproduce the matching failure in this Dart package;
7. compare at least one relevant Dart implementation and two independent mature implementations when protocol behaviour is involved;
8. design the smallest Dart-native fix and add a failing regression first;
9. update `maintenance-sources.yaml`, `fork-survey.md`, client status/ADR, and PR evidence with exact revisions.

Do not copy a changed branch wholesale. Do not add random client identifiers, user agents, timing, request order, or proxy rotation. Do not introduce a longer fallback list merely because several forks tried different clients.

## Adding a source

A source must have:

- a stable `owner/repository` name;
- an explicit branch;
- a clear role and reason for tracking;
- an exact reviewed commit when review is complete;
- notes about app-specific behaviour, mirrors, cautions, and licence considerations in the registry/survey.

A newly created fork with no independent commits is not a maintained source. A mirror carrying the same commit as another repository is not independent confirmation.

## Limitations

The watch compares branch heads only. It does not search every issue, pull request, release, comment, tag, or non-default branch automatically. During an incident, the agent must still perform targeted GitHub searches and cross-language analysis described in [`maintenance-workflow.md`](maintenance-workflow.md).
