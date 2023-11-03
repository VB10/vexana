import 'package:vexana/vexana.dart';

class Todo extends INetworkModel<Todo> {
  Todo({this.userId, this.id, this.title, this.completed});

  Todo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    userId = json['userId'] as int?;
    id = json['id'] as int?;
    title = json['title'] as String?;
    completed = json['completed'] as bool?;
  }
  int? userId;
  int? id;
  String? title;
  bool? completed;

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['userId'] = userId ?? '';
    data['id'] = id ?? '';
    data['title'] = title ?? '';
    data['completed'] = completed ?? '';
    return data;
  }

  @override
  Todo fromJson(Map<String, dynamic>? json) {
    return Todo.fromJson(json);
  }
}
