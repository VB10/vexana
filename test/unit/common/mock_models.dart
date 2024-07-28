// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:vexana/vexana.dart';

final class MockModels {
  MockModels._();

  /// https://jsonplaceholder.typicode.com/posts
  static const posts = [
    {
      'userId': 1,
      'id': 1,
      'title':
          'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
      'body':
          'quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto',
    },
    {
      'userId': 1,
      'id': 2,
      'title': 'qui est esse',
      'body':
          'est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla',
    }
  ];

  static const post = {
    'userId': 1,
    'id': 1,
    'title':
        'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
    'body':
        'quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto',
  };

  static const emptyModel = {'name': 'test'};
}

class Post extends INetworkModel<Post> {
  final int? userId;
  final int? id;
  final String? title;
  final String? body;

  const Post({
    this.userId,
    this.id,
    this.title,
    this.body,
  });

  @override
  Post fromJson(Map<String, dynamic> json) {
    return Post.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson() {
    return toMap();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      userId: map['userId'] as int,
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
    );
  }
}

class PostFormData extends INetworkModel<Post> with IFormDataModel<Post> {
  @override
  Post fromJson(Map<String, dynamic> json) {
    return Post.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson() {
    return {};
  }
}
