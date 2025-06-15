import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';

import './json_place_holder.dart';
import 'model/post.dart';

abstract class JsonPlaceHolderViewModel extends State<JsonPlaceHolder> {
  List<Post> posts = [];

  late INetworkManager<Post> networkManager;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    networkManager = NetworkManager<Post>(
      isEnableLogger: true,
      // fileManager: LocalSembast(),
      isEnableTest: true,
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
    final response = await networkManager.send<Post, List<Post>>(
      '/posts',
      parseModel: const Post(),
      method: RequestType.GET,
      isErrorDialog: true,
    );

    if (response.data is List) {
      posts = response.data ?? [];
    }

    changeLoading();
  }

  void changeLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }
}

class NoNetworkSample extends StatelessWidget {
  const NoNetworkSample({super.key, this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('sample'),
        TextButton(
          onPressed: () {
            onPressed?.call();
            Navigator.of(context).pop();
          },
          child: const Text('data'),
        ),
      ],
    );
  }
}
