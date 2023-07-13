/// The `LocalModel` class is a Dart class that represents a model with a time and model name, and
/// provides methods for converting to and from JSON.
class LocalModel {
  LocalModel({this.time, this.model});

  LocalModel.fromJson(Map<String, dynamic> json) {
    time = json['time'] is String ? DateTime.parse(json['time'] as String) : null;
    model = json['model'] is String ? json['model'] as String : '';
  }
  DateTime? time;
  String? model;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time.toString();
    data['model'] = model;
    return data;
  }
}
