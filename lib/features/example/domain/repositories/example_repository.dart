import 'package:monster_livescore/core/utils/typedef.dart';
import '../entities/example_entity.dart';

/// Contract for the example feature's data access.
///
/// The domain layer depends on this abstract class only — never on the
/// concrete implementation in `data/`. Dependency inversion is wired
/// through `injection_container.dart`.
abstract class ExampleRepository {
  /// Returns a list of example items or a [Failure] on error.
  ResultFuture<List<ExampleEntity>> getExamples();
}
