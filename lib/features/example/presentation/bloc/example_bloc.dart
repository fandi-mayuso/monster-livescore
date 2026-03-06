import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monster_livescore/core/error/failures.dart';
import 'package:monster_livescore/core/usecases/usecase.dart';
import 'package:monster_livescore/core/utils/app_logger.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/usecases/get_examples.dart';

part 'example_event.dart';
part 'example_state.dart';

/// BLoC for the example feature.
///
/// Accepts [ExampleStarted] and [ExampleRefreshed] events, both of which
/// trigger a fetch via [GetExamples] and emit the appropriate state.
///
/// Register as `registerFactory` in `injection_container.dart` so a fresh
/// instance is created for each route.
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  ExampleBloc({required GetExamples getExamples})
      : _getExamples = getExamples,
        super(const ExampleInitial()) {
    on<ExampleStarted>(_onFetch);
    on<ExampleRefreshed>(_onFetch);
  }

  final GetExamples _getExamples;

  Future<void> _onFetch(
    ExampleEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    final result = await _getExamples(const NoParams());

    if (result.failure != null) {
      logger.e(
        'ExampleBloc: fetch failed — ${result.failure!.message}',
      );
      emit(
        ExampleError(
          failure: result.failure!,
          userMessage: _toUserMessage(result.failure!),
        ),
      );
    } else {
      emit(ExampleLoaded(result.data ?? []));
    }
  }

  /// Maps a [Failure] to a friendly, displayable message.
  String _toUserMessage(Failure failure) => switch (failure) {
        ServerFailure() => 'Server error. Please try again later.',
        NetworkFailure() => 'No connection. Check your internet and retry.',
        CacheFailure() => 'Could not load cached data.',
        UnauthorisedFailure() => 'Session expired. Please log in again.',
        UnexpectedFailure() => 'Something went wrong. Please try again.',
      };
}
