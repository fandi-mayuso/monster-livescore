# Implementation Plan: Flutter Project Architecture Setup

**Branch**: `001-flutter-architecture` | **Date**: 2026-03-06 | **Spec**: [spec.md](./spec.md)  
**Input**: "This project should use BLoC (Business Logic Component) design pattern with Clean Architecture (Presentation layer, Domain layer, Data layer)"

## Summary

Establish a scalable, maintainable project structure for the Monster Livescore Flutter app using **Clean Architecture** with three strict layers (Presentation → Domain → Data) and **BLoC** as the state management pattern. The outcome is a complete folder scaffold with four top-level directories — `core/` (infrastructure), `shared/` (cross-feature domain entities and repositories), `features/` (feature-specific slices), and `main/` (flavor entry points) — plus a documented template every developer follows when adding a new feature.

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK ^3.11.1  
**Primary Dependencies**: flutter_bloc ^8.1.x, get_it ^7.6.x, equatable ^2.0.x, Dio ^5.3.x, shared_preferences ^2.2.x, flutter_dotenv ^5.1.x, logger ^2.0.x  
**Storage**: shared_preferences (local key-value), remote REST API via Dio  
**Testing**: flutter_test (built-in), bloc_test ^9.1.x, mockito ^5.4.x  
**Target Platform**: iOS 15+ and Android (minSdk 21+)  
**Project Type**: Mobile app (iOS & Android)  
**Performance Goals**: 60 fps scrolling, <2 s data display after API response, <3 s cold start  
**Constraints**: <150 MB steady-state memory, offline-aware error handling, multi-flavor (dev/staging/prod) must be preserved  
**Scale/Scope**: ~10–20 feature modules expected (matches, leagues, standings, notifications, user profile, etc.)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Code Quality** | ✅ Pass | Architecture enforces business logic out of widgets via BLoC. File-size limit (300 lines) is compatible with the chosen structure. Constants centralised in `core/constants/`. |
| **II. Testing Standards** | ✅ Pass | BLoC layer is trivially unit-testable with `bloc_test`. Repository and data-source abstractions allow full mocking. `flutter_test` covers widget layer. |
| **III. UX Consistency** | ✅ Pass | Design system tokens (colours, typography, spacing) live in `core/theme/`. Loading/error states are domain-defined and handled uniformly by BLoC states. |
| **IV. Performance** | ✅ Pass | BLoC's event-stream model naturally debounces duplicate API calls. Dio interceptors (cache, retry) preserved. Lazy list rendering enforced by convention. |
| **State management — Provider** | ⚠️ **ADR Required** | Constitution §Dev Standards mandates Provider. BLoC is chosen instead. See **Complexity Tracking** below for full justification. This deviation is documented and approved as part of this architecture decision. |
| **Flavors** | ✅ Pass | Existing `FlavorConfig` and `.env.*` files are migrated into `core/config/` without any logic change. |
| **Logging** | ✅ Pass | `logger` package retained; `print()` statements in existing `FlavorConfig._logConfiguration()` will be replaced with `logger` calls during implementation. |
| **Secrets** | ✅ Pass | All secrets remain in `.env.*` files loaded via `flutter_dotenv`. No change. |

## Project Structure

### Documentation (this feature)

```text
specs/001-flutter-architecture/
├── plan.md              ← this file
├── research.md          ← Phase 0: decisions & rationale
├── data-model.md        ← Phase 1: architectural entities & contracts
├── quickstart.md        ← Phase 1: developer guide for adding a feature
├── contracts/           ← Phase 1: abstract interface definitions
│   ├── repository.md
│   ├── datasource.md
│   └── usecase.md
└── tasks.md             ← Phase 2 (/speckit.tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── app.dart                              # Root MaterialApp + global BlocProviders
├── injection_container.dart              # get_it service locator registration
│
├── main/                                 # (existing — preserved)
│   ├── main_dev.dart
│   ├── main_staging.dart
│   └── main_prod.dart
│
├── core/                                 # Infrastructure — no domain knowledge
│   ├── config/
│   │   └── flavor_config.dart            # (existing — moved from lib/config/)
│   ├── constants/
│   │   └── app_constants.dart            # (existing — moved from lib/constants/)
│   ├── error/
│   │   ├── exceptions.dart               # Raw exceptions thrown by data sources
│   │   └── failures.dart                 # Domain-level sealed failure types
│   ├── network/
│   │   ├── api_client.dart               # Dio instance factory + base options
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── logging_interceptor.dart
│   │       └── retry_interceptor.dart
│   ├── theme/
│   │   ├── app_theme.dart                # ThemeData factory
│   │   ├── app_colors.dart               # Colour token constants
│   │   └── app_text_styles.dart          # Typography scale
│   ├── router/
│   │   └── app_router.dart               # Named route definitions
│   ├── usecases/
│   │   └── usecase.dart                  # Abstract UseCase<Type, Params> base
│   └── utils/
│       ├── app_logger.dart               # Configured logger instance
│       └── typedef.dart                  # Shared type aliases
│
├── shared/                               # Domain entities & repositories used by ≥2 features
│   ├── domain/
│   │   ├── entities/                     # Pure Dart business objects (Match, Team, League…)
│   │   ├── repositories/                 # Abstract interfaces shared across features
│   │   └── usecases/                     # Use cases reused by multiple features
│   └── data/
│       ├── models/                       # JSON-serialisable versions of shared entities
│       ├── datasources/                  # Remote/local datasources for shared data
│       └── repositories/                 # Implementations of shared repository interfaces
│
└── features/                             # One directory per product feature
    └── [feature_name]/                   # e.g., match_list, live_score, standings
        ├── data/
        │   ├── datasources/              # Only if the feature has its own exclusive data source
        │   ├── models/                   # Only if the feature has its own exclusive models
        │   └── repositories/             # Only if the feature has its own exclusive repository
        ├── domain/
        │   ├── entities/                 # Feature-exclusive entities (not shared elsewhere)
        │   ├── repositories/             # Feature-exclusive abstract interfaces
        │   └── usecases/                 # Feature-specific use cases (may consume shared repos)
        └── presentation/
            ├── bloc/
            │   ├── [feature]_bloc.dart
            │   ├── [feature]_event.dart
            │   └── [feature]_state.dart
            ├── pages/
            │   └── [feature]_page.dart
            └── widgets/
                └── [reusable_widget].dart

test/
├── unit/
│   ├── core/
│   ├── shared/                           # Tests for shared domain & data layers
│   │   ├── domain/
│   │   └── data/
│   └── features/
│       └── [feature]/
│           ├── bloc/
│           ├── domain/
│           └── data/
├── widget/
│   └── features/
│       └── [feature]/
└── integration/
    └── features/
        └── [feature]/
```

**Structure Decision**: Feature-first (vertical slice) layout with a dedicated `shared/` layer for cross-feature domain logic. The four top-level directories serve distinct roles:

| Directory | Contains | Who may import it |
|-----------|----------|------------------|
| `core/` | Infrastructure (Dio, Logger, Failures, Theme) | `shared/`, `features/`, `app.dart` |
| `shared/` | Domain entities & repositories used by ≥2 features | `features/` only |
| `features/` | Feature-specific presentation, domain, and data | Nothing else |
| `main/` | Flavor entry points | Nothing else |

**Promotion rule**: Start an entity or repository inside its first feature. When a second feature needs it, promote it to `shared/`. This prevents premature abstraction while eliminating duplication the moment it appears.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| **BLoC instead of Provider** (Constitution §Dev Standards) | A livescore app is inherently event-driven: score updates, connection changes, user filter actions map cleanly to BLoC events. BLoC enforces strict separation — UI emits events, BLoC processes them, UI reacts to states — which is structurally harder to violate than Provider's open `notifyListeners()` pattern. `bloc_test` provides first-class unit testing with no widget tree required. | Provider's `ChangeNotifier` model is flexible but lacks enforced structure. In a team context building real-time data screens, the unstructured nature of Provider leads to business logic leaking into notifiers that also hold UI state. BLoC's explicit event/state contracts are the primary safeguard against the "spaghetti code" the spec targets. |
