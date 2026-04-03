# SCAVO Exchange Frontend Architecture

## Objective

Describe the initial frontend architecture created in Phase 0.1 and define the baseline structure that future frontend subphases must extend.

## Initial Context

The frontend started as an unmodified Flutter template while the backend already exposed usable authentication and session contracts.

## Problem Statement

Without a documented architecture, the frontend risked growing as isolated screens without contract boundaries, responsive navigation rules, or a stable project structure.

## Scope

This document covers:

- app structure
- configuration strategy
- network boundaries
- session persistence
- responsive shell approach
- module organization

## Root Cause Analysis

The initial project was a vanilla Flutter bootstrap with no SCAVO-specific conventions. That left the project without:

- a core layer
- module boundaries
- contract typing
- environment configuration
- backend alignment rules
- responsive shell planning

## Files Affected

Primary architectural files introduced in Phase 0.1:

- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/app/theme.dart`
- `lib/app/responsive_app_shell.dart`
- `lib/core/config/app_config.dart`
- `lib/core/layout/app_breakpoints.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/ws_client.dart`
- `lib/core/storage/session_storage.dart`
- `lib/core/errors/app_error.dart`
- `lib/modules/...`

## Implementation Characteristics

### 1. Layered structure

The project is organized into three main frontend layers:

- `app/`: application composition, theme, shell, and routing
- `core/`: reusable infrastructure and technical primitives
- `modules/`: feature-specific models, services, and UI

### 2. Backend-first contracts

Only contracts validated in the backend ZIP are modeled as typed frontend objects.

At this phase, the frontend models:

- health
- version
- login
- me
- session
- wallet challenge and verify contracts
- wallet list contracts
- WebSocket envelope and base response structures

### 3. Responsive shell by breakpoint

The frontend uses a layout-class strategy rather than per-OS branching:

- compact: drawer-based shell
- medium: navigation rail shell
- expanded: persistent sidebar shell

### 4. Session boundary

The bearer token is stored through `SessionStorage`, then injected by `ApiClient` into authenticated calls.

### 5. Minimal service boundaries

Service classes currently exposed:

- `SystemApi`
- `AuthApi`

These services form the first contract boundary between UI and backend.


### 6. Toolchain baseline

The frontend now standardizes Flutter execution through FVM with a pinned SDK version:

- Flutter `3.41.5`
- `.fvmrc` as project truth
- `.vscode/settings.json` pointing to `.fvm/flutter_sdk`

This avoids drift between local machines and future CI execution.

## Validation

The architecture is considered valid for Phase 0.1 when:

- the app compiles without the template counter screen
- the layout responds to width changes
- authenticated and unauthenticated flows are clearly separated
- API and WS clients are reusable from future modules

## Release Impact

Phase 0.1 is a foundation phase only. It does not represent a feature-complete exchange frontend.

## Risks

- overgrowing the foundation before real market/trading contracts exist
- assuming wallet UX decisions before wallet connector strategy is defined
- coupling UI decisions to the current dev login as if it were the final auth mode

## What it does NOT solve

This architecture does not yet solve:

- exchange dashboard feature set
- market data flows
- order entry
- wallet signing UX
- production-grade route guarding across every future module

## Conclusion

The frontend now has a documented baseline architecture aligned to the real backend state and suitable for incremental expansion without inventing unsupported features.


## Phase 0.2

HTTP + WS auth integration added with a central session controller.


## Phase 0.3 extension

Wallet flows now reuse the existing auth session controller as the single session consolidation point. A dedicated wallet flow controller orchestrates challenge, verify, and inventory interactions without changing the application-wide auth pattern introduced in Phase 0.2.
