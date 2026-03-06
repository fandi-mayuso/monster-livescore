import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dio interceptor that injects an `Authorization` Bearer token into every
/// outgoing request.
///
/// Reads the token from [SharedPreferences] using the key [_tokenKey].
/// If no token is stored (e.g., unauthenticated user), the header is omitted
/// and the request proceeds without modification.
class AuthInterceptor extends Interceptor {
  static const _tokenKey = 'auth_token';

  final SharedPreferences _prefs;

  /// Creates an [AuthInterceptor] backed by the provided [SharedPreferences]
  /// instance.
  AuthInterceptor({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
