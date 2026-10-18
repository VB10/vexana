import 'package:equatable/equatable.dart';

/// The `LocalModel` class is a Dart class that represents a
/// model with a time and model name, and
/// provides methods for converting to and from JSON.
final class LocalModel extends Equatable {
  /// The `LocalModel` constructor is used to create a new `LocalModel`
  const LocalModel({this.time, this.model});

  /// The `fromJson` method is used to convert a JSON object to a `LocalModel`.
  factory LocalModel.fromJson(Map<String, dynamic> json) {
    return LocalModel(
      time: DateTime.parse(json['time'] as String),
      model: json['model'] as String?,
    );
  }

  /// [time] for caching data time
  final DateTime? time;

  /// [model] for caching data model
  final String? model;

  /// The `toJson` method is used to convert a `LocalModel` to JSON.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time.toString();
    data['model'] = model;
    return data;
  }

  @override
  List<Object?> get props => [time, model];
}
