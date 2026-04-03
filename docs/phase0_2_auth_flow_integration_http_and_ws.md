# Phase 0.2 — Auth Flow Integration (HTTP + WS)

## Objective
Consolidate authentication into an application-level controller that restores the persisted token, resolves the authenticated HTTP session, and complements it with real WebSocket request/response validation using only backend-confirmed actions.

## Initial Context
Phase 0.1 already delivered the responsive shell, backend health/version connectivity, developer login, session persistence, and the baseline WebSocket client structure. The backend ZIP confirms `POST /auth/login`, `GET /auth/session`, `GET /auth/me`, and WebSocket actions `system.ping`, `auth.session`, and `auth.whoami`.

## Problem Statement
Auth state was still resolved page-by-page. Login, bootstrap, and session views each handled their own fetches, and WebSocket auth validation was not yet consolidated into the app flow.

## Scope
- Add a central auth/session controller.
- Restore persisted auth on app startup.
- Resolve HTTP session and user identity centrally.
- Connect to `/ws` with the persisted bearer token using the query-token path supported by the backend.
- Resolve `system.ping`, `auth.session`, and `auth.whoami`.
- Reflect HTTP + WS auth state in bootstrap, login, and session pages.

## Root Cause Analysis
The frontend foundation was enough to prove connectivity, but not enough to become a reusable authenticated application shell. State lived in individual pages instead of a shared controller.

## Files Affected
- `lib/app/app.dart`
- `lib/core/network/ws_client.dart`
- `lib/modules/auth/controllers/auth_session_controller.dart`
- `lib/modules/auth/models/auth_state.dart`
- `lib/modules/auth/models/whoami_models.dart`
- `lib/modules/auth/ui/login_page.dart`
- `lib/modules/auth/ui/session_page.dart`
- `lib/modules/system/ui/bootstrap_page.dart`
- `lib/modules/ws/models/ws_request_models.dart`
- `lib/modules/ws/models/ws_response_models.dart`
- `lib/modules/ws/services/auth_ws_service.dart`

## Implementation Characteristics
The implementation extends the existing frontend structure instead of replacing it with a new state-management stack. A single `AuthSessionController` now owns token restoration, login, logout, HTTP session recovery, and WebSocket validation state.

## Validation
Expected runtime validation:
- login still succeeds through HTTP
- token persists locally
- app restart restores authenticated state
- WebSocket connects when a token is present
- `system.ping`, `auth.session`, and `auth.whoami` resolve
- logout clears both local session and WS state

## Release Impact
No backend change is required. Frontend gains a central authenticated application state and a first real HTTP + WS integration boundary.

## Risks
- WebSocket may fail while HTTP auth stays valid; the controller marks this as degraded instead of forcing logout.
- Browser/network environments may behave differently on WS reconnects; the implementation keeps the protocol simple and request/response only.

## What it does NOT solve
- wallet challenge or wallet management UI
- exchange dashboard
- market streams
- order/trading flows
- refresh-token logic or server-side logout

## Conclusion
Phase 0.2 moves the frontend from page-local auth requests to a consistent application auth flow aligned with the backend contracts already present in the ZIP.
