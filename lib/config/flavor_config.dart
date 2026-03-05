import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Enum to identify which environment/flavor is running
enum Flavor { dev, staging, prod }

class FlavorConfig {
  // Configuration variables that change per environment
  final Flavor flavor;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final String firebaseProjectId;
  final String logLevel;
  final bool enableAnalytics;

  FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.firebaseProjectId,
    required this.logLevel,
    required this.enableAnalytics,
  });

  // Singleton instance (only one config in memory at a time)
  static late FlavorConfig _instance;

  /// Set the flavor and configure accordingly
  /// Call this once at app startup with the appropriate flavor
  /// This also loads the corresponding .env file
  static Future<void> setFlavor(Flavor flavor) async {
    // Determine which .env file to load based on flavor
    late String envFile;
    switch (flavor) {
      case Flavor.dev:
        envFile = '.env.dev';
        break;
      case Flavor.staging:
        envFile = '.env.staging';
        break;
      case Flavor.prod:
        envFile = '.env.prod';
        break;
    }

    // Load the .env file
    await dotenv.load(fileName: envFile);

    // Get values from the loaded .env file
    // Using ?? to provide defaults if env var is missing
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
    final logLevel = dotenv.env['LOG_LEVEL'] ?? 'INFO';
    final enableAnalyticsStr = dotenv.env['ENABLE_ANALYTICS'] ?? 'true';
    final firebaseProjectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? 'myapp-dev';

    // Create the config instance with loaded values
    switch (flavor) {
      case Flavor.dev:
        _instance = FlavorConfig(
          flavor: Flavor.dev,
          apiBaseUrl: apiBaseUrl,
          appName: 'Monster Livescore Dev',
          enableLogging: true, // Always enable logging in dev
          firebaseProjectId: firebaseProjectId,
          logLevel: logLevel,
          enableAnalytics: _parseBoolean(enableAnalyticsStr),
        );
        break;
      case Flavor.staging:
        _instance = FlavorConfig(
          flavor: Flavor.staging,
          apiBaseUrl: apiBaseUrl,
          appName: 'Monster Livescore Staging',
          enableLogging: true, // Enable logging for debugging in staging
          firebaseProjectId: firebaseProjectId,
          logLevel: logLevel,
          enableAnalytics: _parseBoolean(enableAnalyticsStr),
        );
        break;
      case Flavor.prod:
        _instance = FlavorConfig(
          flavor: Flavor.prod,
          apiBaseUrl: apiBaseUrl,
          appName: 'Monster Livescore',
          enableLogging: false, // Disable debug banner for production users
          firebaseProjectId: firebaseProjectId,
          logLevel: logLevel,
          enableAnalytics: _parseBoolean(enableAnalyticsStr),
        );
        break;
    }

    // Log the loaded configuration (helpful for debugging)
    _logConfiguration();
  }

  /// Get the current config (use this throughout your app)
  static FlavorConfig get instance => _instance;

  /// Helper method to parse boolean strings from .env files
  /// ".env" files are text-based, so "true" is a string, not a boolean
  /// This converts "true", "True", "TRUE", "yes" → true
  ///           "false", "False", "FALSE", "no" → false
  static bool _parseBoolean(String value) {
    return value.toLowerCase() == 'true' ||
        value.toLowerCase() == 'yes' ||
        value == '1';
  }

  /// Log the current configuration
  /// Useful for debugging to confirm correct flavor loaded
  static void _logConfiguration() {
    print('═══════════════════════════════════════════════════════════');
    print('📱 FlavorConfig Loaded');
    print('═══════════════════════════════════════════════════════════');
    print('🎯 Flavor: ${_instance.flavor.toString().split('.').last.toUpperCase()}');
    print('📛 App Name: ${_instance.appName}');
    print('🌐 API Base URL: ${_instance.apiBaseUrl}');
    print('📊 Firebase Project: ${_instance.firebaseProjectId}');
    print('📝 Log Level: ${_instance.logLevel}');
    print('🔍 Debug Mode: ${_instance.enableLogging}');
    print('📈 Analytics Enabled: ${_instance.enableAnalytics}');
    print('═══════════════════════════════════════════════════════════');
  }

  /// Check if the app is running in a specific flavor
  /// Useful for conditional logic throughout the app
  bool isDev() => flavor == Flavor.dev;
  bool isStaging() => flavor == Flavor.staging;
  bool isProd() => flavor == Flavor.prod;

  /// Check if this is a production environment
  bool isProduction() => flavor == Flavor.prod;

  /// Get flavor name as string
  String getFlavorName() => flavor.toString().split('.').last;

  /// Get flavor name in uppercase
  String getFlavorNameUpperCase() => getFlavorName().toUpperCase();
}
