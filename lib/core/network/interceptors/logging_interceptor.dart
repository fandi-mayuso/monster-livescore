import 'package:dio/dio.dart';
import 'package:monster_livescore/core/config/flavor_config.dart';
import 'package:monster_livescore/core/utils/app_logger.dart';

/// Dio interceptor that logs outgoing requests, incoming responses, and errors.
///
/// Only active when [FlavorConfig.instance.enableLogging] is `true`, so
/// production builds produce no network log output.
class LoggingInterceptor extends Interceptor {
  final _logger = AppLogger.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (FlavorConfig.instance.enableLogging) {
      _logger.d(
        '→ ${options.method} ${options.uri}\n'
        '  Headers: ${options.headers}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (FlavorConfig.instance.enableLogging) {
      final duration = _elapsedMs(response.requestOptions);
      _logger.i(
        '← ${response.statusCode} ${response.requestOptions.uri}'
        '${duration != null ? ' (${duration}ms)' : ''}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✗ ${err.type.name} ${err.requestOptions.uri}\n'
      '  Status: ${err.response?.statusCode}\n'
      '  Message: ${err.message}',
      err,
      err.stackTrace,
    );
    handler.next(err);
  }

  /// Returns elapsed milliseconds if the request carries a start-time stamp,
  /// otherwise returns null.
  int? _elapsedMs(RequestOptions options) {
    final start = options.extra['requestStartTime'];
    if (start is DateTime) {
      return DateTime.now().difference(start).inMilliseconds;
    }
    return null;
  }
}
