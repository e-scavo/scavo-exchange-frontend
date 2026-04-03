# Phase 0.1 — Frontend Baseline, Multiplatform Foundation and Backend Contract Alignment

## Objective

Transform the frontend from a Flutter template into a documented, backend-aligned, multiplatform application foundation.

## Initial Context

The paired backend ZIP already contained real contracts for health, version, authentication, sessions, wallet contracts, and base WebSocket behavior. The frontend ZIP only contained the default Flutter starter project and a local tooling script with hardcoded connection secrets.

## Problem Statement

The frontend had no safe base to consume the backend. It lacked:

- documentation
- app structure
- responsive navigation foundation
- typed contracts
- session persistence
- connectivity services
- tooling hardening

## Scope

Phase 0.1 includes:

- frontend documentation bootstrap
- responsive multiplatform shell foundation
- runtime configuration
- reusable API and WS clients
- typed models for current backend contracts
- minimal login and session restoration flow
- local tooling hardening

## Root Cause Analysis

The project was created from the Flutter template and had not yet been normalized into a SCAVO Exchange frontend codebase. Backend progress significantly outpaced frontend structure.

## Files Affected

### Modified

- `README.md`
- `.gitignore`
- `pubspec.yaml`
- `lib/main.dart`
- `test/widget_test.dart`
- `tools/sync_backend_repo.dart`

### Added

- `docs/index.md`
- `docs/architecture.md`
- `docs/roadmap.md`
- `docs/phase-status.md`
- `docs/phase0_1_frontend_baseline_multiplatform_foundation_and_backend_contract_alignment.md`
- `docs/handoff/frontend-status.md`
- `lib/app/*`
- `lib/core/*`
- `lib/modules/*`
- `tools/sync_backend_repo.example.json`

## Implementation Characteristics

### 1. Documentation foundation

Frontend documentation now exists inside the repo and becomes mandatory maintenance surface from this phase forward.

### 2. Multiplatform responsive shell

The application now chooses navigation presentation by width class:

- compact: drawer
- medium: navigation rail
- expanded: persistent sidebar

### 3. Contract-first integration

Only backend-confirmed contracts were modeled. No exchange endpoints, market payloads, or speculative WebSocket events were invented.

### 4. Minimal authenticated bootstrap flow

The frontend now:

- checks health and version
- restores persisted bearer token when present
- resolves `/auth/session`
- resolves `/auth/me`
- allows dev login using the backend's current contract

### 5. Tooling hardening

The previous hardcoded sync script configuration was replaced by a local JSON config file approach with an example file and `.gitignore` protections.

## Validation

Manual validation target for this phase:

1. run backend locally on `http://localhost:8080`
2. launch frontend with default config or matching `--dart-define` values
3. verify bootstrap loads service status and version
4. log in with an email and password `dev`
5. confirm session page shows session and user payloads
6. resize layout and verify shell adapts between drawer, rail, and sidebar behavior

## Release Impact

This phase changes the frontend from a template into a real project foundation but does not introduce exchange business features.

## Risks

- current login contract is explicitly dev-oriented and must not be mistaken for final product auth
- wallet contracts are modeled but not yet surfaced as full UX
- future phases must continue to avoid speculative product assumptions

## What it does NOT solve

This phase does not yet provide:

- logout UX hardening
- wallet challenge and signature UX
- wallet list UI
- portfolio or balances
- market/trading screens
- production branding pack

## Conclusion

Phase 0.1 is the correct first frontend milestone because it anchors the UI codebase to real backend contracts while establishing a responsive, documented, and scalable app foundation.
