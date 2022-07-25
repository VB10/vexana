import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';

import './json_place_holder.dart';
import 'model/post.dart';

abstract class JsonPlaceHolderViewModel extends State<JsonPlaceHolder> {
  List<Post> posts = [];

  late INetworkManager networkManager;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    networkManager = NetworkManager(
      isEnableLogger: true,
      noNetwork: NoNetwork(
        context,
        // customNoNetwork: (onRetry) {
        //   return NoNetworkSample(onPressed: onRetry);
        // },
      ),
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),

      errorModelFromData: _errorModelFromData, //This is optional.
    );
  }

  Future<void> getAllPosts() async {
    changeLoading();

    final response = await networkManager.send<Post, List<Post>>('/posts',
        parseModel: Post(), method: RequestType.GET, isErrorDialog: true);

    if (response.data is List) {
      posts = response.data!;
    }

    changeLoading();
  }

  void changeLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  //You can use this function for custom generate an error model.
  INetworkModel _errorModelFromData(dynamic data) {
    if (data is Map<String, dynamic> || data is String) {
      final map =
          data is String ? jsonDecode(data) : data as Map<String, dynamic>;
      return Post.fromJson(map);
    }

    return Post(id: -1, userId: -1, title: 'Error!', body: 'Unexpected data');
  }
}

class NoNetworkSample extends StatelessWidget {
  const NoNetworkSample({Key? key, required this.onPressed}) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('sample'),
        TextButton(
          onPressed: () {
            onPressed.call();
            Navigator.of(context).pop();
          },
          child: Text('Retry'),
        )
      ],
    );
  }
}
