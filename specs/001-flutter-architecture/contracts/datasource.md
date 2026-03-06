# Contract: Abstract Data Source Interface

**Layer**: Data layer internals  
**Location**: `lib/features/[feature]/data/datasources/[feature]_remote_datasource.dart`  
**Location**: `lib/features/[feature]/data/datasources/[feature]_local_datasource.dart`

## Purpose

Data source abstract classes define the contract between the repository implementation and the underlying data mechanism (HTTP API or local storage). This allows data sources to be swapped or mocked in tests without changing repository logic.

## Rules

1. Methods MUST return model objects (not domain entities) on success.
2. Methods MUST throw typed exceptions from `core/error/exceptions.dart` on failure — never return null or `Failure`.
3. Remote data sources MAY only import Dio and model classes.
4. Local data sources MAY only import `shared_preferences` and model classes.
5. No use case, BLoC, or domain entity is imported here.

## Remote Data Source Template

```dart
import 'package:dio/dio.dart';
import 'package:monster_livescore/core/error/exceptions.dart';
import 'package:monster_livescore/features/[feature]/data/models/[entity]_model.dart';

/// Contract for fetching [Feature] data from the remote API.
///
/// Throws typed exceptions — never returns null or Failure.
abstract class [Feature]RemoteDatasource {
  /// Fetches [entity] by [id] from the remote API.
  ///
  /// Throws [ServerException] on non-2xx responses.
  /// Throws [NetworkException] on connectivity failure or timeout.
  /// Throws [UnauthorisedException] on 401/403.
  Future<[Entity]Model> fetch[Entity](String id);

  Future<List<[Entity]Model>> fetch[Entity]List();
}

class [Feature]RemoteDatasourceImpl implements [Feature]RemoteDatasource {
  final Dio _dio;

  [Feature]RemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<[Entity]Model> fetch[Entity](String id) async {
    try {
      final response = await _dio.get('/[endpoint]/$id');
      return [Entity]Model.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw UnauthorisedException(message: 'Not authorised');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Request timed out');
      }
      throw ServerException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Server error',
      );
    }
  }

  @override
  Future<List<[Entity]Model>> fetch[Entity]List() async {
    // Follow same try/catch pattern as above
    throw UnimplementedError();
  }
}
```

## Local Data Source Template

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monster_livescore/core/error/exceptions.dart';
import 'package:monster_livescore/features/[feature]/data/models/[entity]_model.dart';

/// Contract for caching [Feature] data locally.
abstract class [Feature]LocalDatasource {
  /// Returns the last cached [entity].
  /// Throws [CacheException] if no data is cached or cache is corrupt.
  Future<[Entity]Model> getCached[Entity]();

  /// Writes [model] to the local cache.
  /// Throws [CacheException] on write failure.
  Future<void> cache[Entity]([Entity]Model model);
}

class [Feature]LocalDatasourceImpl implements [Feature]LocalDatasource {
  static const _cacheKey = 'CACHED_[ENTITY_UPPER]';

  final SharedPreferences _prefs;

  [Feature]LocalDatasourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<[Entity]Model> getCached[Entity]() async {
    final json = _prefs.getString(_cacheKey);
    if (json == null) throw CacheException(message: 'No cached data found');
    try {
      return [Entity]Model.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      throw CacheException(message: 'Cache data is corrupt');
    }
  }

  @override
  Future<void> cache[Entity]([Entity]Model model) async {
    final success = await _prefs.setString(_cacheKey, jsonEncode(model.toJson()));
    if (!success) throw CacheException(message: 'Failed to write to cache');
  }
}
```
