import 'package:logger/logger.dart';
import 'package:monster_livescore/core/config/flavor_config.dart';

/// Application-wide logger singleton wrapping the `logger` package.
///
/// Use [AppLogger.instance] everywhere instead of `print()`.
/// Log level is driven by [FlavorConfig.instance.logLevel]:
/// - `VERBOSE` / `DEBUG` → all levels active
/// - `INFO`              → info, warning, error
/// - `WARNING`           → warning, error
/// - `ERROR`             → error only
///
/// Usage:
/// ```dart
/// AppLogger.instance.d('Fetching matches from API');
/// AppLogger.instance.i('Matches loaded: ${matches.length}');
/// AppLogger.instance.w('Retry attempt $attempt');
/// AppLogger.instance.e('Repository failed: ${failure.message}');
/// ```
class AppLogger {
  AppLogger._internal();

  static final AppLogger _instance = AppLogger._internal();

  /// The shared [AppLogger] instance. Use this throughout the app.
  static AppLogger get instance => _instance;

  late final Logger _logger = Logger(
    level: _resolveLevel(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Level _resolveLevel() {
    // FlavorConfig may not be initialised yet during very early startup;
    // default to verbose so nothing is missed before setFlavor() is called.
    try {
      final raw = FlavorConfig.instance.logLevel.toUpperCase();
      return switch (raw) {
        'VERBOSE' => Level.trace,
        'DEBUG' => Level.debug,
        'INFO' => Level.info,
        'WARNING' || 'WARN' => Level.warning,
        'ERROR' => Level.error,
        _ => Level.info,
      };
    } catch (_) {
      return Level.trace;
    }
  }

  /// Log a debug-level message. Use for detailed diagnostic information.
  void d(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  /// Log an info-level message. Use for high-level lifecycle events.
  void i(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  /// Log a warning-level message. Use for recoverable anomalies.
  void w(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// Log an error-level message. Use for failures that affect behaviour.
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
