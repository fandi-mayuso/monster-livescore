import 'package:monster_livescore/core/error/exceptions.dart';
import 'package:monster_livescore/core/error/failures.dart';
import 'package:monster_livescore/core/utils/typedef.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_remote_datasource.dart';

/// Concrete implementation of [ExampleRepository].
///
/// Catches typed [Exception]s from the datasource and maps them to [Failure]
/// subtypes before returning them to the domain layer.
///
/// Exception → Failure mapping:
/// - [ServerException]       → [ServerFailure]
/// - [NetworkException]      → [NetworkFailure]
/// - [UnauthorisedException] → [UnauthorisedFailure]
/// - any other               → [UnexpectedFailure]
class ExampleRepositoryImpl implements ExampleRepository {
  const ExampleRepositoryImpl({required ExampleRemoteDatasource remote})
      : _remote = remote;

  final ExampleRemoteDatasource _remote;

  @override
  ResultFuture<List<ExampleEntity>> getExamples() async {
    try {
      final models = await _remote.fetchExamples();
      return (data: List<ExampleEntity>.from(models), failure: null);
    } on ServerException catch (e) {
      return (
        data: null,
        failure: ServerFailure(message: e.message),
      );
    } on NetworkException catch (e) {
      return (
        data: null,
        failure: NetworkFailure(message: e.message),
      );
    } on UnauthorisedException catch (e) {
      return (
        data: null,
        failure: UnauthorisedFailure(message: e.message),
      );
    } catch (e) {
      return (
        data: null,
        failure: UnexpectedFailure(message: e.toString()),
      );
    }
  }
}
