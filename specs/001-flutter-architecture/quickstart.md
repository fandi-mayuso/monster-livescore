# Developer Quickstart: Monster Livescore Architecture

**Branch**: `001-flutter-architecture`  
**Date**: 2026-03-06

This guide explains how the project is structured and how to add a new feature from scratch. Read this before writing any code.

---

## Project Structure at a Glance

```
lib/
├── app.dart                  ← Root MaterialApp; registers global BlocProviders
├── injection_container.dart  ← All get_it registrations (add yours here)
├── main/                     ← Entry points per flavor (dev/staging/prod)
├── core/                     ← Infrastructure — never import features or shared from here
│   ├── config/               ← FlavorConfig (environment setup)
│   ├── constants/            ← AppConstants (named constants only)
│   ├── error/                ← Failure and Exception sealed classes
│   ├── network/              ← Dio factory + interceptors
│   ├── theme/                ← AppTheme, AppColors, AppTextStyles
│   ├── router/               ← Named route definitions
│   ├── usecases/             ← UseCase base class + NoParams
│   └── utils/                ← AppLogger, shared type aliases
├── shared/                   ← Domain entities & repos used by ≥2 features
│   ├── domain/
│   │   ├── entities/         ← e.g. match.dart, team.dart, league.dart
│   │   ├── repositories/     ← Abstract interfaces shared across features
│   │   └── usecases/         ← Use cases reused by multiple features
│   └── data/
│       ├── models/           ← JSON models for shared entities
│       ├── datasources/      ← Remote/local datasources for shared data
│       └── repositories/     ← Implementations of shared repo interfaces
└── features/                 ← One folder per product feature
    └── [feature_name]/
        ├── data/             ← Feature-exclusive JSON, Dio calls, SharedPreferences
        ├── domain/           ← Feature-exclusive entities, repo interfaces, use cases
        └── presentation/     ← Widgets, pages, BLoC
```

**Golden rules — dependency direction:**
```
presentation  →  domain  →  data          ✅  (inward only)
features/*    →  shared/                  ✅  (features consume shared)
features/*    →  core/                    ✅  (features consume core)
shared/       →  core/                    ✅  (shared consumes core)
domain        →  presentation             ❌
features/a    →  features/b               ❌  (never cross-feature)
core/         →  shared/ or features/     ❌  (core knows nothing about domain)
```

### Where does my code go?

| What you're writing | Where it lives |
|---------------------|---------------|
| Entity used by **one** feature | `features/[f]/domain/entities/` |
| Entity used by **two or more** features | `lib/shared/domain/entities/` |
| Repository used by **one** feature | `features/[f]/domain/repositories/` |
| Repository used by **two or more** features | `lib/shared/domain/repositories/` |
| Use case that is feature-specific | `features/[f]/domain/usecases/` |
| Use case reused across features | `lib/shared/domain/usecases/` |
| HTTP / local storage logic | `data/datasources/` (feature or shared) |
| BLoC, pages, widgets | `features/[f]/presentation/` always |
| Dio, Logger, Theme, Router | `core/` always |

> **Promotion rule**: Start inside the feature. When a second feature needs the same entity or repository, move it to `shared/`. Don't abstract prematurely.

---

## Adding a New Feature (Step-by-Step)

### Step 1 — Create the folder skeleton

Replace `[feature]` and `[Entity]` with your feature and entity names (e.g., `match_list`, `Match`).

```bash
mkdir -p lib/features/[feature]/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
mkdir -p test/unit/features/[feature]/{bloc,domain,data}
mkdir -p test/widget/features/[feature]
```

If you're adding or promoting a **shared** entity/repository (used by ≥2 features):

```bash
mkdir -p lib/shared/{domain/{entities,repositories,usecases},data/{models,datasources,repositories}}
mkdir -p test/unit/shared/{domain,data}
```

### Step 2 — Domain Entity

`lib/features/[feature]/domain/entities/[entity].dart`

```dart
import 'package:equatable/equatable.dart';

/// Core [Entity] business object. Pure Dart — no Flutter or platform imports.
class [Entity] extends Equatable {
  final String id;
  final String name;
  // Add fields relevant to this entity

  const [Entity]({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
```

### Step 3 — Repository Interface (domain layer)

`lib/features/[feature]/domain/repositories/[feature]_repository.dart`

```dart
import 'package:monster_livescore/core/utils/typedef.dart';
import 'package:monster_livescore/features/[feature]/domain/entities/[entity].dart';

abstract class [Feature]Repository {
  ResultFuture<[Entity]> get[Entity](String id);
  ResultFuture<List<[Entity]>> get[Entity]List();
}
```

### Step 4 — Use Case

`lib/features/[feature]/domain/usecases/get_[entity]_list.dart`

```dart
import 'package:monster_livescore/core/usecases/usecase.dart';
import 'package:monster_livescore/core/utils/typedef.dart';
import 'package:monster_livescore/features/[feature]/domain/entities/[entity].dart';
import 'package:monster_livescore/features/[feature]/domain/repositories/[feature]_repository.dart';

class Get[Entity]List implements UseCase<List<[Entity]>, NoParams> {
  final [Feature]Repository _repository;

  Get[Entity]List({required [Feature]Repository repository})
      : _repository = repository;

  @override
  ResultFuture<List<[Entity]>> call(NoParams params) {
    return _repository.get[Entity]List();
  }
}
```

### Step 5 — Data Model

`lib/features/[feature]/data/models/[entity]_model.dart`

```dart
import 'package:monster_livescore/features/[feature]/domain/entities/[entity].dart';

class [Entity]Model extends [Entity] {
  const [Entity]Model({required super.id, required super.name});

  factory [Entity]Model.fromJson(Map<String, dynamic> json) {
    return [Entity]Model(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

### Step 6 — Remote Data Source

`lib/features/[feature]/data/datasources/[feature]_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import 'package:monster_livescore/core/error/exceptions.dart';
import 'package:monster_livescore/features/[feature]/data/models/[entity]_model.dart';

abstract class [Feature]RemoteDatasource {
  Future<List<[Entity]Model>> fetch[Entity]List();
}

class [Feature]RemoteDatasourceImpl implements [Feature]RemoteDatasource {
  final Dio _dio;
  [Feature]RemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<[Entity]Model>> fetch[Entity]List() async {
    try {
      final response = await _dio.get('/[endpoint]');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => [Entity]Model.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Unknown error',
      );
    }
  }
}
```

### Step 7 — Repository Implementation

`lib/features/[feature]/data/repositories/[feature]_repository_impl.dart`

```dart
import 'package:monster_livescore/core/error/exceptions.dart';
import 'package:monster_livescore/core/error/failures.dart';
import 'package:monster_livescore/core/utils/typedef.dart';
import 'package:monster_livescore/features/[feature]/data/datasources/[feature]_remote_datasource.dart';
import 'package:monster_livescore/features/[feature]/domain/entities/[entity].dart';
import 'package:monster_livescore/features/[feature]/domain/repositories/[feature]_repository.dart';

class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]RemoteDatasource _remote;

  [Feature]RepositoryImpl({required [Feature]RemoteDatasource remote})
      : _remote = remote;

  @override
  ResultFuture<[Entity]> get[Entity](String id) async {
    throw UnimplementedError(); // implement as needed
  }

  @override
  ResultFuture<List<[Entity]>> get[Entity]List() async {
    try {
      final models = await _remote.fetch[Entity]List();
      // List<[Entity]Model> cannot be directly returned as List<[Entity]> —
      // use List<[Entity]>.from() to perform the covariant cast safely.
      return (data: List<[Entity]>.from(models), failure: null);
    } on ServerException catch (e) {
      return (data: null, failure: ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return (data: null, failure: NetworkFailure(message: e.message));
    } catch (e) {
      return (data: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }
}
```

### Step 8 — BLoC

**Events** — `lib/features/[feature]/presentation/bloc/[feature]_event.dart`

```dart
part of '[feature]_bloc.dart';

sealed class [Feature]Event extends Equatable {
  const [Feature]Event();
  @override List<Object?> get props => [];
}

final class [Feature]Started extends [Feature]Event {
  const [Feature]Started();
}

final class [Feature]Refreshed extends [Feature]Event {
  const [Feature]Refreshed();
}
```

**States** — `lib/features/[feature]/presentation/bloc/[feature]_state.dart`

```dart
part of '[feature]_bloc.dart';

sealed class [Feature]State extends Equatable {
  const [Feature]State();
  @override List<Object?> get props => [];
}

final class [Feature]Initial extends [Feature]State {
  const [Feature]Initial();
}

final class [Feature]Loading extends [Feature]State {
  const [Feature]Loading();
}

final class [Feature]Loaded extends [Feature]State {
  final List<[Entity]> items;
  const [Feature]Loaded({required this.items});
  @override List<Object?> get props => [items];
}

final class [Feature]Error extends [Feature]State {
  final Failure failure;
  final String userMessage;
  const [Feature]Error({required this.failure, required this.userMessage});
  @override List<Object?> get props => [failure, userMessage];
}
```

**BLoC** — `lib/features/[feature]/presentation/bloc/[feature]_bloc.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monster_livescore/core/error/failures.dart';
import 'package:monster_livescore/core/usecases/usecase.dart';
import 'package:monster_livescore/features/[feature]/domain/entities/[entity].dart';
import 'package:monster_livescore/features/[feature]/domain/usecases/get_[entity]_list.dart';

part '[feature]_event.dart';
part '[feature]_state.dart';

class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]State> {
  final Get[Entity]List _get[Entity]List;

  [Feature]Bloc({required Get[Entity]List get[Entity]List})
      : _get[Entity]List = get[Entity]List,
        super(const [Feature]Initial()) {
    on<[Feature]Started>(_onStarted);
    on<[Feature]Refreshed>(_onStarted);
  }

  Future<void> _onStarted(
    [Feature]Event event,
    Emitter<[Feature]State> emit,
  ) async {
    emit(const [Feature]Loading());
    final result = await _get[Entity]List(NoParams());
    if (result.data != null) {
      emit([Feature]Loaded(items: result.data!));
    } else {
      emit([Feature]Error(
        failure: result.failure!,
        userMessage: 'Failed to load data. Please try again.',
      ));
    }
  }
}
```

### Step 9 — Register in DI

`lib/injection_container.dart`

```dart
// [Feature] — add in dependency order (external → data → domain → presentation)

// Data sources
sl.registerLazySingleton<[Feature]RemoteDatasource>(
  () => [Feature]RemoteDatasourceImpl(dio: sl()),
);

// Repositories
sl.registerLazySingleton<[Feature]Repository>(
  () => [Feature]RepositoryImpl(remote: sl()),
);

// Use cases
sl.registerLazySingleton(() => Get[Entity]List(repository: sl()));

// BLoC (factory = new instance per BlocProvider)
sl.registerFactory(() => [Feature]Bloc(get[Entity]List: sl()));
```

### Step 10 — Connect to UI

```dart
// In app.dart or the page's parent route:
BlocProvider(
  create: (_) => sl<[Feature]Bloc>()..add(const [Feature]Started()),
  child: const [Feature]Page(),
)

// In [feature]_page.dart:
BlocBuilder<[Feature]Bloc, [Feature]State>(
  builder: (context, state) {
    return switch (state) {
      [Feature]Initial() => const SizedBox.shrink(),
      [Feature]Loading() => const Center(child: CircularProgressIndicator()),
      [Feature]Loaded(:final items) => [Feature]ListView(items: items),
      [Feature]Error(:final userMessage) => ErrorView(
          message: userMessage,
          onRetry: () => context.read<[Feature]Bloc>().add(const [Feature]Refreshed()),
        ),
    };
  },
)
```

---

## Promoting a Feature Entity to Shared

When a second feature needs an entity or repository that already lives inside a feature, follow these steps:

### 1. Move the files

```bash
# Example: Match entity lives in features/match_list, now live_score also needs it
mv lib/features/match_list/domain/entities/match.dart         lib/shared/domain/entities/match.dart
mv lib/features/match_list/data/models/match_model.dart       lib/shared/data/models/match_model.dart
mv lib/features/match_list/domain/repositories/match_repository.dart  lib/shared/domain/repositories/match_repository.dart
mv lib/features/match_list/data/repositories/match_repository_impl.dart lib/shared/data/repositories/match_repository_impl.dart
mv lib/features/match_list/data/datasources/match_remote_datasource.dart lib/shared/data/datasources/match_remote_datasource.dart
```

### 2. Update imports in both features

```dart
// Before
import 'package:monster_livescore/features/match_list/domain/entities/match.dart';

// After
import 'package:monster_livescore/shared/domain/entities/match.dart';
```

### 3. Move tests too

```bash
mv test/unit/features/match_list/domain/match_test.dart  test/unit/shared/domain/match_test.dart
```

### 4. No DI changes needed

The `injection_container.dart` registration stays the same — the concrete class just moved directories. Only the import path in that file changes.

---

## Key Conventions

| Rule | Correct | Wrong |
|------|---------|-------|
| Business logic location | Inside BLoC | Inside widget `build()` |
| Error propagation | Return `Failure` from repository | Throw exceptions past repository boundary |
| State equality | Use `Equatable` on all states/events | Manual `==` override |
| Logging | `logger.d('msg')` | `print('msg')` |
| Colours | `AppColors.primary` | `Colors.blue` |
| Constants | `AppConstants.apiTimeout` | Inline `'30'` |
| Entity used by 1 feature | `features/[f]/domain/entities/` | — |
| Entity used by 2+ features | `shared/domain/entities/` | Import from another feature |
| Cross-feature coupling | Never — use `shared/` | `features/a` importing `features/b` |

---

## Running Tests

```bash
# Generate mocks (run after adding @GenerateMocks annotations)
dart run build_runner build --delete-conflicting-outputs

# Unit + widget tests with coverage
flutter test --coverage

# Integration tests (requires connected device or emulator)
flutter test integration_test/

# Run with specific flavor
flutter run --flavor dev -t lib/main/main_dev.dart
```

Coverage must remain **≥ 80%** per the project constitution.
