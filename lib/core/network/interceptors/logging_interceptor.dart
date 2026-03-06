import 'package:dio/dio.dart';
import 'package:monster_livescore/core/config/flavor_config.dart';
import 'package:monster_livescore/core/utils/app_logger.dart';

/// Dio interceptor that logs the full request/response/error chain.
///
/// Logging is **only active** when [FlavorConfig.instance.enableLogging] is
/// `true` (dev and staging), so production builds produce zero network output.
///
/// Log levels:
/// - `d` (debug)   — outgoing request (URL, method, headers)
/// - `i` (info)    — incoming response (status code, duration in ms)
/// - `e` (error)   — any [DioException] (type, status code, message)
///
/// Timing: each outgoing request is stamped with a [DateTime] in
/// `options.extra['requestStartTime']`; the response handler reads this to
/// compute elapsed milliseconds.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Stamp start time so onResponse can compute elapsed duration.
    options.extra['requestStartTime'] = DateTime.now();

    if (FlavorConfig.instance.enableLogging) {
      final flavor = FlavorConfig.instance.flavor;
      final headerLine = flavor == Flavor.dev
          ? '\n  Headers: ${options.headers}'
          : '';

      logger.d(
        '→ ${options.method} ${options.uri}$headerLine',
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (FlavorConfig.instance.enableLogging) {
      final elapsed = _elapsedMs(response.requestOptions);
      final durationLabel = elapsed != null ? ' (${elapsed}ms)' : '';

      logger.i(
        '← ${response.statusCode} ${response.requestOptions.uri}$durationLabel',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (FlavorConfig.instance.enableLogging) {
      final elapsed = _elapsedMs(err.requestOptions);
      final durationLabel = elapsed != null ? ' (${elapsed}ms)' : '';

      logger.e(
        '✗ [${err.type.name}] ${err.requestOptions.method} '
        '${err.requestOptions.uri}$durationLabel\n'
        '  Status : ${err.response?.statusCode ?? 'N/A'}\n'
        '  Message: ${err.message}',
        err,
        err.stackTrace,
      );
    }

    handler.next(err);
  }

  /// Computes elapsed milliseconds since the request was stamped in [onRequest].
  /// Returns `null` if no stamp is present.
  int? _elapsedMs(RequestOptions options) {
    final start = options.extra['requestStartTime'];
    if (start is DateTime) {
      return DateTime.now().difference(start).inMilliseconds;
    }
    return null;
  }
}
