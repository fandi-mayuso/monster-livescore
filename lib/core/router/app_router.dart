import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monster_livescore/injection_container.dart';
import '../../features/example/presentation/bloc/example_bloc.dart';
import '../../features/example/presentation/pages/example_page.dart';

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
      body: Center(
        child: TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.example),
          child: const Text('Open Example Feature →'),
        ),
      ),
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

  /// Route map wired into [MaterialApp.routes].
  ///
  /// Keys are [AppRoutes] constants; values are [WidgetBuilder]s that
  /// wrap the target page in any required [BlocProvider]s.
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.home: (_) => const _HomeScreen(),
        AppRoutes.example: (_) => BlocProvider(
              create: (_) =>
                  sl<ExampleBloc>()..add(const ExampleStarted()),
              child: const ExamplePage(),
            ),
      };
}
