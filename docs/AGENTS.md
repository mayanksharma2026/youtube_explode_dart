# Documentation Agent Guide

This file extends the root [`AGENTS.md`](../AGENTS.md) for `docs/`.

## Evidence and dates

- Treat client profiles and server behaviour as time-sensitive.
- Record `last_reviewed_utc`, exact commits, affected paths, and observed limitations.
- Prefer permanent commit links over moving branch links when documenting evidence.
- Separate observed facts, upstream statements, downstream reports, and local inference.
- Never write “permanent”, “always”, or “never” for undocumented YouTube behaviour without qualification.

## Source registry

[`maintenance-sources.yaml`](maintenance-sources.yaml) is the machine-readable source of truth. [`upstream-sources.md`](upstream-sources.md) explains how to use it; [`fork-survey.md`](fork-survey.md) records the comparative review.

When adding or updating a source:

1. verify that the repository is the intended upstream/fork rather than an unmodified mirror;
2. record the default branch and exact reviewed commit;
3. state why it is relevant and which paths/features to inspect;
4. classify it as authoritative, comparative, downstream signal, or watch-only;
5. record cautions, app-specific behaviour, and licensing considerations;
6. update the snapshot date.

Do not promote a fork to “maintained” from a recent fork creation alone. Look for independent commits, issue activity, releases, or production use.

## Decision records

Use an ADR for defaults, fallback strategy, new public API, transport architecture, or changes that future maintainers may otherwise undo. ADRs are append-only: supersede an old decision rather than rewriting its historical rationale.

## Security and privacy

Do not include cookies, authorization headers, PO tokens, visitor identifiers, account data, or complete signed stream URLs in docs or examples.