# Contract: UseCase Base Interface

**Layer**: Domain  
**Location**: `lib/core/usecases/usecase.dart`

## Purpose

Defines the single abstract method every use case must implement. Enforces a consistent call signature across all features.

## Rules

1. Each use case is one class with one public method: `call()`.
2. `call()` MUST return `Future<({Type? data, Failure? failure})>`.
3. No Flutter, Dio, or shared_preferences imports.
4. A use case MUST call only repository abstract methods — never data sources directly.
5. If a use case takes no parameters, use `NoParams`.

## Base Class

```dart
import 'package:monster_livescore/core/error/failures.dart';

/// Base contract for all use cases.
///
/// [Type] is the expected success data type.
/// [Params] is the input parameter type; use [NoParams] for parameterless cases.
abstract class UseCase<Type, Params> {
  Future<({Type? data, Failure? failure})> call(Params params);
}

/// Sentinel type for use cases that require no input parameters.
class NoParams {}
```

## Use Case Template

```dart
import 'package:monster_livescore/core/error/failures.dart';
import 'package:monster_livescore/core/usecases/usecase.dart';
import 'package:monster_livescore/features/[feature]/domain/entities/[entity].dart';
import 'package:monster_livescore/features/[feature]/domain/repositories/[feature]_repository.dart';

/// Retrieves a single [Entity] by its identifier.
class Get[Entity] implements UseCase<[Entity], String> {
  final [Feature]Repository _repository;

  Get[Entity]({required [Feature]Repository repository})
      : _repository = repository;

  @override
  Future<({[Entity]? data, Failure? failure})> call(String id) {
    return _repository.get[Entity](id);
  }
}
```

## Unit Test Template

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:monster_livescore/core/error/failures.dart';
import 'package:monster_livescore/features/[feature]/domain/repositories/[feature]_repository.dart';
import 'package:monster_livescore/features/[feature]/domain/usecases/get_[entity].dart';

@GenerateMocks([[Feature]Repository])
import 'get_[entity]_test.mocks.dart';

void main() {
  late Get[Entity] useCase;
  late Mock[Feature]Repository mockRepository;

  setUp(() {
    mockRepository = Mock[Feature]Repository();
    useCase = Get[Entity](repository: mockRepository);
  });

  test('returns data on success', () async {
    final entity = [Entity](/* ... */);
    when(mockRepository.get[Entity]('id-1'))
        .thenAnswer((_) async => (data: entity, failure: null));

    final result = await useCase('id-1');

    expect(result.data, equals(entity));
    expect(result.failure, isNull);
  });

  test('returns failure on error', () async {
    when(mockRepository.get[Entity]('bad-id'))
        .thenAnswer((_) async => (data: null, failure: ServerFailure(message: 'Not found')));

    final result = await useCase('bad-id');

    expect(result.failure, isA<ServerFailure>());
    expect(result.data, isNull);
  });
}
```
