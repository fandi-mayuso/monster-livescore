# Research: Flutter Project Architecture Setup

**Phase**: 0 — Outline & Research  
**Branch**: `001-flutter-architecture`  
**Date**: 2026-03-06

## Decision 1: Architecture Pattern — Clean Architecture with BLoC

**Decision**: Adopt Clean Architecture (Presentation → Domain → Data) with BLoC as the state management pattern, replacing the Provider dependency listed in the current `pubspec.yaml`.

**Rationale**:  
Clean Architecture separates concerns into three layers with a strict inward dependency rule (outer layers depend on inner layers, never the reverse). For a livescore app that fetches real-time data from remote APIs, this means:
- UI widgets only know about BLoC states — they never call Dio directly.
- Domain use cases contain pure business rules — they never import Flutter or Dio.
- Data repositories implement domain abstractions — they can be swapped or mocked in tests.

BLoC (Business Logic Component) fits this model naturally because it enforces an explicit contract between UI (events) and state (outputs). Every state transition is traceable through a single event stream, which is ideal for debugging data display bugs in live-score scenarios.

**Alternatives considered**:

| Alternative | Why Rejected |
|-------------|-------------|
| Provider (current) | Flexible but unstructured — `ChangeNotifier` allows business logic to leak into the notifier class, which is exactly the "spaghetti code" the spec targets. No built-in event/state separation. |
| Riverpod | Strong alternative, but requires team relearning and has no first-class "event" concept for real-time data flows. BLoC's explicit `Event` sealed class is a better fit for sports score update events. |
| GetX | Mixes routing, DI, and state management — creates tight coupling between layers that Clean Architecture is specifically designed to avoid. |
| MobX / Redux | Significantly more ceremony for the expected team size and feature count (~10–20 modules). |

---

## Decision 2: Dependency Injection — get_it

**Decision**: Use `get_it` (service locator) for dependency injection.

**Rationale**:  
`get_it` is the de-facto standard DI solution for Flutter Clean Architecture projects. It:
- Registers all dependencies in a single `injection_container.dart` file, giving a clear map of the entire object graph.
- Works perfectly with `flutter_bloc` — Blocs are created by the DI container and provided to the widget tree via `BlocProvider`.
- Is compile-safe (no code generation required, unlike injectable).
- Is trivial to mock in tests by re-registering a fake implementation before a test run.

**Alternatives considered**:

| Alternative | Why Rejected |
|-------------|-------------|
| injectable (get_it + code gen) | Adds code generation complexity. Appropriate for very large teams; overkill for this project's scale. |
| Provider-based DI | Tightly coupled to Provider state management pattern being replaced. |
| Manual constructor injection | No central registration point — adding a new dependency requires touching every call site. |

---

## Decision 3: Error Handling — Sealed Failure Types (no external FP library)

**Decision**: Define custom sealed `Failure` classes in `core/error/failures.dart`. Use Dart's native `sealed class` (Dart 3) for exhaustive pattern matching. No `dartz` or `fpdart` dependency.

**Rationale**:  
Dart 3's `sealed class` provides exhaustive `switch` pattern matching natively. For a mobile app with a small number of error categories (NetworkFailure, ServerFailure, CacheFailure, ValidationFailure), a custom sealed hierarchy is:
- Zero additional dependency
- Readable by team members unfamiliar with functional programming idioms
- Fully compatible with BLoC states (a BLoC state can simply hold a `Failure` object)

Each repository method returns `({T? data, Failure? failure})` as a named record (Dart 3 records), or a simple result type class, instead of the `Either<Failure, T>` pattern common with `dartz`.

**Alternatives considered**:

| Alternative | Why Rejected |
|-------------|-------------|
| `dartz` Either<L,R> | Functional idiom unfamiliar to most Flutter developers; adds a learning curve for the team. Not needed when Dart 3 records/sealed classes are available. |
| `fpdart` | Same concern as dartz. Modern but still FP-heavy. |
| Exceptions only (try/catch everywhere) | Unstructured; errors escape the data layer as raw exceptions, making UI error handling inconsistent — the exact problem the spec targets. |

---

## Decision 4: New Dependencies Required

The following packages must be added to `pubspec.yaml`:

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.0 | BLoC pattern implementation |
| `equatable` | ^2.0.5 | Value equality for BLoC events/states (avoids manual `==` overrides) |
| `get_it` | ^7.6.0 | Service locator / dependency injection |
| `bloc_test` | ^9.1.0 (dev) | Unit testing BLoC classes |
| `mockito` | ^5.4.0 (dev) | Mocking repositories and data sources in tests |
| `build_runner` | ^2.4.0 (dev) | Required by mockito for mock generation |

The following package should be **removed** from `pubspec.yaml`:

| Package | Reason |
|---------|--------|
| `provider` | Replaced by `flutter_bloc`. The constitution §Dev Standards mandates Provider; this removal is the ADR-documented exception tracked in `plan.md` Complexity Tracking. |

---

## Decision 5: Networking Layer — Dio with Interceptors

**Decision**: Centralise all HTTP communication in `core/network/api_client.dart` as a configured Dio factory. Three interceptors: `AuthInterceptor`, `LoggingInterceptor`, `RetryInterceptor`.

**Rationale**:  
Dio is already a project dependency and is superior to the `http` package for this use case because it natively supports interceptors. Centralising setup ensures:
- All requests go through the same base URL (from `FlavorConfig`).
- Auth headers are injected uniformly.
- Failed requests are retried automatically.
- All outgoing/incoming traffic is logged in dev/staging only.

The `http` package can remain as a dependency but should not be used for feature development — Dio is the standard.

**Alternatives considered**: N/A — Dio already chosen and present.

---

## Decision 6: Feature Folder Convention — Feature-First (Vertical Slice)

**Decision**: Organise `lib/features/` by product feature, not by architectural layer.

**Rationale**:  
A layer-first organisation (`lib/presentation/`, `lib/domain/`, `lib/data/`) places related code far apart — to work on the "matches" feature a developer must navigate three top-level directories. A feature-first structure (`lib/features/matches/`) keeps all three layers together, making the feature self-contained and easier to:
- Delete (remove a feature by deleting one folder).
- Review (a PR for "matches" touches only `features/matches/`).
- Understand (a new developer sees the complete feature in one place).

Each feature still enforces the three-layer internal structure (`data/`, `domain/`, `presentation/`) so Clean Architecture rules are not relaxed.

---

## Decision 7: Testing Strategy

**Decision**: Three-tier test organisation mirroring the architecture.

| Test Type | Location | Tooling | What It Covers |
|-----------|----------|---------|---------------|
| Unit | `test/unit/` | `bloc_test`, `mockito` | BLoC event/state transitions, use cases, repository implementations (with mocked data sources) |
| Widget | `test/widget/` | `flutter_test` | Pages and widgets rendering correct output for each BLoC state |
| Integration | `test/integration/` | `flutter_test` integration_test | Full user flows on device/emulator |

All repository and data-source dependencies are injected via `get_it`, making substitution with fakes straightforward in tests.

---

## Decision 8: Routing — Named Routes in app_router.dart

**Decision**: Centralise all route definitions in `core/router/app_router.dart` using Flutter's built-in `MaterialPageRoute` + named route pattern. No third-party router in this phase.

**Rationale**:  
The current `app.dart` already uses `MaterialApp`. Named routes with a central router file is sufficient for the expected ~10–20 screens and requires no new dependency. If the team later needs deep linking or nested navigation, migrating to `go_router` is straightforward from a centralised router file.

**Alternatives considered**:

| Alternative | Why Rejected |
|-------------|-------------|
| `go_router` | Excellent package but adds complexity before any routing pain is felt. Deferred to a future ADR when deep linking is required. |
| `auto_route` | Requires code generation; same rationale as injectable — overkill for current scope. |
