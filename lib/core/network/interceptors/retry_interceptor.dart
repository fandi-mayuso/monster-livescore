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
/// Backoff delays: 1 s → 2 s → 4 s.
/// After all retries are exhausted, throws a [NetworkException].
class RetryInterceptor extends Interceptor {
  /// Maximum number of retry attempts before giving up.
  final int maxRetries;

  /// Base backoff duration. Actual delay = [_baseDelay] * 2^attempt.
  static const _baseDelay = Duration(seconds: 1);

  final Dio _dio;
  final _logger = AppLogger.instance;

  /// Creates a [RetryInterceptor] that uses [dio] to replay failed requests.
  RetryInterceptor({required Dio dio, this.maxRetries = 3}) : _dio = dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isTimeout = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (!isTimeout) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    if (attempt >= maxRetries) {
      _logger.e('Max retries ($maxRetries) exceeded for ${err.requestOptions.uri}');
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: NetworkException(
            message: 'Max retries exceeded for ${err.requestOptions.uri}',
          ),
          type: DioExceptionType.unknown,
        ),
      );
    }

    final delay = _baseDelay * (1 << attempt); // 1s, 2s, 4s
    _logger.w(
      'Timeout on ${err.requestOptions.uri} — '
      'retry ${attempt + 1}/$maxRetries in ${delay.inSeconds}s',
    );

    await Future<void>.delayed(delay);

    final options = err.requestOptions
      ..extra['retryCount'] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }
}
