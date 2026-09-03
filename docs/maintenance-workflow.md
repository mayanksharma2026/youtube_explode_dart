# Phased Maintenance Workflow

This workflow is mandatory for protocol and parser changes. It is designed for both human maintainers and coding agents.

## Phase 0 — Define scope and safety boundaries

Write the user-visible symptom, affected API, first observed UTC time, and release/commit. Decide whether the work is a protocol hotfix, parser fix, transport correction, or maintenance infrastructure.

Do not use random fingerprints, rotating identities, artificial timing, proxy rotation, or other anti-detection behaviour. The goal is reliable compatibility through coherent request semantics, not evasion.

**Output:** issue/incident record and one-sentence scope.

## Phase 1 — Reproduce and classify

Build the smallest reproduction and capture redacted evidence. Determine whether failure occurs during:

1. watch-page acquisition;
2. player request;
3. playability evaluation;
4. signature/`n` solving;
5. manifest parsing;
6. content-length/probe request;
7. actual byte-range, fragment, or HLS segment fetch;
8. retry/refresh;
9. search/channel/playlist continuation parsing.

**Gate:** no production code change before the failing layer is identified or competing hypotheses are explicitly recorded.

## Phase 2 — Refresh source intelligence

Read `maintenance-sources.yaml`. For each relevant source:

- fetch the current default-branch commit;
- search recent issues, PRs, commits, and comments using exact error terms;
- compare maintained Dart forks and embedded downstream copies;
- inspect at least two independent cross-language implementations for protocol changes;
- update the registry/survey with exact commits and findings.

Record whether repositories are independent or share the same patch commit.

**Output:** comparison table listing adopted, adapted, rejected, and unresolved ideas.

## Phase 3 — Design before porting

Design a Dart-native solution against these criteria:

- smallest coherent change;
- deterministic behaviour;
- explicit client/fallback policy;
- client identity preserved across the complete resource lifecycle;
- no silent stream-type loss;
- bounded retries and clear errors;
- public API compatibility;
- testability without live YouTube access;
- easy upstreaming and rebasing.

When multiple sources disagree, prefer reproduced behaviour and a reversible design. Do not combine unrelated improvements to make a patch appear more complete.

**Output:** ADR for default/fallback/API/architecture changes.

## Phase 4 — Test first

Add:

- deterministic unit tests for the local defect (headers, range construction, retry, parser fixture, etc.);
- a narrow live regression for the server-controlled behaviour;
- failure-case coverage that proves errors remain visible.

For a media incident, the live test must read real bytes. A non-empty manifest is insufficient.

## Phase 5 — Implement

Port behaviour, not syntax. Preserve attribution in the commit/PR. Keep commits reviewable:

1. regression/failing test;
2. production fix;
3. documentation/decision update.

Generated files must be regenerated with the repository's supported tooling, not edited manually.

## Phase 6 — Validate

Run deterministic checks:

```bash
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze
dart test
```

Then run targeted live tests from a network where YouTube is reachable. Verify a matrix appropriate to the change:

- normal public video;
- audio-only media bytes;
- video-only media bytes;
- muxed/HLS when affected;
- invalid/private/unavailable error;
- content class known to differ for the client, if a stable public case exists.

Record environment and timestamp. Do not treat GitHub-hosted runner blocking as a product failure.

## Phase 7 — Review and PR

Review the entire diff for:

- unrelated changes;
- hidden fallback or swallowed exceptions;
- sensitive logs;
- stale source references;
- mismatched client fields;
- dropped headers on a secondary request path;
- unbounded network work;
- weak tests.

Use a professional Conventional Commit title. The PR must include evidence, sources, alternatives, tests, risk, rollback, revalidation trigger, and upstreamability.

## Phase 8 — Release and monitor

Merge only after deterministic CI passes and live validation evidence is recorded. Tag a fork release and have consumers pin the exact tag or commit.

Monitor application failures by status class and operation, without logging signed URLs or tokens. If a default profile becomes unhealthy, open a new incident; do not silently randomise or expand the client list.

## Phase 9 — Feed learning back

After each incident:

- update client status and the fork changelog;
- add new maintained sources or remove stale/no-value mirrors;
- add a focused issue for independent follow-ups discovered during research;
- upstream reusable changes manually when ready;
- keep fork-specific deployment policy out of the upstream PR.