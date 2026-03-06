import 'package:flutter/material.dart';

/// Central colour palette for Monster Livescore.
///
/// Every colour used in the app **must** reference a constant from this class.
/// Never use `Colors.*` literals or hardcoded hex values in widget code.
///
/// Colour naming follows Material 3 role semantics so tokens map 1-to-1
/// onto [ColorScheme] in [AppTheme].
abstract final class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────

  /// Primary brand colour — used for key actions, active states, FABs.
  static const Color primary = Color(0xFF00C853);

  /// Darker shade of [primary] for pressed/hover states.
  static const Color primaryDark = Color(0xFF009624);

  /// Container fill associated with the primary colour.
  static const Color primaryContainer = Color(0xFFB9F6CA);

  /// Text/icons that sit on top of [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text/icons that sit on top of [primaryContainer].
  static const Color onPrimaryContainer = Color(0xFF002112);

  // ── Secondary ──────────────────────────────────────────────────────────────

  /// Accent colour — used for secondary actions, chips, highlights.
  static const Color secondary = Color(0xFF1565C0);

  /// Container fill associated with the secondary colour.
  static const Color secondaryContainer = Color(0xFFD0E4FF);

  /// Text/icons that sit on top of [secondary].
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Text/icons that sit on top of [secondaryContainer].
  static const Color onSecondaryContainer = Color(0xFF001C3B);

  // ── Background & Surface ───────────────────────────────────────────────────

  /// Main page background.
  static const Color background = Color(0xFF0D0D0D);

  /// Card / sheet surface.
  static const Color surface = Color(0xFF1A1A1A);

  /// Elevated surface (e.g., bottom-sheet over surface).
  static const Color surfaceVariant = Color(0xFF2C2C2C);

  /// Text/icons on [background].
  static const Color onBackground = Color(0xFFE0E0E0);

  /// Text/icons on [surface].
  static const Color onSurface = Color(0xFFE0E0E0);

  /// Subdued text/icons on [surfaceVariant].
  static const Color onSurfaceVariant = Color(0xFFAAAAAA);

  // ── Semantic ───────────────────────────────────────────────────────────────

  /// Destructive actions, validation errors.
  static const Color error = Color(0xFFCF6679);

  /// Container fill for error messages.
  static const Color errorContainer = Color(0xFF93000A);

  /// Text/icons on [error].
  static const Color onError = Color(0xFFFFFFFF);

  /// Text/icons on [errorContainer].
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ── Utility ────────────────────────────────────────────────────────────────

  /// Dividers, borders, subtle separators.
  static const Color outline = Color(0xFF3A3A3A);

  /// Subtle variant of [outline] for low-emphasis separators.
  static const Color outlineVariant = Color(0xFF2A2A2A);

  // ── Score-specific ─────────────────────────────────────────────────────────

  /// Win indicator (goal, green dot).
  static const Color win = Color(0xFF00C853);

  /// Loss indicator.
  static const Color loss = Color(0xFFCF6679);

  /// Draw / neutral indicator.
  static const Color draw = Color(0xFFFFAB00);

  /// Live match pulse colour.
  static const Color live = Color(0xFFFF1744);
}
