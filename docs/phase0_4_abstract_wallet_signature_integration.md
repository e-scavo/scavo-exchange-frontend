# Phase 0.4 — Abstract Wallet Signature Integration

## Objective

Complete the wallet authentication path by adding an abstract signer strategy that can support external signers now and an internal SCAVIUM signer later.

## Initial Context

Phase 0.3 already exposed wallet challenge, manual verify, and wallet inventory preparation. The remaining gap was obtaining a signature from inside the application.

## Problem Statement

The frontend could request a challenge and submit a signature, but it still depended entirely on manual external signing.

## Scope

This phase adds:

- signer abstraction
- first external signer implementation for web browsers with MetaMask-style injected providers
- prepared internal signer contract for future SCAVIUM Wallet reuse
- retained manual fallback

## Root Cause Analysis

The frontend previously lacked a generic signing boundary, so any automatic signing feature would have been tightly coupled to one provider or one platform.

## Files Affected

- `lib/app/app.dart`
- `lib/modules/auth/controllers/wallet_flow_controller.dart`
- `lib/modules/auth/models/wallet_flow_state.dart`
- `lib/modules/auth/models/wallet_signature_models.dart`
- `lib/modules/auth/models/wallet_signer_state.dart`
- `lib/modules/auth/services/wallet_signer_service.dart`
- `lib/modules/auth/services/wallet_signer_stub.dart`
- `lib/modules/auth/services/wallet_signer_web.dart`
- `lib/modules/auth/services/wallet_signer_internal_contract.dart`
- `lib/modules/auth/services/wallet_signer_resolver.dart`
- `lib/modules/auth/ui/wallet_challenge_card.dart`
- `lib/modules/auth/ui/wallet_page.dart`
- `lib/modules/auth/ui/wallet_verify_card.dart`
- `docs/phase0_4_abstract_wallet_signature_integration.md`

## Implementation Characteristics

- manual signature entry remains supported
- automatic signing is attempted only through the abstract signer boundary
- MetaMask-style injected web providers are supported as the first concrete signer
- the internal SCAVIUM signer remains intentionally prepared but not implemented yet

## Validation

Phase 0.4 is considered valid when:

- wallet challenge still works
- the app can detect signer availability
- automatic signing is attempted when a supported signer exists
- manual fallback remains available when no signer exists
- verify and wallet inventory flows continue to work after a successful signature

## Release Impact

This phase expands wallet authentication ergonomics but does not yet deliver a full internal wallet implementation.

## Risks

- injected-provider behavior can vary between browsers and wallet extensions
- future internal signer work must respect the same abstraction instead of bypassing it

## What it does NOT solve

It does not yet integrate the full SCAVIUM Wallet cryptographic engine or mobile-native signer UX.

## Conclusion

Phase 0.4 introduces the long-term signer abstraction needed to support both external and future internal wallet authentication strategies without rewriting the auth flow.
