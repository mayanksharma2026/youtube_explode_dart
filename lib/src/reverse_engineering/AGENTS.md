# Reverse Engineering Agent Guidance

This file applies to `lib/src/reverse_engineering/` and supplements the root `AGENTS.md`.

## Scope

This subtree handles reverse-engineered HTTP, page, manifest, player, continuation, signature, and challenge behaviour. Small changes can affect unrelated features, so avoid broad “make YouTube work again” patches here.

## Diagnose before changing transport

Identify which request is actually failing before modifying `YoutubeHttpClient`, page parsers, continuation payloads, or solver code. A media CDN 403 caused by a client/token policy is not automatically evidence that the generic WEB continuation request needs new browser versions or headers.

Keep separate incidents separate:

- player API/client identity;
- watch-page parsing;
- continuation/browse/search parsing;
- visitor data;
- stream CDN transport/range requests;
- HLS/DASH parsing;
- JS signature/n challenge solving.

## Request fidelity

When adding headers or request context:

- identify which endpoint needs them;
- preserve caller-supplied headers;
- keep body/header client identity aligned;
- propagate request-scoped values such as visitor data consistently;
- do not add global headers merely because they fixed one endpoint in another project.

For range and fragmented media requests, verify that any required per-stream headers survive retries and refreshed manifests. Treat this as a transport invariant, not an anti-detection mechanism.

## Parser changes

YouTube often ships layouts gradually. Parser changes should:

- preserve the old path when practical;
- add a targeted fallback for the observed new shape;
- use null-safe extraction rather than assuming a single rollout;
- include fixture or focused regression coverage when feasible;
- avoid combining multiple unrelated page-layout migrations into a streaming/client PR.

## HLS/DASH/SABR

Do not treat missing progressive URLs as malformed automatically. Some clients can return server-side/SABR-only formats. Determine whether the chosen client is expected to provide progressive URLs before throwing, skipping, or falling back.

Do not silently convert a manifest into muxed-only output simply because a non-muxed HEAD request failed. Surface or recover from the actual failure class.

## Solver changes

Signature and n-challenge changes require evidence from the current player script/EJS tooling. Keep solver/runtime updates separate from client-profile changes unless both are demonstrably necessary for the same request path.

## Verification

A reverse-engineering PR should state exactly which endpoints and response shapes were exercised. If the change affects transport, test the resulting resource request, not only parsing.