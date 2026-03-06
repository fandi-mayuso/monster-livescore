import 'package:monster_livescore/core/error/failures.dart';

/// Base contract for all use cases in the application.
///
/// [Type] is the expected success data type (e.g., `List<Match>`, `User`).
/// [Params] is the input parameter type. Use [NoParams] when no input is needed.
///
/// Every use case exposes a single `call()` operator so it can be invoked
/// like a function:
/// ```dart
/// final result = await getMatches(NoParams());
/// if (result.data != null) { ... } else { ... result.failure ... }
/// ```
///
/// Rules:
/// - Must NOT import `package:flutter`, Dio, or any data-layer class.
/// - Must NOT hold mutable state between calls.
/// - Must call only repository abstract methods.
abstract class UseCase<ReturnType, Params> {
  /// Executes the use case with the given [params].
  ///
  /// Returns a named record where exactly one field is non-null:
  /// - `data` is set on success.
  /// - `failure` is set on error.
  Future<({ReturnType? data, Failure? failure})> call(Params params);
}

/// Sentinel parameter type for use cases that require no input.
///
/// Usage:
/// ```dart
/// class GetMatches implements UseCase<List<Match>, NoParams> {
///   @override
///   Future<({List<Match>? data, Failure? failure})> call(NoParams params) { ... }
/// }
/// final result = await getMatches(NoParams());
/// ```
class NoParams {
  const NoParams();
}
