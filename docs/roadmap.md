# SCAVO Exchange Frontend Roadmap

## Objective

Track the frontend evolution aligned to backend reality and prevent unsupported product assumptions.

## Initial Context

Frontend starts after backend Stage 0 / Phase 0.4 established authentication, session, wallet ownership foundations, and base WebSocket contracts.

## Problem Statement

The frontend must evolve in lockstep with backend contracts. A roadmap is required to separate what is already consumable from what must remain pending.

## Scope

This roadmap defines the near-term frontend progression.

## Root Cause Analysis

Without an explicit roadmap, the frontend could drift into speculative exchange UI before the backend exposes corresponding contracts.

## Files Affected

- `docs/roadmap.md`
- `docs/phase-status.md`
- future phase documents

## Implementation Characteristics

### Completed

- Phase 0.1 — Frontend Baseline, Multiplatform Foundation and Backend Contract Alignment

### Next likely frontend phases

#### Phase 0.2 — Auth Flow Hardening and Session UX

Possible focus:

- loading and error states refinement
- session-expired handling
- logout flow
- reusable authenticated shell state
- protected-route tightening

#### Phase 0.3 — Wallet Contract Surfacing

Possible focus, only because contracts already exist in backend:

- wallet challenge UI preparation
- wallet verify flow preparation
- wallet inventory visualization
- detach and primary eligibility representation

#### Future phases, backend-dependent

Pending backend availability:

- market data
- dashboard widgets
- order/trade flows
- portfolio views
- exchange-specific real-time event streams

## Validation

The roadmap remains valid only if each upcoming phase continues to be justified by the backend ZIP state.

## Release Impact

This roadmap is planning-only and does not itself change runtime behavior.

## Risks

- treating the roadmap as a commitment independent of backend evolution
- skipping validation against the paired backend ZIP

## What it does NOT solve

It does not define product deadlines or implementation commitments beyond the current verified phase.

## Conclusion

The roadmap keeps the frontend anchored to backend truth while still giving a clear expansion path.


## Near-term next step after Phase 0.3

- Add wallet linking, merge, primary, and detach preparation once backend validation paths are ready.
- Decide the definitive wallet connector strategy for web and mobile in a later phase.
