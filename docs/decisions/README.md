# Architecture decisions

Architecture decision records preserve the reason behind fork-specific behaviour that is not obvious from code alone.

## Records

- [`0001-explicit-visionos-client.md`](0001-explicit-visionos-client.md) — add VisionOS as an opt-in profile without changing the package default.

## When an ADR is required

Add or amend an ADR when changing:

- the default client or client iteration/fallback semantics;
- authentication, cookies, visitor data or PO-token strategy;
- public API compatibility;
- broad retry, validation or error semantics;
- package identity, publishing or long-lived fork architecture.

A focused parser/client constant update can normally update existing operational documentation instead, unless it reverses a recorded decision.

## Format

Each record should include status, date, context, decision, rationale, alternatives, consequences, revisit conditions and stable evidence links. Do not rewrite an accepted historical decision to make it look as though later information was known at the time; supersede it with a new record.
