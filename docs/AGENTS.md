# Documentation Agent Guidance

This file applies to `docs/` and supplements the root `AGENTS.md`.

## Role of this folder

The maintenance documents are operational source-of-truth for future compatibility work. They should help a new maintainer or coding agent understand **what to investigate, where to look, what evidence is strong enough, and how to avoid repeating old experiments**.

Keep the documents factual and dated when a statement depends on YouTube's current behaviour.

## Required documents

- `maintenance.md` — incident workflow and decision process.
- `reference-repositories.md` — maintained cross-language references and noteworthy Dart forks, including how to refresh the list.
- `client-profiles.md` — known InnerTube client behaviour and current fallback rationale.

If a new document becomes authoritative, link it from the root `AGENTS.md` and from the relevant scoped `AGENTS.md`.

## Research rules

For a YouTube breakage:

1. Start from a reproducible symptom and date.
2. Check canonical Dart upstream issues/PRs/commits.
3. Re-scan Dart forks rather than assuming the stored fork list is exhaustive.
4. Inspect recent commits/issues in maintained cross-language implementations.
5. Record the **protocol conclusion**, not just links to patches.
6. Separate confirmed facts, project-specific behaviour, and hypotheses.
7. Prefer primary repository evidence over blogs, copied snippets, or social posts.

A repository being popular does not make every workaround correct. Prefer recent evidence that directly addresses the observed failure.

## Fork classification

Do not label every GitHub fork as maintained. Classify a fork as noteworthy when it has one or more of:

- commits after the canonical upstream head relevant to the incident;
- an active custom branch with meaningful changes;
- an open PR carrying a distinct implementation;
- a downstream application demonstrably relying on its changes;
- repeated maintenance across more than one YouTube breakage.

Record unchanged/snapshot forks only when they provide useful downstream validation. Avoid an enormous static list that becomes stale.

## Updating `reference-repositories.md`

When refreshing the list, record:

- repository and language;
- default or relevant branch;
- why it is useful;
- the latest incident-relevant commit/PR/issue reviewed;
- the date it was reviewed;
- whether it is a protocol reference, parity reference, downstream validation source, or experimental fork.

Remove or downgrade a reference when it becomes archived, stale, or no longer provides independent evidence.

## Security and platform-control note

Do not document techniques whose purpose is arbitrary fingerprint randomisation, evasion of platform controls, or concealment. For reliability, document coherent client identities, required visitor/session data, documented token requirements, controlled fallbacks, and observable failure handling.

## Writing quality

Documentation should be concise, technical, and usable by another engineer without conversation history. Avoid claims such as “this always works” for reverse-engineered behaviour. Use wording such as “verified on YYYY-MM-DD” and describe the exact verification.