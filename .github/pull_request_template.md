## Problem

<!-- Describe the externally observable failure or maintenance need. Include dates/video IDs/error classes when relevant. -->

## Root cause

<!-- Explain the protocol/parser/client behaviour that changed. Separate confirmed evidence from hypotheses. -->

## Change

<!-- Describe the smallest coherent implementation in this PR and why it belongs together. -->

## Evidence

<!-- Link the canonical Dart issue/PR and the maintained cross-language/fork evidence reviewed. Do not cite duplicate forks as independent confirmation. -->

## Verification

- [ ] `dart pub get`
- [ ] `dart analyze`
- [ ] deterministic `dart test` coverage
- [ ] relevant live-network regression verified locally, or explicitly documented as not run
- [ ] actual media bytes verified when this changes stream extraction/transport
- [ ] fallback content class verified when this adds/changes fallback behaviour

## Deep review

- [ ] Complete diff reviewed against the target branch
- [ ] No unrelated parser/refactor/dependency/formatting changes
- [ ] Client identity, headers and visitor/session data are internally consistent
- [ ] Shared static request/profile maps are not mutated with request-scoped values
- [ ] Error semantics are preserved; failed stream classes are not silently hidden
- [ ] Fallbacks are evidence-based and stop after a successful primary path
- [ ] Retry/latency impact considered
- [ ] Documentation/client profile ledger updated where required
- [ ] PR targets `mayanksharma2026/youtube_explode_dart` only

## Compatibility / limitations

<!-- State known content, region, authentication, PO-token, JS-player, HLS/DASH/SABR, or CI-network limitations. -->

## Upstreamability

<!-- Note anything fork-specific. Prefer a diff that can later be submitted to Hexer10/youtube_explode_dart without cleanup. -->