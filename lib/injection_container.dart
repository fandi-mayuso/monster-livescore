import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monster_livescore/core/config/flavor_config.dart';
import 'package:monster_livescore/core/network/api_client.dart';
import 'package:monster_livescore/core/utils/app_logger.dart';

/// Global service locator instance.
///
/// Use `sl<T>()` to retrieve any registered dependency throughout the app.
/// Never construct dependencies manually outside of this file.
final GetIt sl = GetIt.instance;

/// Initialises all dependencies and registers them with [sl].
///
/// Call this once at app startup **before** [runApp], after
/// [WidgetsFlutterBinding.ensureInitialized] and [FlavorConfig.setFlavor].
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await FlavorConfig.setFlavor(Flavor.dev);
///   await initDependencies();
///   runApp(const MyApp());
/// }
/// ```
Future<void> initDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  sl.registerLazySingleton<AppLogger>(() => AppLogger.instance);

  sl.registerLazySingleton<Dio>(
    () => createDio(FlavorConfig.instance, sl<SharedPreferences>()),
  );

  // ── Feature registrations go below this line ──────────────────────────────
  // Follow the bottom-up order: DataSources → Repositories → UseCases → BLoCs
  //
  // Example:
  // sl.registerLazySingleton<ExampleRemoteDatasource>(
  //   () => ExampleRemoteDatasourceImpl(dio: sl()),
  // );
  // sl.registerLazySingleton<ExampleRepository>(
  //   () => ExampleRepositoryImpl(remote: sl()),
  // );
  // sl.registerLazySingleton(() => GetExamples(repository: sl()));
  // sl.registerFactory(() => ExampleBloc(getExamples: sl()));
}
