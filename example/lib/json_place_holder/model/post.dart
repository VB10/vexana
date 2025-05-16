import 'package:vexana/vexana.dart';

class Post extends INetworkModel<Post> {
  Post({this.userId, this.id, this.title, this.body});

  Post.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] as int?;
    id = json['id'] as int?;
    title = json['title'] as String?;
    body = json['body'] as String?;
  }
  int? userId;
  int? id;
  String? title;
  String? body;

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['id'] = id;
    data['title'] = title;
    data['body'] = body;
    return data;
  }

  @override
  Post fromJson(Map<String, dynamic> json) => Post.fromJson(json);
}
