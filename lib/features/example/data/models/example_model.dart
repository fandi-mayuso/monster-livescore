import '../../domain/entities/example_entity.dart';

/// JSON-serialisable representation of [ExampleEntity].
///
/// Lives in the data layer only — never leak this type into domain or
/// presentation code. The repository impl returns [ExampleEntity] values,
/// not [ExampleModel] values.
class ExampleModel extends ExampleEntity {
  const ExampleModel({required super.id, required super.title});

  /// Deserialises an [ExampleModel] from a JSON map returned by the API.
  factory ExampleModel.fromJson(Map<String, dynamic> json) => ExampleModel(
        id: json['id'] as String,
        title: json['title'] as String,
      );

  /// Serialises this model to a JSON map (e.g., for caching).
  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}
