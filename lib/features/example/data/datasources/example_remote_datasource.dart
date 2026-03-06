import 'package:dio/dio.dart';
import 'package:monster_livescore/core/error/exceptions.dart';
import '../models/example_model.dart';

/// Contract for the example feature's remote data access.
///
/// Throws typed [Exception]s — never [Failure]s (that conversion happens
/// in the repository implementation).
abstract class ExampleRemoteDatasource {
  /// Fetches example items from the remote API.
  ///
  /// Throws [ServerException] on non-2xx responses.
  /// Throws [NetworkException] on connectivity or timeout errors.
  Future<List<ExampleModel>> fetchExamples();
}

/// Production implementation backed by [Dio].
class ExampleRemoteDatasourceImpl implements ExampleRemoteDatasource {
  const ExampleRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<ExampleModel>> fetchExamples() async {
    try {
      final response = await _dio.get<List<dynamic>>('/examples');

      if (response.statusCode != null && response.statusCode! ~/ 100 == 2) {
        final data = response.data ?? [];
        return data
            .cast<Map<String, dynamic>>()
            .map(ExampleModel.fromJson)
            .toList();
      }

      throw ServerException(
        statusCode: response.statusCode ?? 0,
        message: 'Unexpected status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          message: e.message ?? 'Network error',
        );
      }
      throw ServerException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Server error',
      );
    }
  }
}
