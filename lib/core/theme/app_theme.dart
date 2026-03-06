import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Centralised [ThemeData] factory for Monster Livescore.
///
/// Usage in `app.dart`:
/// ```dart
/// MaterialApp(theme: AppTheme.dark());
/// ```
///
/// Rules:
/// - All colours reference [AppColors] tokens — never `Colors.*`.
/// - All text styles reference [AppTextStyles] tokens — never raw `TextStyle`.
abstract final class AppTheme {
  AppTheme._();

  /// Default dark theme tailored for a livescore experience.
  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(AppColors.onBackground),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 0.5,
        space: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.onSurface,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  /// Light variant — kept for future design-system parity.
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
      surfaceContainerHighest: Color(0xFFF5F5F5),
      onSurfaceVariant: Color(0xFF666666),
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      outline: Color(0xFFE0E0E0),
      outlineVariant: Color(0xFFF0F0F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(const Color(0xFF1A1A1A)),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color defaultColor) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: defaultColor),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: defaultColor),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: defaultColor),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: defaultColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: defaultColor),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: defaultColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: defaultColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: defaultColor),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: defaultColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: defaultColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: defaultColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: defaultColor),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: defaultColor),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: defaultColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: defaultColor),
    );
  }
}
