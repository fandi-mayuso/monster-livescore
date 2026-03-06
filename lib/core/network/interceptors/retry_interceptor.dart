import 'package:dio/dio.dart';
import 'package:monster_livescore/core/error/exceptions.dart';
import 'package:monster_livescore/core/utils/app_logger.dart';

/// Dio interceptor that automatically retries timed-out requests with
/// exponential backoff.
///
/// Retries up to [maxRetries] times (default: 3) on:
/// - [DioExceptionType.connectionTimeout]
/// - [DioExceptionType.receiveTimeout]
///
/// Backoff schedule: 1 s → 2 s → 4 s (base × 2^attempt).
///
/// After exhausting all retries, the interceptor rejects the request with a
/// [DioException] whose `error` is a [NetworkException] with the message
/// `"Max retries exceeded"`.
///
/// Each retry attempt is logged via [AppLogger] at warning level so the
/// full retry timeline is visible in dev/staging logs.
class RetryInterceptor extends Interceptor {
  /// Maximum number of retry attempts before giving up.
  final int maxRetries;

  static const _baseDelay = Duration(seconds: 1);

  final Dio _dio;

  /// Creates a [RetryInterceptor] that uses [dio] to replay failed requests.
  RetryInterceptor({required Dio dio, this.maxRetries = 3}) : _dio = dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (!isRetryable) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    if (attempt >= maxRetries) {
      const message = 'Max retries exceeded';
      logger.e(
        '$message — ${err.requestOptions.method} ${err.requestOptions.uri} '
        '(tried $maxRetries time${maxRetries == 1 ? '' : 's'})',
      );
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(message: message),
          type: DioExceptionType.unknown,
        ),
      );
    }

    final delay = _baseDelay * (1 << attempt); // 1s, 2s, 4s
    logger.w(
      '⟳ Retry ${attempt + 1}/$maxRetries for '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '— waiting ${delay.inSeconds}s (${err.type.name})',
    );

    await Future<void>.delayed(delay);

    err.requestOptions.extra['retryCount'] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      logger.i(
        '✓ Retry ${attempt + 1} succeeded for ${err.requestOptions.uri}',
      );
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }
}
