import 'package:flutter/material.dart';

/// Named route constants for the entire app.
///
/// Always navigate using these constants — never string literals:
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.example);
/// ```
abstract final class AppRoutes {
  AppRoutes._();

  /// Splash / home — the first route loaded by [MaterialApp.initialRoute].
  static const String home = '/';

  /// Placeholder route used by the architecture reference feature.
  static const String example = '/example';
}

// ---------------------------------------------------------------------------
// Stub screens (replace with real feature screens as features are built)
// ---------------------------------------------------------------------------

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monster Livescore')),
      body: const Center(child: Text('Home — coming soon')),
    );
  }
}

class _ExampleScreen extends StatelessWidget {
  const _ExampleScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: const Center(child: Text('Example feature — coming soon')),
    );
  }
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

/// Centralised named-route map wired into [MaterialApp.routes].
///
/// Add new routes here as features are built. Follow the pattern:
/// 1. Add a constant to [AppRoutes].
/// 2. Add an entry to [AppRouter.routes].
/// 3. Point the entry at the feature's top-level screen widget.
///
/// For routes requiring arguments, use [MaterialApp.onGenerateRoute] instead
/// and document the expected argument type in a comment next to the case.
abstract final class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.home: (_) => const _HomeScreen(),
        AppRoutes.example: (_) => const _ExampleScreen(),
      };
}
