# Contract: Abstract Repository Interface

**Layer**: Domain → Data boundary  
**Location**: `lib/features/[feature]/domain/repositories/[feature]_repository.dart`

## Purpose

The repository abstract class is the contract between the domain layer (use cases) and the data layer (implementations). Domain layer code depends only on this interface — never on `RepositoryImpl`, `RemoteDatasource`, or Dio.

## Rules

1. All methods return a named record `({T? data, Failure? failure})` — never throw exceptions.
2. The abstract class MUST import only `core/error/failures.dart` and domain entity files.
3. No Flutter, Dio, or platform-specific imports are permitted.
4. Method names use a `verb + noun` convention: `getMatches`, `getLiveScore`, `searchLeagues`.

## Template

```dart
import 'package:monster_livescore/core/error/failures.dart';
import 'package:monster_livescore/features/[feature]/domain/entities/[entity].dart';

/// Contract between the [Feature] domain and its data implementation.
///
/// All methods return a named record with exactly one non-null field:
/// either [data] on success or [failure] on error.
abstract class [Feature]Repository {
  Future<({[Entity]? data, Failure? failure})> get[Entity](String id);

  Future<({List<[Entity]>? data, Failure? failure})> get[Entity]List();

  // Add more methods as the feature requires, following the same return pattern.
}
```

## Accepted Return Patterns

```dart
// Success
return (data: entity, failure: null);

// Failure
return (data: null, failure: ServerFailure(message: 'Could not load data'));
```

## Prohibited Patterns

```dart
// ❌ Throwing exceptions from a repository
throw ServerException();

// ❌ Returning raw nullable without Failure context
Future<[Entity]?> get[Entity](String id);

// ❌ Importing implementation details
import 'package:dio/dio.dart';
```
