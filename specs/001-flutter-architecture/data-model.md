# Data Model: Flutter Project Architecture — Architectural Entities

**Phase**: 1 — Design  
**Branch**: `001-flutter-architecture`  
**Date**: 2026-03-06

> This document describes the **architectural abstractions** introduced by this feature — the structural building blocks every product feature will inherit. Domain entities for individual features (Match, Team, League, etc.) are specified separately in each feature's spec.

---

## 1. Core Error Hierarchy

Located in `lib/core/error/`.

### Exceptions (`exceptions.dart`)

Raw exceptions thrown by data sources. These are caught at the repository boundary and converted to Failures.

```
ServerException
├── statusCode: int
└── message: String

CacheException
└── message: String

NetworkException
└── message: String

UnauthorisedException
└── message: String

ValidationException
└── message: String
```

**Rules**:
- Data sources MUST only throw subtypes of these exceptions — no raw `Exception` or `Error` propagates upward.
- These are never exposed to the domain or presentation layers.

---

### Failures (`failures.dart`)

Sealed domain-level failure types returned by repositories. The presentation layer handles these.

```
sealed class Failure
├── ServerFailure       — API returned a non-2xx response
├── NetworkFailure      — No connectivity or request timed out
├── CacheFailure        — Local storage read/write failed
├── UnauthorisedFailure — 401/403 received; user must re-authenticate
└── UnexpectedFailure   — Catch-all for unmapped errors
```

Each `Failure` carries:
- `message: String` — human-readable description (for logging/debugging, not necessarily shown verbatim to users)

**Transitions**:
```
ServerException      → ServerFailure
NetworkException     → NetworkFailure
CacheException       → CacheFailure
UnauthorisedException → UnauthorisedFailure
Exception (any other) → UnexpectedFailure
```

---

## 2. UseCase Base Contract

Located in `lib/core/usecases/usecase.dart`.

```
abstract class UseCase<Type, Params>
└── call(Params params) → Future<({Type? data, Failure? failure})>

class NoParams   ← Used when a use case takes no input
```

**Rules**:
- Every use case is a single-method class with a `call()` operator.
- Return type is a Dart 3 named record `({Type? data, Failure? failure})`. Exactly one field is non-null per call.
- Use cases MUST NOT import `package:flutter`, Dio, or shared_preferences — they are pure Dart.
- Use cases MUST NOT hold state between calls.

---

## 3. Repository Pattern

Each feature defines two files for its repository:

### Abstract Repository (domain layer)

```
abstract class [Feature]Repository
└── [verb][Entity](params...) → Future<({[Entity]? data, Failure? failure})>
```

- Located in `lib/features/[feature]/domain/repositories/[feature]_repository.dart`
- Pure Dart — no Flutter, Dio, or shared_preferences imports
- Methods return named records (not raw types or thrown exceptions)

### Repository Implementation (data layer)

```
class [Feature]RepositoryImpl implements [Feature]Repository
├── _remoteDatasource: [Feature]RemoteDatasource
└── _localDatasource:  [Feature]LocalDatasource  (optional)
```

- Located in `lib/features/[feature]/data/repositories/[feature]_repository_impl.dart`
- Catches exceptions from data sources and maps to Failure types
- Applies offline-first or cache-aside logic as needed

---

## 4. Data Source Pattern

Each feature may have up to two data sources:

### Remote Data Source

```
abstract class [Feature]RemoteDatasource
└── fetch[Entity](params...) → Future<[Entity]Model>
    (throws ServerException | NetworkException | UnauthorisedException)

class [Feature]RemoteDatasourceImpl implements [Feature]RemoteDatasource
└── _apiClient: Dio
```

- Located in `lib/features/[feature]/data/datasources/[feature]_remote_datasource.dart`
- Uses Dio for HTTP; never returns Failure — throws typed exceptions instead

### Local Data Source (optional)

```
abstract class [Feature]LocalDatasource
└── getCached[Entity]() → Future<[Entity]Model>
└── cache[Entity]([Entity]Model model) → Future<void>
    (throws CacheException)

class [Feature]LocalDatasourceImpl implements [Feature]LocalDatasource
└── _prefs: SharedPreferences
```

- Located in `lib/features/[feature]/data/datasources/[feature]_local_datasource.dart`

---

## 5. Model vs Entity

| Concept | Location | Purpose | Dependencies |
|---------|----------|---------|-------------|
| **Entity** | `domain/entities/` | Pure business object; what the app reasons about | Pure Dart only |
| **Model** | `data/models/` | JSON-serialisable version of the entity; what the API/cache returns | `dart:convert` only |

**Rules**:
- Models extend (or compose) their corresponding entity.
- JSON serialisation logic (`fromJson`, `toJson`) lives **only** in the model — never in the entity.
- The domain layer never imports a model class.

---

## 6. BLoC Structure

Each feature's BLoC consists of three files:

### Events (`[feature]_event.dart`)

```
sealed class [Feature]Event extends Equatable
├── [Feature]Started    — initialise / load data
├── [Feature]Refreshed  — pull-to-refresh triggered
└── [Feature][Action]   — user interaction (filter, select, etc.)
```

**Rules**:
- Events MUST extend `Equatable` for deduplication.
- Events MUST be immutable (all fields `final`).
- Events represent **intent** — they never contain logic.

### States (`[feature]_state.dart`)

```
sealed class [Feature]State extends Equatable
├── [Feature]Initial    — before any data is loaded
├── [Feature]Loading    — data fetch in progress
├── [Feature]Loaded     — data successfully fetched; holds entity/list
└── [Feature]Error      — failure; holds a Failure object and user message
```

**Rules**:
- States MUST extend `Equatable`.
- States MUST be immutable.
- The `Loaded` state holds domain entities, not models.
- The `Error` state holds a `Failure` (for logging) and a `String userMessage` (for display).

### BLoC (`[feature]_bloc.dart`)

```
class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]State>
├── _useCase: Get[Entity]UseCase  (injected)
└── on<[Feature]Started>() → emits Loading → Loaded | Error
```

**Rules**:
- BLoCs MUST receive use cases via constructor injection (registered in `get_it`).
- BLoCs MUST NOT import Dio, shared_preferences, or any data layer class.
- A BLoC handles one conceptual domain — split if responsibility grows beyond ~3 event types.

---

## 7. Dependency Injection Registration

All registrations in `lib/injection_container.dart`.

```
Registration order (bottom-up):
1. External (Dio, SharedPreferences)
2. Data Sources
3. Repositories
4. Use Cases
5. BLoCs (registered as factories so each BlocProvider gets a fresh instance)
```

**Scoping rules**:
- `registerLazySingleton` → external services (Dio, SharedPreferences, Logger)
- `registerLazySingleton` → repositories and data sources
- `registerFactory` → BLoCs (a new instance per widget tree injection)

---

## 8. App-Level Entities

These are not feature-specific but are global architectural objects:

| Entity | Location | Purpose |
|--------|----------|---------|
| `FlavorConfig` | `core/config/flavor_config.dart` | Runtime environment configuration (existing) |
| `AppConstants` | `core/constants/app_constants.dart` | Named constants (existing) |
| `AppLogger` | `core/utils/app_logger.dart` | Shared logger instance wrapping the `logger` package |
| `ApiClient` | `core/network/api_client.dart` | Configured Dio factory (timeout, base URL, interceptors) |
| `AppTheme` | `core/theme/app_theme.dart` | ThemeData factory |
| `AppRouter` | `core/router/app_router.dart` | Named route map |
