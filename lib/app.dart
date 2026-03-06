import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/flavor_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Register global BLoC providers here.
        // Feature-scoped BLoCs should be provided closer to the widget that needs them.
      ],
      child: MaterialApp(
        title: FlavorConfig.instance.appName,
        theme: AppTheme.dark(),
        initialRoute: AppRoutes.home,
        routes: AppRouter.routes,
        debugShowCheckedModeBanner: FlavorConfig.instance.enableLogging,
      ),
    );
  }
}
