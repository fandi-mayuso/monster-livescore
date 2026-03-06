import 'package:monster_livescore/core/error/failures.dart';

/// Shorthand for the standard repository return type used throughout the app.
///
/// Every repository method and use case returns a [ResultFuture] where exactly
/// one field in the named record is non-null:
/// - `data` is set on success.
/// - `failure` is set on error.
///
/// Usage:
/// ```dart
/// ResultFuture<List<Match>> getMatches();
/// // is equivalent to:
/// Future<({List<Match>? data, Failure? failure})> getMatches();
/// ```
typedef ResultFuture<T> = Future<({T? data, Failure? failure})>;
