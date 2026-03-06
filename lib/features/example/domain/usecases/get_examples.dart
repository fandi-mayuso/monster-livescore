import 'package:monster_livescore/core/usecases/usecase.dart';
import 'package:monster_livescore/core/utils/typedef.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

/// Fetches the list of example items from the repository.
///
/// Use [NoParams] when calling — no input is required:
/// ```dart
/// final result = await getExamples(const NoParams());
/// ```
class GetExamples implements UseCase<List<ExampleEntity>, NoParams> {
  const GetExamples(this._repository);

  final ExampleRepository _repository;

  @override
  ResultFuture<List<ExampleEntity>> call(NoParams params) =>
      _repository.getExamples();
}
