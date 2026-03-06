/// Domain-level failure types returned by repositories.
///
/// Repositories catch typed [Exception]s from data sources and convert them
/// into the appropriate [Failure] subtype. Presentation layer code (BLoCs)
/// handles [Failure] values to decide what to show the user.
///
/// Use exhaustive pattern matching on the sealed class:
/// ```dart
/// switch (failure) {
///   ServerFailure()      => 'Server error',
///   NetworkFailure()     => 'No connection',
///   CacheFailure()       => 'Local storage error',
///   UnauthorisedFailure() => 'Please log in again',
///   UnexpectedFailure()  => 'Something went wrong',
/// }
/// ```
sealed class Failure {
  /// A human-readable description for logging and debugging.
  /// Not intended to be shown verbatim to end users.
  final String message;

  const Failure({required this.message});
}

/// The remote API returned a non-2xx response.
final class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// The device has no connectivity or the request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// A local storage read or write operation failed.
final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// The server returned 401 or 403 — the user must re-authenticate.
final class UnauthorisedFailure extends Failure {
  const UnauthorisedFailure({required super.message});
}

/// A catch-all for any error not covered by the above subtypes.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
