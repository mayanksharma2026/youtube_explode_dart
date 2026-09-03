# AGENTS.md

## Purpose

This repository is a maintained fork of `Hexer10/youtube_explode_dart`. It exists so production consumers can receive reviewed compatibility fixes when YouTube changes before upstream Dart support is available.

The goal is **not** to accumulate hacks or permanently diverge from upstream. Prefer the smallest evidence-backed change that restores correctness while keeping the fork easy to compare, review, test, and eventually upstream.

## Instruction hierarchy

Agents must read this file before changing the repository. Some complex folders contain a nearer `AGENTS.md`; the nearest file supplements or overrides this root guidance for that subtree.

Current scoped guidance:

- `docs/AGENTS.md` — maintenance research and documentation.
- `lib/src/videos/AGENTS.md` — InnerTube client profiles and player-response logic.
- `lib/src/reverse_engineering/AGENTS.md` — HTTP/page parsing and reverse-engineered protocol changes.
- `test/AGENTS.md` — regression and live-network test expectations.

Do not create an `AGENTS.md` in every directory mechanically. Add one only when that subtree has materially different risks, invariants, or verification steps.

## Repository relationship

- Canonical upstream: `https://github.com/Hexer10/youtube_explode_dart`
- Maintained fork: `https://github.com/mayanksharma2026/youtube_explode_dart`
- Upstream default branch: `master`

Keep upstream history intact. New maintenance work should normally be done on a focused branch and merged through a pull request in this fork. Do not open or modify a pull request in the canonical upstream repository unless a human explicitly asks for that action.

## Required maintenance workflow

When YouTube behaviour changes, do not immediately patch the first failing line. Work in this order:

1. **Reproduce** the failure and classify it: player API failure, playability, media CDN 403/429, signature/n challenge, PO-token policy, visitor-data/session issue, parser/layout change, HLS/DASH/SABR change, or transport/header issue.
2. **Read current Dart evidence**: upstream issues, open PRs, recent commits, and divergent maintained forks.
3. **Research maintained implementations in other languages** listed in `docs/reference-repositories.md`. Prioritise recent commits/issues that describe the same failure mode.
4. **Compare implementations**, not just patches. Identify the protocol fact that changed and distinguish required request fidelity from application-specific workarounds.
5. **Design the smallest Dart-native fix** that preserves public API compatibility unless a breaking change is genuinely necessary.
6. **Add regression coverage** proving the failure class, not merely that a JSON response parses.
7. Run static analysis and the relevant deterministic tests. Run live-network tests locally when they are required to prove fetchability; GitHub-hosted runners may be blocked by YouTube.
8. **Deep-review the complete diff before opening a PR**: error semantics, fallback behaviour, latency, retries, stream-type coverage, headers, resource cleanup, logging, tests, comments, and upstreamability.
9. Open a professional pull request **only in this fork**. A human may later submit an equivalent PR upstream.
10. Update the maintenance documentation when a client profile, fallback, reference repository, or known limitation changes.

## Evidence standard

A change to reverse-engineered behaviour must be supported by at least one of:

- reproducible network behaviour;
- current upstream issue/PR evidence;
- a recent implementation in a well-maintained extractor;
- current YouTube client metadata/policy observed by more than one maintained project.

Prefer corroboration from two independent maintained implementations for client identity, token policy, or transport changes.

Do not copy code blindly from another project. Different projects have different HTTP stacks, authentication/session models, parser assumptions, retry semantics, and licensing. Extract the protocol behaviour, then implement it idiomatically in Dart.

## Client impersonation and request fidelity

Treat InnerTube client identities as compatibility profiles, not as a place for arbitrary randomisation.

- Keep `clientName`, `clientVersion`, device/OS fields, `User-Agent`, headers, and visitor data internally consistent.
- Do not invent random client versions, rotate fake devices, or add fingerprint noise with the goal of evading YouTube controls. Inconsistent fingerprints are fragile and can make failures harder to diagnose.
- If YouTube requires a PO token or authentication for a client, document that requirement rather than disguising the client.
- Prefer a currently supported client profile that naturally satisfies the needed request path.
- Keep fallbacks narrow and evidence-based. A fallback must solve a known content class or failure mode; it must not be a list of every historical client.

See `docs/client-profiles.md` for the current profile matrix.

## Change isolation

Keep unrelated fixes in separate PRs. Parser changes, client-profile changes, transport changes, and broad refactors should not be bundled merely because they were discovered together.

This repository should remain easy to upstream. Avoid drive-by formatting, renames, dependency upgrades, or style rewrites in compatibility PRs.

## Pull request rules

Before creating a PR:

- review `git diff` / GitHub compare output file-by-file;
- verify the branch targets only this repository;
- ensure the PR contains one coherent change;
- include the failure, root cause, evidence, implementation, tests, limitations, and external references;
- use neutral, professional wording suitable for eventual upstream submission;
- do not claim a workaround is permanent;
- do not claim live-network behaviour was tested unless it actually was.

When several PRs are required, prefer independent, non-overlapping branches so the maintainer can merge them in the documented order without manual retargeting or rebasing.

## Baseline commands

```bash
dart pub get
dart analyze
dart test
```

Network tests may intentionally be skipped in GitHub Actions because YouTube commonly blocks hosted runner IPs. See `test/AGENTS.md` before changing skip behaviour.

## Maintenance documentation

The following documents are part of the source of truth and must remain current:

- `docs/maintenance.md`
- `docs/reference-repositories.md`
- `docs/client-profiles.md`

If implementation and documentation disagree about a client profile or fallback, fix both in the same PR.