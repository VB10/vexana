import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';

import './json_place_holder.dart';
import 'model/post.dart';

abstract class JsonPlaceHolderViewModel extends State<JsonPlaceHolder> {
  List<Post> posts = [];

  INetworkManager networkManager;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    networkManager = NetworkManager<Post>(
      isEnableLogger: true,
      fileManager: LocalSembast(),

      noNetwork: NoNetwork(
        context,
        // customNoNetwork: (onRetry) {
        //   return NoNetworkSample(onPressed: onRetry);
        // },
      ),
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),

      // errorModelFromData: _errorModelFromData, //This is optional.
    );
  }

  Future<void> getAllPosts() async {
    changeLoading();
    final response = await networkManager.send<Post, List<Post>>('/posts',
        parseModel: Post(),
        method: RequestType.GET,
        isErrorDialog: true,
        expiration: const Duration(seconds: 1));

    if (response.data is List) {
      posts = response.data;
    }

    changeLoading();
  }

  void changeLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  //You can use this function for custom generate an error model.
  INetworkModel<Post> _errorModelFromData(Map<String, dynamic> data) {
    return Post.fromJson(data);
  }
}

class NoNetworkSample extends StatelessWidget {
  const NoNetworkSample({Key key, this.onPressed}) : super(key: key);
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
        )
      ],
    );
  }
}
