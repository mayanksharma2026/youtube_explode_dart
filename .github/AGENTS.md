# GitHub Automation and Review Guide

This file extends the root [`AGENTS.md`](../AGENTS.md) for `.github/`.

## Workflows

- Pin third-party actions to a trusted major version or immutable SHA according to repository policy.
- Use least-privilege `permissions` blocks.
- Never expose secrets to pull requests from forks.
- Keep deterministic unit analysis/tests separate from live YouTube checks.
- Do not make external-source changes auto-merge. Source monitoring may open a report, but a human or coding agent must reproduce, compare, and review before implementation.
- Scheduled jobs must use bounded timeouts and avoid high-frequency requests to YouTube or external repositories.

## Issues

For protocol failures, require exact UTC date, package SHA, environment, public sample IDs, selected client, status/exception, manifest outcome, media-byte outcome, and redacted logs.

Do not accept reports containing cookies, tokens, signed media URLs, private video IDs, or account data. Ask reporters to redact them.

## Pull requests

Protocol PRs must follow the root PR standard and the repository template. Keep documentation-only, protocol, parser, and infrastructure changes separate unless one cannot be reviewed or tested without another.

Do not use vague titles such as `fix youtube`. Prefer Conventional Commit style with a narrow scope, for example:

- `fix(streams): preserve client headers for media requests`
- `fix(player): add VisionOS client compatibility profile`
- `docs(maintenance): catalogue active Dart forks`

A PR intended for possible upstream submission must avoid fork-specific branding in reusable code and preserve original contributor attribution.