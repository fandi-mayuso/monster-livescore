# Tasks: Flutter Project Architecture Setup

**Input**: Design documents from `specs/001-flutter-architecture/`  
**Branch**: `001-flutter-architecture`  
**Date**: 2026-03-06  
**Stack**: Dart 3 / Flutter SDK ^3.11.1 · flutter_bloc · get_it · equatable · Dio · shared_preferences · logger

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Exact file paths are included in every task description

---

## Phase 1: Setup

**Purpose**: Update dependencies and create the full directory scaffold before any code is written.

- [ ] T001 Update `pubspec.yaml`: add `flutter_bloc: ^8.1.0`, `equatable: ^2.0.5`, `get_it: ^7.6.0` to dependencies; add `bloc_test: ^9.1.0`, `mockito: ^5.4.0`, `build_runner: ^2.4.0` to dev_dependencies; remove `provider`
- [ ] T002 Run `flutter pub get` to install updated dependencies and confirm no resolution errors
- [ ] T003 [P] Create source directory scaffold: `lib/core/{config,constants,error,network/interceptors,theme,router,usecases,utils}`, `lib/shared/{domain/{entities,repositories,usecases},data/{models,datasources,repositories}}`, `lib/features/` (empty, ready for feature modules)
- [ ] T004 [P] Create test directory scaffold: `test/unit/{core,shared/{domain,data},features/example/{bloc,domain,data}}`, `test/widget/features/example/`, `test/integration/features/example/`

**Checkpoint**: Dependencies installed, all directories exist — no implementation yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before any user story work begins. These files are imported by everything else.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T005 Move `lib/config/flavor_config.dart` → `lib/core/config/flavor_config.dart`; update import in `lib/app.dart` and all `lib/main/*.dart` files accordingly
- [ ] T006 [P] Move `lib/constants/app_constants.dart` → `lib/core/constants/app_constants.dart`; update any imports that reference the old path
- [ ] T007 Create `lib/core/error/exceptions.dart` with five typed exception classes: `ServerException(statusCode, message)`, `CacheException(message)`, `NetworkException(message)`, `UnauthorisedException(message)`, `ValidationException(message)` — all extending `Exception`
- [ ] T008 Create `lib/core/error/failures.dart` with `sealed class Failure { final String message; }` and five subtypes: `ServerFailure`, `NetworkFailure`, `CacheFailure`, `UnauthorisedFailure`, `UnexpectedFailure` — all extending `Failure` with `const` constructors
- [ ] T009 Create `lib/core/usecases/usecase.dart` with `abstract class UseCase<Type, Params>` defining `Future<({Type? data, Failure? failure})> call(Params params)`, plus `class NoParams {}` sentinel
- [ ] T010 Create `lib/core/utils/app_logger.dart` wrapping the `logger` package: expose a singleton `AppLogger.instance` with `d()`, `i()`, `w()`, `e()` methods; log level driven by `FlavorConfig.instance.logLevel`
- [ ] T011 Replace all `print()` calls in `lib/core/config/flavor_config.dart` (`_logConfiguration` method) with `AppLogger.instance.d()`
- [ ] T012 [P] Create `lib/core/utils/typedef.dart` with shared type alias: `typedef ResultFuture<T> = Future<({T? data, Failure? failure})>;`
- [ ] T013 Create `lib/core/network/interceptors/logging_interceptor.dart`: `LoggingInterceptor extends Interceptor` — logs request method + URL on `onRequest`; logs status code + duration on `onResponse`; logs error on `onError`; uses `AppLogger`; only active when `FlavorConfig.instance.enableLogging` is true
- [ ] T014 [P] Create `lib/core/network/interceptors/auth_interceptor.dart`: `AuthInterceptor extends Interceptor` — injects `Authorization` header on `onRequest` (reads token from SharedPreferences key `auth_token`; skips if absent)
- [ ] T015 [P] Create `lib/core/network/interceptors/retry_interceptor.dart`: `RetryInterceptor extends Interceptor` — retries on `DioExceptionType.connectionTimeout` and `receiveTimeout` up to 3 times with 1s/2s/4s exponential backoff; throws `NetworkException` after final failure
- [ ] T016 Create `lib/core/network/api_client.dart`: factory function `createDio(FlavorConfig config)` returning a `Dio` instance with `baseUrl` from `config.apiBaseUrl`, `connectTimeout: 30s`, `receiveTimeout: 30s`, and all three interceptors added in order: `LoggingInterceptor`, `AuthInterceptor`, `RetryInterceptor`
- [ ] T017 Create `lib/injection_container.dart`: initialise `GetIt sl = GetIt.instance`; register `SharedPreferences` as lazy singleton (async via `await SharedPreferences.getInstance()`); register `Dio` (via `createDio`) as lazy singleton; register `AppLogger.instance` as lazy singleton
- [ ] T018 Update all three `lib/main/main_*.dart` files to call `WidgetsFlutterBinding.ensureInitialized()` and `await initDependencies()` (a top-level async function in `injection_container.dart`) before `runApp()`

**Checkpoint**: Core infrastructure is wired — errors, logging, networking, and DI are ready. User story work can now begin.

---

## Phase 3: User Story 1 — Onboard a New Team Member (Priority: P1) 🎯 MVP

**Goal**: A new developer can open the project and immediately understand where every type of code lives — without asking anyone.

**Independent Test**: Open the project cold and answer "where does a new league screen go?" and "where does an API call go?" correctly within 5 minutes by reading the folder structure and `ARCHITECTURE.md` alone.

- [ ] T019 [P] [US1] Create `lib/core/theme/app_colors.dart`: define all colour tokens as `static const Color` values (primary, secondary, background, surface, error, onPrimary, etc.) — no `Colors.*` literals used anywhere else
- [ ] T020 [P] [US1] Create `lib/core/theme/app_text_styles.dart`: define typography scale as `static const TextStyle` values (headlineLarge, headlineMedium, bodyLarge, bodyMedium, labelLarge, etc.)
- [ ] T021 [US1] Create `lib/core/theme/app_theme.dart`: `AppTheme.light()` factory returning `ThemeData` built entirely from `AppColors` and `AppTextStyles` tokens — no hardcoded colours or font sizes inside
- [ ] T022 [US1] Create `lib/core/router/app_router.dart`: define `class AppRoutes` with `static const String` route name constants; define `AppRouter.routes` map of `String → WidgetBuilder`; include a `/` home route and a `/example` route as stubs
- [ ] T023 [US1] Update `lib/app.dart`: replace `ThemeData(primarySwatch: Colors.blue)` with `AppTheme.light()`; replace inline `home:` with `initialRoute: AppRoutes.home` and `routes: AppRouter.routes`; wrap with `MultiBlocProvider(providers: [], child: ...)` scaffold ready for future BLoCs
- [ ] T024 [US1] Create `ARCHITECTURE.md` at repository root documenting: the four top-level directories (`core/`, `shared/`, `features/`, `main/`) and their rules; the dependency direction diagram; the feature-first folder template; the promotion rule for shared entities; the BLoC event/state/bloc three-file pattern; naming conventions (snake_case files, PascalCase classes, `_bloc`, `_event`, `_state`, `_repository`, `_datasource`, `_model` suffixes)

**Checkpoint ✅ US1 Done**: New developer can read `ARCHITECTURE.md` and the folder tree and correctly place any type of code. Theme and router are centralised with zero hardcoded values.

---

## Phase 4: User Story 2 — Add a New Feature Without Breaking Existing Ones (Priority: P2)

**Goal**: A complete, runnable reference feature (`example`) demonstrates exactly how to add a new feature — every layer in place, wired through DI, with no coupling to anything outside its own folder.

**Independent Test**: Delete `lib/features/example/` entirely and confirm the app still compiles and runs. Then re-create it from the template and confirm it compiles again with zero changes to any file outside `lib/features/example/` and `lib/injection_container.dart`.

- [ ] T025 [US2] Create `lib/features/example/domain/entities/example_entity.dart`: `class ExampleEntity extends Equatable` with `id: String` and `title: String` fields, `const` constructor, `props` override — no Flutter/Dio imports
- [ ] T026 [P] [US2] Create `lib/features/example/domain/repositories/example_repository.dart`: `abstract class ExampleRepository` with `ResultFuture<List<ExampleEntity>> getExamples()` — imports only `core/error/failures.dart`, `core/utils/typedef.dart`, and the entity
- [ ] T027 [P] [US2] Create `lib/features/example/domain/usecases/get_examples.dart`: `class GetExamples implements UseCase<List<ExampleEntity>, NoParams>` — calls `_repository.getExamples()` and returns the result unchanged
- [ ] T028 [US2] Create `lib/features/example/data/models/example_model.dart`: `class ExampleModel extends ExampleEntity` with `factory ExampleModel.fromJson(Map<String, dynamic> json)` and `Map<String, dynamic> toJson()` — `dart:convert` only
- [ ] T029 [P] [US2] Create `lib/features/example/data/datasources/example_remote_datasource.dart`: abstract `ExampleRemoteDatasource` with `Future<List<ExampleModel>> fetchExamples()`; `ExampleRemoteDatasourceImpl` using injected `Dio`, throws `ServerException` on non-2xx, `NetworkException` on timeout
- [ ] T030 [US2] Create `lib/features/example/data/repositories/example_repository_impl.dart`: `ExampleRepositoryImpl implements ExampleRepository` — calls remote datasource, catches `ServerException` → `ServerFailure`, `NetworkException` → `NetworkFailure`, any other → `UnexpectedFailure`
- [ ] T031 [US2] Create `lib/features/example/presentation/bloc/example_event.dart`: `sealed class ExampleEvent extends Equatable` with `final class ExampleStarted` and `final class ExampleRefreshed` — `const` constructors, `props: []`
- [ ] T032 [P] [US2] Create `lib/features/example/presentation/bloc/example_state.dart`: `sealed class ExampleState extends Equatable` with four subtypes: `ExampleInitial`, `ExampleLoading`, `ExampleLoaded(List<ExampleEntity> items)`, `ExampleError(Failure failure, String userMessage)` — all `const`, all `Equatable`
- [ ] T033 [US2] Create `lib/features/example/presentation/bloc/example_bloc.dart`: `ExampleBloc extends Bloc<ExampleEvent, ExampleState>` — constructor receives `GetExamples getExamples`; registers `on<ExampleStarted>` and `on<ExampleRefreshed>` both mapping to the same private handler; handler emits `ExampleLoading` → calls use case → emits `ExampleLoaded` or `ExampleError`
- [ ] T034 [US2] Create `lib/features/example/presentation/pages/example_page.dart`: `BlocBuilder<ExampleBloc, ExampleState>` using exhaustive `switch` on sealed state — `ExampleInitial`: empty `SizedBox`; `ExampleLoading`: `CircularProgressIndicator`; `ExampleLoaded`: `ListView.builder` with item count; `ExampleError`: error message text + `TextButton('Retry', ...)` dispatching `ExampleRefreshed`
- [ ] T035 [US2] Register example feature in `lib/injection_container.dart` (bottom-up order): `ExampleRemoteDatasource` → `ExampleRepository` → `GetExamples` → `ExampleBloc` (as `registerFactory`)
- [ ] T036 [US2] Add `/example` route to `lib/core/router/app_router.dart` pointing to `ExamplePage` wrapped in `BlocProvider(create: (_) => sl<ExampleBloc>()..add(const ExampleStarted()))`

**Checkpoint ✅ US2 Done**: The example feature compiles, runs end-to-end (with network errors handled), and can be deleted/restored with zero impact outside its own folder + DI registration.

---

## Phase 5: User Story 3 — Debug a Bug Efficiently (Priority: P3)

**Goal**: Every layer boundary is explicit and traceable. A developer can follow a bug from the UI error state, through the BLoC, through the use case, to the exact repository method and datasource call that failed — in under 10 minutes.

**Independent Test**: Simulate a 500 API error from the example datasource. Confirm: (1) `LoggingInterceptor` logs the failure, (2) `ExampleRepositoryImpl` maps it to `ServerFailure`, (3) `ExampleBloc` emits `ExampleError`, (4) `ExamplePage` shows a user-readable message and retry button.

- [ ] T037 [US3] Verify the complete error flow in `lib/features/example/`: introduce a deliberate `throw ServerException(statusCode: 500, message: 'test')` in `ExampleRemoteDatasourceImpl.fetchExamples()`; run the app; confirm the chain — interceptor logs it → repository maps to `ServerFailure` → BLoC emits `ExampleError` → page renders error message; then remove the deliberate throw
- [ ] T038 [US3] Update `lib/core/network/interceptors/logging_interceptor.dart` to log the full chain: outgoing request (URL, method, headers in dev), incoming response (status, duration in ms), and errors (type, message, status code) — all via `AppLogger` at appropriate levels (`d` for requests, `i` for responses, `e` for errors)
- [ ] T039 [US3] Update `lib/core/network/interceptors/retry_interceptor.dart` to log each retry attempt with attempt number and delay via `AppLogger.instance.w()`; ensure the final failure after max retries emits a `NetworkException` with a message stating "Max retries exceeded"
- [ ] T040 [US3] Update `lib/features/example/presentation/pages/example_page.dart`: in the `ExampleError` branch, display `state.userMessage` in a visible `Text` widget; add `AppLogger.instance.e(state.failure.message)` call in the BLoC's error handler in `example_bloc.dart` so the technical failure is always logged even if the UI shows a friendlier message
- [ ] T041 [US3] Add `lib/core/utils/typedef.dart` documentation: add inline comments mapping each type alias to its usage pattern so a developer reading any repository can immediately understand the return type contract without consulting external docs

**Checkpoint ✅ US3 Done**: The entire request → error → UI path is logged and traceable. Any error is catchable at exactly one layer boundary. No silent failures exist.

---

## Phase 6: User Story 4 — Consistent Code Style Across the Team (Priority: P4)

**Goal**: Every file follows identical patterns. A developer authoring a second feature produces the same structure as the example without any guidance.

**Independent Test**: Two developers independently duplicate the example feature folder (renaming it), run `flutter analyze`, and get zero errors or warnings. Their resulting file structures and class names are identical in pattern.

- [ ] T042 [US4] Update `analysis_options.yaml` to add: `avoid_print: true`, `prefer_const_constructors: true`, `prefer_const_declarations: true`, `require_trailing_commas: true`, `sort_pub_dependencies: true`; run `flutter analyze` and fix any violations introduced in earlier tasks
- [ ] T043 [P] [US4] Add `///` doc comments to every public class and method in `lib/core/`: `UseCase`, `NoParams`, all `Failure` subtypes, all `Exception` subtypes, `AppLogger`, `ApiClient`, `AppTheme`, `AppColors`, `AppTextStyles`, `AppRouter`, `AppRoutes`
- [ ] T044 [P] [US4] Add `///` doc comments to every public class and method in `lib/features/example/`: `ExampleEntity`, `ExampleRepository`, `GetExamples`, `ExampleModel`, `ExampleRemoteDatasource`, `ExampleRepositoryImpl`, all BLoC events, all BLoC states, `ExampleBloc`, `ExamplePage`
- [ ] T045 [US4] Update `lib/core/constants/app_constants.dart`: add `static const Duration apiConnectTimeout = Duration(seconds: 30)` and `static const Duration apiReceiveTimeout = Duration(seconds: 30)`; replace the inline `Duration(seconds: 30)` literals in `api_client.dart` with these constants
- [ ] T046 [US4] Update `ARCHITECTURE.md` with a **Naming Conventions** section: file names (snake_case, suffixed by role: `_bloc`, `_event`, `_state`, `_repository`, `_datasource`, `_model`, `_entity`, `_page`, `_widget`); class names (PascalCase matching file name); no abbreviations in public names; event/state sealed classes use `final class` keyword (Dart 3)

**Checkpoint ✅ US4 Done**: `flutter analyze` passes with zero issues. Every file has doc comments. Naming conventions are enforced by linter and documented for new developers.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Validate the whole architecture end-to-end and confirm all success criteria from the spec are met.

- [ ] T047 Run `flutter analyze` — confirm zero errors and zero warnings across the entire project
- [ ] T048 [P] Run `flutter test --coverage` — confirm all tests pass; record baseline coverage percentage; document in `ARCHITECTURE.md` under a **Testing** section
- [ ] T049 [P] Validate `specs/001-flutter-architecture/quickstart.md` against the actual implemented file paths — fix any path discrepancies between the guide and real directory names
- [ ] T050 Manually walk the `quickstart.md` Step 1–10 guide using a second feature name (e.g., `lib/features/standings/`) to confirm the guide produces a compiling feature with zero changes to the example feature

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **BLOCKS all user stories**
- **Phase 3 (US1)**: Depends on Phase 2 — can start as soon as foundational is complete
- **Phase 4 (US2)**: Depends on Phase 2 — can run in parallel with Phase 3 if team allows (US2 doesn't depend on US1's theme/router)
- **Phase 5 (US3)**: Depends on Phase 4 (needs the example feature to trace through)
- **Phase 6 (US4)**: Depends on Phases 3, 4, 5 — runs last (lints the completed codebase)
- **Final Phase**: Depends on all user story phases

### Within Each Phase

```
Phase 2: T005, T006 (parallel) → T007, T008, T009, T010, T011, T012 (parallel group) → T013, T014, T015 (parallel) → T016 → T017 → T018

Phase 3: T019, T020 (parallel) → T021 → T022 → T023 → T024

Phase 4: T025 → T026, T027 (parallel) → T028 → T029 → T030 → T031 → T032 (parallel) → T033 → T034 → T035 → T036

Phase 5: T037 → T038, T039 (parallel) → T040 → T041

Phase 6: T042 → T043, T044 (parallel) → T045 → T046
```

---

## Parallel Execution Examples

### Phase 2 — Parallel group (once T009 + T010 done)

```
Parallel: T013 (LoggingInterceptor) + T014 (AuthInterceptor) + T015 (RetryInterceptor)
Then:     T016 (ApiClient wires all three)
```

### Phase 3 — Parallel group

```
Parallel: T019 (AppColors) + T020 (AppTextStyles)
Then:     T021 (AppTheme consumes both)
```

### Phase 4 — Parallel group

```
Parallel: T026 (Repository interface) + T027 (UseCase)
Then:     T030 (RepositoryImpl needs both)

Parallel: T031 (Events) + T032 (States)
Then:     T033 (BLoC needs both)
```

### Phase 6 — Parallel group

```
Parallel: T043 (doc comments core/) + T044 (doc comments features/example/)
Then:     T047 flutter analyze (validates both)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (**critical blocker**)
3. Complete Phase 3: User Story 1 (readable structure + ARCHITECTURE.md)
4. **STOP and VALIDATE**: Can a new developer navigate the project in 5 minutes?
5. The project is now structurally sound — feature development can begin on any product feature

### Incremental Delivery

1. Setup + Foundational → infrastructure ready
2. + US1 (Phase 3) → readable, documented structure → **MVP: new developer can be onboarded**
3. + US2 (Phase 4) → reference example feature → **team has a copy-paste template**
4. + US3 (Phase 5) → full error traceability → **debugging is predictable**
5. + US4 (Phase 6) → linting + docs → **code reviews are structural-comment-free**

### Parallel Team Strategy

```
Phase 1+2: All developers together (shared infrastructure)
Phase 3+4: Developer A → US1 theme/router/docs
           Developer B → US2 example feature layers
Phase 5:   Developer B continues (error flow, depends on US2)
           Developer A continues (ARCHITECTURE.md polish)
Phase 6:   Any developer (linting pass on completed codebase)
```

---

## Notes

- `[P]` tasks touch different files with no shared write dependencies — safe to run simultaneously
- `[Story]` label maps each task to a specific user story for traceability in code review
- Every user story phase ends with an independent testable checkpoint — stop and validate before moving to the next phase
- Commit after each checkpoint (end of each phase) at minimum; atomic commits per task are better
- `flutter analyze` must pass with zero issues at every checkpoint — do not accumulate linting debt
- The `example` feature (Phase 4) is a **reference template only** — it should use a stub API endpoint and placeholder data; it is not a real product feature
