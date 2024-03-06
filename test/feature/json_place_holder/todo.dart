import 'package:vexana/vexana.dart';

final class Todo extends INetworkModel<Todo> {
  const Todo({this.userId, this.id, this.title, this.completed});

  factory Todo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Todo();
    }

    return Todo(
      userId: json['userId'] as int?,
      id: json['id'] as int?,
      title: json['title'] as String?,
      completed: json['completed'] as bool?,
    );
  }
  final int? userId;
  final int? id;
  final String? title;
  final bool? completed;

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
