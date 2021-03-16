import 'package:vexana/src/interface/INetworkModel.dart';

class Todo extends INetworkModel<Todo> {
  int? userId;
  int? id;
  String? title;
  bool? completed;

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

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['userId'] = userId ?? '';
    data['id'] = id ?? '';
    data['title'] = title ?? '';
    ;
    data['completed'] = completed ?? '';
    ;
    return data;
  }

  @override
  Todo fromJson(Map<String, dynamic>? json) {
    return Todo.fromJson(json);
  }
}
