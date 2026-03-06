part of 'example_bloc.dart';

/// Base class for all states emitted by [ExampleBloc].
sealed class ExampleState extends Equatable {
  const ExampleState();
}

/// The BLoC has been created but no event has been dispatched yet.
final class ExampleInitial extends ExampleState {
  const ExampleInitial();

  @override
  List<Object?> get props => [];
}

/// A fetch is in progress — show a loading indicator.
final class ExampleLoading extends ExampleState {
  const ExampleLoading();

  @override
  List<Object?> get props => [];
}

/// Fetch succeeded — [items] contains the result list.
final class ExampleLoaded extends ExampleState {
  const ExampleLoaded(this.items);

  final List<ExampleEntity> items;

  @override
  List<Object?> get props => [items];
}

/// Fetch failed — show [userMessage] to the user; log [failure] internally.
final class ExampleError extends ExampleState {
  const ExampleError({required this.failure, required this.userMessage});

  /// The domain-level failure (for logging and debugging).
  final Failure failure;

  /// A friendly message safe to display in the UI.
  final String userMessage;

  @override
  List<Object?> get props => [failure, userMessage];
}
