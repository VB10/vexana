import 'package:vexana/vexana.dart';

class Post extends INetworkModel<Post> {
  const Post({this.userId, this.id, this.title, this.body});

  Post.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] is int ? json['userId'] as int : null,
        id = json['id'] is int ? json['id'] as int : null,
        title = json['title'] is String ? json['title'] as String : null,
        body = json['body'] is String ? json['body'] as String : null;
  final int? userId;
  final int? id;
  final String? title;
  final String? body;

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
