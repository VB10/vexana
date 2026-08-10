import 'package:vexana/vexana.dart';

class Post extends INetworkModel<Post> {
  const Post({this.id, this.title, this.body});

  final int? id;
  final String? title;
  final String? body;

  @override
  Post fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int?,
        title: json['title'] as String?,
        body: json['body'] as String?,
      );

  @override
  Map<String, dynamic>? toJson() => {'id': id, 'title': title, 'body': body};
}
