part of 'example_bloc.dart';

/// Base class for all events dispatched to [ExampleBloc].
sealed class ExampleEvent extends Equatable {
  const ExampleEvent();
}

/// Dispatched when the example screen is first loaded.
final class ExampleStarted extends ExampleEvent {
  const ExampleStarted();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user taps the Retry button after an error.
final class ExampleRefreshed extends ExampleEvent {
  const ExampleRefreshed();

  @override
  List<Object?> get props => [];
}
