# SCAVO Exchange Frontend Status Handoff

## Objective

Provide a compact operational handoff of the frontend state after Phase 0.1.

## Initial Context

This handoff captures the first real frontend implementation aligned to the paired backend ZIP.

## Problem Statement

Future chats need a quick status summary that does not replace the full documents but helps re-enter the project safely.

## Scope

This handoff summarizes implemented foundation, current boundaries, and immediate next-phase candidates.

## Root Cause Analysis

The frontend now has enough structure that future work requires a concise but reliable project checkpoint.

## Files Affected

- `docs/handoff/frontend-status.md`

## Implementation Characteristics

### Implemented in Phase 0.1

- SCAVO frontend README
- frontend docs bootstrap
- responsive app shell
- app theme and router
- backend config via compile-time defines
- API client with bearer token support
- WS client foundation
- session persistence
- system and auth services
- health/version bootstrap screen
- dev login screen
- session display screen
- local tooling config hardening
- FVM pinning to Flutter 3.41.5

### Backend contracts currently consumed

- `GET /health`
- `GET /version`
- `POST /auth/login`
- `GET /auth/session`
- `GET /auth/me`

### Backend contracts already modeled but not yet surfaced as UX

- `POST /auth/wallet/challenge`
- `POST /auth/wallet/verify`
- `GET /auth/wallets`
- wallet linking, merge, detach, and primary contracts
- base `/ws` envelope

### Suggested next frontend phase

A likely next step is Phase 0.2 with focus on auth UX hardening and shell refinement, followed by wallet contract surfacing once UX decisions are approved.

## Validation

- run `fvm flutter pub get`
- run frontend against local backend
- log in with password `dev`
- confirm session and current user load successfully
- confirm responsive layout changes by width

## Release Impact

This handoff is documentation-only.

## Risks

- future work may try to jump directly into exchange features before backend contracts exist
- docs may drift if not updated incrementally per phase

## What it does NOT solve

It does not replace the detailed phase document or architecture document.

## Conclusion

Frontend is no longer a template. It now has a safe technical baseline for continued backend-aligned expansion.


## Current status after Phase 0.3

- Bootstrap, login, session, and wallet sections are available.
- Wallet challenge and verify are exposed through a manual signature workflow.
- Wallet inventory can be loaded from an authenticated session.
- Automatic wallet connectors are intentionally not implemented yet.

## Phase 0.4 status

- abstract signer layer added
- injected web signer implemented
- internal signer contract prepared
- manual fallback preserved
