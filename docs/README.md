# Maintenance documentation

This directory contains fork-specific operational knowledge. It supplements the original package API documentation; it is not a replacement for source comments or tests.

## Start here

- [`maintenance.md`](maintenance.md) — incident triage, reproduction, research, porting and validation runbook.
- [`client-profiles.md`](client-profiles.md) — InnerTube profile ledger, current VisionOS compatibility profile and update rules.
- [`upstream-sources.md`](upstream-sources.md) — related implementations to research, what each source is useful for and licence cautions.
- [`release-and-upstream-sync.md`](release-and-upstream-sync.md) — keeping the fork close to upstream, release tagging, consumer pinning and rollback.
- [`decisions/0001-explicit-visionos-client.md`](decisions/0001-explicit-visionos-client.md) — decision to expose VisionOS explicitly without changing the package default.

## Agent instructions

Repository-wide agent policy is in [`../AGENTS.md`](../AGENTS.md). Relevant subtrees contain additional `AGENTS.md` files and are linked from the root guidance map.

## Documentation update rule

Update the affected document in the same pull request as a protocol, client-profile, fallback, validation or release-process change. Do not leave incident knowledge only in a chat, issue comment or commit message.
