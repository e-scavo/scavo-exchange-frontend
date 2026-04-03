# Phase 0.3 - Wallet and Identity Preparation Layer

## Objective
Expose backend-confirmed wallet challenge, manual verify, and wallet inventory flows in the frontend without inventing final wallet connector behavior.

## Initial Context
Phase 0.2 already centralizes HTTP and WebSocket authentication. The backend wallet contracts are present and the frontend already contains wallet models and API methods, but they were not yet available through the UI.

## Problem Statement
The product had real wallet contracts available in the backend while the frontend still exposed only bootstrap, login, and session views. This blocked wallet-auth experimentation and postponed identity visibility unnecessarily.

## Scope
This phase adds a wallet section to the application shell, a wallet challenge request flow, a manual signature verification flow, and an authenticated wallet inventory view.

## Root Cause Analysis
The gap came from missing UI surfacing rather than missing contracts. Backend challenge, verify, and inventory routes already existed, and frontend models were already implemented.

## Files Affected
- lib/app/router.dart
- lib/modules/auth/controllers/auth_session_controller.dart
- lib/modules/auth/controllers/wallet_flow_controller.dart
- lib/modules/auth/models/auth_state.dart
- lib/modules/auth/models/wallet_flow_state.dart
- lib/modules/auth/ui/wallet_page.dart
- lib/modules/auth/ui/wallet_challenge_card.dart
- lib/modules/auth/ui/wallet_verify_card.dart
- lib/modules/auth/ui/wallet_inventory_card.dart
- lib/modules/system/ui/bootstrap_page.dart
- lib/modules/auth/ui/login_page.dart
- lib/modules/auth/ui/session_page.dart
- test/widget_test.dart

## Implementation Characteristics
- Wallet challenge requests use the public backend contract only.
- Wallet verify expects manual signature input and persists the returned access token through the existing auth session controller.
- Wallet inventory is available only after an authenticated session exists.
- Session UI now surfaces wallet identity details when available.
- No connector automation, WalletConnect, or MetaMask-specific behavior was introduced.

## Validation
Expected validation for this phase:
- Request a challenge from the wallet page.
- Copy the challenge message and sign it externally.
- Paste the signature into the verify section.
- Confirm the frontend becomes authenticated through the returned access token.
- Refresh wallet inventory from the authenticated session.

## Release Impact
This phase expands the visible product surface without changing backend contracts. It prepares the app for future wallet linking and ownership management flows.

## Risks
- Users may assume the manual signature flow is the final UX.
- Inventory remains dependent on successful authentication.
- Wallet mutations such as primary, detach, and merge are still pending.

## What it does NOT solve
- Automatic wallet connector integration
- WalletConnect or MetaMask browser integration
- Wallet linking, merge, detach, or primary mutation UI
- Exchange dashboard or trading features

## Conclusion
Phase 0.3 makes wallet identity a first-class visible part of the frontend while staying fully aligned with the current backend truth.
