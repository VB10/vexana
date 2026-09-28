// Live playground: https://vb10.github.io/vexana/
import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';

void main() => runApp(const MaterialApp(home: PostsView()));

/// A response model: vexana parses JSON into it through [fromJson].
final class Post extends INetworkModel<Post> {
  /// Creates a post; every field is optional because the API may omit any.
  const Post({this.id, this.title});

  /// Reads a post from a decoded JSON object.
  factory Post.fromMap(Map<String, dynamic> json) =>
      Post(id: json['id'] as int?, title: json['title'] as String?);

  /// The post id.
  final int? id;

  /// The post title.
  final String? title;

  @override
  Post fromJson(Map<String, dynamic> json) => Post.fromMap(json);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}

/// The app's single network manager. `EmptyModel` means the API has no
/// error body to parse.
final INetworkManager<EmptyModel> networkManager = NetworkManager<EmptyModel>(
  options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
  fileManager: LocalPreferences(),
);

/// Lists the posts, or the error the request returned.
class PostsView extends StatefulWidget {
  /// Creates the posts screen.
  const PostsView({super.key});

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView> {
  late Future<NetworkResult<List<Post>, EmptyModel>> _posts = _fetch();

  Future<NetworkResult<List<Post>, EmptyModel>> _fetch() =>
      networkManager.sendRequest<Post, List<Post>>(
        '/posts',
        parseModel: const Post(),
        method: RequestType.GET,
        expiration: const Duration(minutes: 1),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('vexana')),
      body: FutureBuilder(
        future: _posts,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return switch (result) {
            NetworkSuccessResult(:final data) => RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _posts = _fetch();
                  });
                  await _posts;
                },
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(data[index].title ?? '')),
                ),
              ),
            NetworkErrorResult(:final error) => Center(
                child: Text('Error ${error.statusCode}: ${error.description}'),
              ),
          };
        },
      ),
    );
  }
}
