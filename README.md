# SCAVO Exchange Frontend

SCAVO Exchange Frontend is the multiplatform Flutter client for SCAVO Exchange.

This repository is intentionally aligned to the backend contracts present in the paired project snapshot. At this stage, the frontend foundation focuses on:

- project documentation bootstrap
- responsive app shell for mobile, tablet, desktop, and web
- backend connectivity foundation
- typed contract modeling for the currently available authentication and system endpoints
- minimal authenticated bootstrap flow

## Supported platforms

The Flutter project is prepared for:

- Web
- Android
- iOS
- Windows
- macOS
- Linux

The UI foundation is responsive by layout class instead of operating system specific branching.

## Current backend-aligned scope

The current frontend implementation is intentionally limited to contracts confirmed in the backend ZIP:

- `GET /health`
- `GET /version`
- `POST /auth/login`
- `GET /auth/session`
- `GET /auth/me`
- base WebSocket envelope support for `/ws`

Wallet challenge, verify, and wallet inventory contracts are modeled, but not yet exposed as a full UI flow in this first frontend phase.

## Flutter version management

This project uses FVM with a pinned Flutter version for reproducible local development and CI behavior.

### Pinned version

- Flutter: `3.41.5`

### Project files

- `.fvmrc`
- `.vscode/settings.json`

### Recommended commands

```bash
fvm install 3.41.5
fvm use 3.41.5
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

## Runtime configuration

The app reads configuration from compile-time defines when available.

### Supported defines

- `SCAVO_API_BASE_URL`
- `SCAVO_WS_URL`
- `SCAVO_APP_ENV`
- `SCAVO_APP_NAME`

### Example

```bash
fvm flutter run -d chrome \
  --dart-define=SCAVO_API_BASE_URL=http://localhost:8080 \
  --dart-define=SCAVO_WS_URL=ws://localhost:8080/ws \
  --dart-define=SCAVO_APP_ENV=local
```

If omitted, the app defaults to:

- API: `http://localhost:8080`
- WS: `ws://localhost:8080/ws`
- environment: `local`

## Project structure

```text
lib/
  app/
  core/
  modules/
docs/
  handoff/
tools/
```

## Tooling security

Sensitive local tooling configuration must not be hardcoded in tracked scripts.

The repository now uses a local JSON file approach for tooling configuration:

- versioned example: `tools/sync_backend_repo.example.json`
- local untracked real file: `tools/sync_backend_repo.local.json`

## Validation target for this phase

- app starts without the Flutter counter template
- responsive shell is active
- `/health` and `/version` can be queried
- dev login works against the backend contract
- session restoration works with persisted bearer token

## Documentation

Frontend documentation starts in:

- `docs/index.md`
- `docs/architecture.md`
- `docs/roadmap.md`
- `docs/phase-status.md`
- `docs/phase0_1_frontend_baseline_multiplatform_foundation_and_backend_contract_alignment.md`
- `docs/handoff/frontend-status.md`
