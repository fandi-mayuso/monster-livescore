# Architecture Guide — Monster Livescore

> **For new contributors**: Read this document first. It answers "where does my code go?" for every situation.

---

## Table of Contents

1. [Overview](#overview)
2. [Directory Structure](#directory-structure)
3. [Layer Rules & Dependency Direction](#layer-rules--dependency-direction)
4. [Feature-First Folder Template](#feature-first-folder-template)
5. [Shared Layer — Promotion Rule](#shared-layer--promotion-rule)
6. [BLoC Pattern — Three-File Breakdown](#bloc-pattern--three-file-breakdown)
7. [Dependency Injection](#dependency-injection)
8. [Naming Conventions](#naming-conventions)
9. [Where Does My Code Go?](#where-does-my-code-go)
10. [Adding a New Feature — Checklist](#adding-a-new-feature--checklist)

---

## Overview

The project uses **Clean Architecture** (Presentation → Domain → Data) with **BLoC** for state management. The folder structure is **feature-first** — every module lives in its own vertical slice under `lib/features/`.

```
Presentation  ←──  BLoC  ←──  UseCase  ←──  Repository  ←──  DataSource
    (UI)         (state)      (domain)         (domain)          (data)
```

Dependencies always point **inward** — outer layers depend on inner layers, never the reverse.

---

## Directory Structure

```
lib/
├── core/               # App-wide infrastructure (no business logic)
│   ├── config/         # FlavorConfig — environment variables, feature flags
│   ├── constants/      # AppConstants — magic numbers, timeouts, keys
│   ├── error/          # Exceptions (data layer) & Failures (domain/presentation)
│   ├── network/        # Dio setup, interceptors (logging, auth, retry)
│   │   └── interceptors/
│   ├── router/         # AppRoutes (constants) + AppRouter (route map)
│   ├── theme/          # AppColors, AppTextStyles, AppTheme
│   ├── usecases/       # Abstract UseCase<ReturnType, Params> base class
│   └── utils/          # AppLogger, ResultFuture typedef, shared helpers
│
├── shared/             # Cross-feature domain entities promoted from features/
│   ├── domain/
│   │   ├── entities/   # Equatable value objects used by ≥2 features
│   │   ├── repositories/
│   │   └── usecases/
│   └── data/
│       ├── models/
│       ├── datasources/
│       └── repositories/
│
├── features/           # One folder per product feature (vertical slices)
│   └── <feature>/
│       ├── domain/     # Pure Dart — entities, repository contracts, usecases
│       ├── data/       # Implementations — models, datasources, repository impls
│       └── presentation/
│           ├── bloc/   # BLoC, events, states
│           ├── pages/  # Full-screen widgets (route targets)
│           └── widgets/ # Feature-scoped reusable widgets
│
└── main/               # Entry points per environment
    ├── main_dev.dart
    ├── main_staging.dart
    └── main_prod.dart
```

### Top-Level Directory Rules

| Directory | What belongs here | What does NOT belong here |
|-----------|-------------------|--------------------------|
| `core/` | Infrastructure used by the entire app (networking, routing, theming, DI) | Business logic, UI widgets, feature code |
| `shared/` | Domain entities / repos / use cases shared by ≥ 2 features | Feature-specific logic, data sources |
| `features/` | All product features, self-contained vertical slices | Cross-feature dependencies (promote to `shared/`) |
| `main/` | Entry point files only | Any logic — call `initDependencies()` and `runApp()` |

---

## Layer Rules & Dependency Direction

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│  Pages, Widgets, BLoC (events/states/bloc)  │
│  ↳ Depends on: Domain only (via UseCases)   │
└────────────────────┬────────────────────────┘
                     │ calls
┌────────────────────▼────────────────────────┐
│               Domain Layer                  │
│  Entities, Repository contracts, UseCases   │
│  ↳ Depends on: Nothing (pure Dart)          │
└────────────────────┬────────────────────────┘
                     │ implements
┌────────────────────▼────────────────────────┐
│                Data Layer                   │
│  Models, DataSources, Repository impls      │
│  ↳ Depends on: Domain contracts only        │
└─────────────────────────────────────────────┘
```

**Golden rules:**

1. **Domain has zero Flutter/Dio imports** — pure Dart only.
2. **Presentation never touches DataSources or Models** — always goes through a UseCase.
3. **Failures, not Exceptions, cross layer boundaries** — DataSources throw `Exception`; Repositories catch them and return `Failure` via `ResultFuture<T>`.
4. **BLoCs are scoped to `registerFactory`** — never singletons; they are created fresh per route.

---

## Feature-First Folder Template

When adding a new feature (e.g., `live_matches`):

```
lib/features/live_matches/
├── domain/
│   ├── entities/
│   │   └── match_entity.dart          # Equatable value object — no Flutter imports
│   ├── repositories/
│   │   └── matches_repository.dart    # abstract class — returns ResultFuture<T>
│   └── usecases/
│       └── get_live_matches.dart      # implements UseCase<List<MatchEntity>, NoParams>
├── data/
│   ├── models/
│   │   └── match_model.dart           # extends MatchEntity; has fromJson / toJson
│   ├── datasources/
│   │   └── matches_remote_datasource.dart  # throws typed Exceptions
│   └── repositories/
│       └── matches_repository_impl.dart    # implements MatchesRepository; catches → Failure
└── presentation/
    ├── bloc/
    │   ├── live_matches_bloc.dart
    │   ├── live_matches_event.dart
    │   └── live_matches_state.dart
    ├── pages/
    │   └── live_matches_page.dart
    └── widgets/
        └── match_card.dart
```

---

## Shared Layer — Promotion Rule

**Start in the feature.** Move to `shared/` only when a second feature needs it.

```
Step 1: Feature A creates lib/features/feature_a/domain/entities/league_entity.dart
Step 2: Feature B also needs LeagueEntity
Step 3: Move the file to lib/shared/domain/entities/league_entity.dart
Step 4: Update imports in both features
Step 5: Move the DI registration to the "shared" section of injection_container.dart
```

Do **not** pre-emptively put entities in `shared/` — wait for the second consumer.

---

## BLoC Pattern — Three-File Breakdown

Every feature BLoC is split across three files:

### `<feature>_event.dart`
```dart
part of '<feature>_bloc.dart';

sealed class LiveMatchesEvent extends Equatable {
  const LiveMatchesEvent();
}

final class LiveMatchesStarted extends LiveMatchesEvent {
  const LiveMatchesStarted();
  @override List<Object?> get props => [];
}
```

### `<feature>_state.dart`
```dart
part of '<feature>_bloc.dart';

sealed class LiveMatchesState extends Equatable {
  const LiveMatchesState();
}

final class LiveMatchesInitial extends LiveMatchesState {
  const LiveMatchesInitial();
  @override List<Object?> get props => [];
}

final class LiveMatchesLoading extends LiveMatchesState {
  const LiveMatchesLoading();
  @override List<Object?> get props => [];
}

final class LiveMatchesLoaded extends LiveMatchesState {
  const LiveMatchesLoaded(this.matches);
  final List<MatchEntity> matches;
  @override List<Object?> get props => [matches];
}

final class LiveMatchesError extends LiveMatchesState {
  const LiveMatchesError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
```

### `<feature>_bloc.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// ... other imports

part '<feature>_event.dart';
part '<feature>_state.dart';

class LiveMatchesBloc extends Bloc<LiveMatchesEvent, LiveMatchesState> {
  LiveMatchesBloc({required GetLiveMatches getLiveMatches})
      : _getLiveMatches = getLiveMatches,
        super(const LiveMatchesInitial()) {
    on<LiveMatchesStarted>(_onStarted);
  }

  final GetLiveMatches _getLiveMatches;

  Future<void> _onStarted(
    LiveMatchesStarted event,
    Emitter<LiveMatchesState> emit,
  ) async {
    emit(const LiveMatchesLoading());
    final result = await _getLiveMatches(const NoParams());
    if (result.failure != null) {
      emit(LiveMatchesError(result.failure!.message));
    } else {
      emit(LiveMatchesLoaded(result.data!));
    }
  }
}
```

---

## Dependency Injection

All DI wiring lives in `lib/injection_container.dart`. Registration order must be **bottom-up**:

```
DataSources → Repositories → UseCases → BLoCs
```

| Type | Registration | Reason |
|------|-------------|--------|
| External services (Dio, SharedPrefs, Logger) | `registerLazySingleton` | Created once, shared globally |
| DataSources | `registerLazySingleton` | Stateless, safe to share |
| Repositories | `registerLazySingleton` | Stateless, safe to share |
| UseCases | `registerLazySingleton` | Stateless, safe to share |
| BLoCs | `registerFactory` | Must be fresh per page/route |

Retrieve with `sl<T>()`. Never construct dependencies with `SomeThing()` outside `injection_container.dart`.

---

## Naming Conventions

> All naming conventions below are **enforced at CI** via `flutter analyze`.
> `analysis_options.yaml` activates `prefer_const_constructors`,
> `prefer_const_declarations`, `require_trailing_commas`, `avoid_print`,
> and `prefer_single_quotes`.

### Files — `snake_case` with role suffix

Every file name must end with a suffix that identifies its architectural role.
This makes the purpose of any file obvious without opening it.

| Artefact | Suffix | Example file | Example class |
|----------|--------|-------------|---------------|
| Entity | `_entity` | `match_entity.dart` | `MatchEntity` |
| JSON model | `_model` | `match_model.dart` | `MatchModel` |
| Repository contract | `_repository` | `matches_repository.dart` | `MatchesRepository` |
| Repository impl | `_repository_impl` | `matches_repository_impl.dart` | `MatchesRepositoryImpl` |
| DataSource contract | `_datasource` | `matches_remote_datasource.dart` | `MatchesRemoteDatasource` |
| DataSource impl | `_datasource_impl` | `matches_remote_datasource_impl.dart` | `MatchesRemoteDatasourceImpl` |
| UseCase | verb phrase | `get_live_matches.dart` | `GetLiveMatches` |
| BLoC | `_bloc` | `live_matches_bloc.dart` | `LiveMatchesBloc` |
| BLoC events | `_event` | `live_matches_event.dart` | `LiveMatchesEvent` |
| BLoC states | `_state` | `live_matches_state.dart` | `LiveMatchesState` |
| Page (full screen) | `_page` | `live_matches_page.dart` | `LiveMatchesPage` |
| Reusable widget | descriptive | `match_card.dart` | `MatchCard` |

### Classes — `PascalCase` matching the file name

The class name must be the PascalCase version of the file name (without the `.dart` extension).

```
match_entity.dart         →  class MatchEntity
matches_repository.dart   →  abstract class MatchesRepository
matches_repository_impl.dart  →  class MatchesRepositoryImpl
get_live_matches.dart     →  class GetLiveMatches
live_matches_bloc.dart    →  class LiveMatchesBloc
live_matches_page.dart    →  class LiveMatchesPage
```

### No Abbreviations in Public Names

Public class names, method names, and field names must not use abbreviations.

```dart
// ❌ Bad
class MatchRepo { ... }
class GetMatchsUC { ... }
String usrId;

// ✅ Good
class MatchesRepository { ... }
class GetLiveMatches { ... }
String userId;
```

### Events & States — Dart 3 sealed + `final class`

BLoC events and states use Dart 3's exhaustive sealed class pattern.
The base class is `sealed`, all concrete subtypes use `final class`.

```dart
// Base — sealed so the switch is exhaustive at compile time
sealed class LiveMatchesEvent extends Equatable {
  const LiveMatchesEvent();
}

// Concrete events — final class (cannot be subclassed further)
final class LiveMatchesStarted extends LiveMatchesEvent {
  const LiveMatchesStarted();
  @override List<Object?> get props => [];
}

final class LiveMatchesRefreshed extends LiveMatchesEvent {
  const LiveMatchesRefreshed();
  @override List<Object?> get props => [];
}

// States follow the same pattern
sealed class LiveMatchesState extends Equatable {
  const LiveMatchesState();
}

final class LiveMatchesInitial  extends LiveMatchesState { ... }
final class LiveMatchesLoading  extends LiveMatchesState { ... }
final class LiveMatchesLoaded   extends LiveMatchesState { ... }
final class LiveMatchesError    extends LiveMatchesState { ... }
```

The exhaustive `switch` in the page guarantees **every state is handled** at compile time — no runtime `default` case required:

```dart
switch (state) {
  LiveMatchesInitial()  => const SizedBox.shrink(),
  LiveMatchesLoading()  => const CircularProgressIndicator(),
  LiveMatchesLoaded()   => _buildList(state.matches),
  LiveMatchesError()    => _buildError(state.userMessage),
}
```

### Linter Enforcement

| Rule | Effect |
|------|--------|
| `avoid_print` | Forces use of `AppLogger` — no raw `print()` |
| `prefer_const_constructors` | Ensures widgets and value objects are `const` where possible |
| `prefer_const_declarations` | Ensures local variables holding constant values are declared `const` |
| `require_trailing_commas` | Keeps multi-line arg lists consistently formatted |
| `prefer_single_quotes` | Enforces consistent string literal style |

---

## Where Does My Code Go?

| I need to add… | Put it in… |
|----------------|-----------|
| A new screen / page | `lib/features/<feature>/presentation/pages/` |
| A reusable widget (one feature) | `lib/features/<feature>/presentation/widgets/` |
| A reusable widget (cross-feature) | `lib/core/` or a new shared widget package |
| A BLoC / event / state | `lib/features/<feature>/presentation/bloc/` |
| A domain entity (one feature) | `lib/features/<feature>/domain/entities/` |
| A domain entity (two+ features) | `lib/shared/domain/entities/` |
| A repository contract | `lib/features/<feature>/domain/repositories/` |
| A repository implementation | `lib/features/<feature>/data/repositories/` |
| A use case | `lib/features/<feature>/domain/usecases/` |
| An API model (fromJson/toJson) | `lib/features/<feature>/data/models/` |
| A remote data source | `lib/features/<feature>/data/datasources/` |
| A named route constant | `lib/core/router/app_router.dart` — `AppRoutes` |
| A colour token | `lib/core/theme/app_colors.dart` |
| A text style token | `lib/core/theme/app_text_styles.dart` |
| An app-wide constant | `lib/core/constants/app_constants.dart` |
| A new environment variable | `.env.*` files + `FlavorConfig` |

---

## Adding a New Feature — Checklist

```
□ 1. Create lib/features/<feature>/ directory tree (domain, data, presentation/bloc,pages,widgets)
□ 2. Create the Entity  (domain/entities/) — Equatable, no Flutter imports
□ 3. Create the Repository contract (domain/repositories/) — returns ResultFuture<T>
□ 4. Create the UseCase(s) (domain/usecases/) — implements UseCase<T, Params>
□ 5. Create the Model (data/models/) — extends Entity, adds fromJson/toJson
□ 6. Create the DataSource (data/datasources/) — throws typed Exceptions
□ 7. Create the Repository impl (data/repositories/) — catches Exceptions → Failure
□ 8. Create BLoC files (presentation/bloc/) — event, state, bloc
□ 9. Create Page(s) and Widget(s) (presentation/pages|widgets/)
□ 10. Register in injection_container.dart (DataSource → Repo → UseCase → BLoC)
□ 11. Add route constant to AppRoutes and entry to AppRouter.routes
□ 12. Run flutter analyze — zero warnings before opening a PR
```

See `specs/001-flutter-architecture/quickstart.md` for the full step-by-step guide.
