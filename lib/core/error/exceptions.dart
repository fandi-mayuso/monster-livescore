// Typed exceptions thrown exclusively by data sources.
//
// These are caught at the repository boundary and converted into [Failure]
// types before reaching the domain or presentation layers.
// No code outside `data/` should ever catch or throw these directly.

/// Thrown when the remote API returns a non-2xx HTTP status code.
class ServerException implements Exception {
  /// The HTTP status code returned by the server.
  final int statusCode;

  /// A human-readable description of the error.
  final String message;

  const ServerException({required this.statusCode, required this.message});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when a local storage read or write operation fails.
class CacheException implements Exception {
  /// A human-readable description of the cache error.
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when the device has no connectivity or a request times out.
class NetworkException implements Exception {
  /// A human-readable description of the network error.
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the server responds with a 401 or 403 status code.
class UnauthorisedException implements Exception {
  /// A human-readable description of the authorisation error.
  final String message;

  const UnauthorisedException({required this.message});

  @override
  String toString() => 'UnauthorisedException: $message';
}

/// Thrown when user-supplied input fails validation before being sent to
/// the API or stored locally.
class ValidationException implements Exception {
  /// A human-readable description of the validation failure.
  final String message;

  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}
