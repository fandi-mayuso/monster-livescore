/// Application-wide named constants.
///
/// All magic numbers and strings used across the app must be declared here
/// (or in a domain-specific constants file) — never inline in widget or
/// service code.
class AppConstants {
  AppConstants._();

  // ── Networking ─────────────────────────────────────────────────────────────

  /// Maximum time allowed to establish a connection to the server.
  static const Duration apiConnectTimeout = Duration(seconds: 30);

  /// Maximum time allowed to receive the full server response.
  static const Duration apiReceiveTimeout = Duration(seconds: 30);

  // ── Feature flags ───────────────────────────────────────────────────────────

  /// Whether to collect analytics data (global default; overridden per flavor).
  static const bool enableAnalytics = true;

  // ── App information ─────────────────────────────────────────────────────────

  /// Current app version string.
  static const String appVersion = '1.0.0';
}

