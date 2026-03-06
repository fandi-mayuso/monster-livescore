import 'package:equatable/equatable.dart';

/// Reference domain entity demonstrating the architecture pattern.
///
/// Rules:
/// - No Flutter, Dio, or data-layer imports — pure Dart only.
/// - Extend [Equatable] and override [props] for value equality.
/// - All fields are final; use `const` constructors.
class ExampleEntity extends Equatable {
  /// Unique identifier for this item (matches the API `id` field).
  final String id;

  /// Human-readable display name for this item.
  final String title;

  const ExampleEntity({required this.id, required this.title});

  @override
  List<Object?> get props => [id, title];
}
