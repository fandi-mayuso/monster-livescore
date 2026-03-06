import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monster_livescore/core/config/flavor_config.dart';
import 'package:monster_livescore/core/constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Factory that creates and configures the application's [Dio] HTTP client.
///
/// The returned instance has:
/// - Base URL from [FlavorConfig.instance.apiBaseUrl]
/// - Connect and receive timeouts from [AppConstants]
/// - Three interceptors applied in order:
///   1. [LoggingInterceptor] — logs requests/responses/errors (dev/staging only)
///   2. [AuthInterceptor]   — injects the Bearer token if one is stored
///   3. [RetryInterceptor]  — retries timed-out requests with exponential backoff
///
/// Usage in `injection_container.dart`:
/// ```dart
/// sl.registerLazySingleton<Dio>(
///   () => createDio(FlavorConfig.instance, sl<SharedPreferences>()),
/// );
/// ```
Dio createDio(FlavorConfig config, SharedPreferences prefs) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: AppConstants.apiConnectTimeout,
      receiveTimeout: AppConstants.apiReceiveTimeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(prefs: prefs),
    RetryInterceptor(dio: dio),
  ]);

  return dio;
}
