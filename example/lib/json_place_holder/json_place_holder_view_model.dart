import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';

import './json_place_holder.dart';
import 'model/post.dart';

abstract class JsonPlaceHolderViewModel extends State<JsonPlaceHolder> {
  List<Post> posts = [];

  late INetworkManager<Post, String> networkManager;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    networkManager = NetworkManager<Post, String>(
      isEnableLogger: true,
      // fileManager: LocalSembast(),
      onRefreshToken: (error, newService) {
        final param = newService.parameters.customParameter;
        print(param);
        return Future.value(error);
      },
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
    final response = await networkManager.send<Post, List<Post>, String>(
      '/posts',
      parseModel: Post(),
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

  //You can use this function for custom generate an error model.
  INetworkModel<Post> _errorModelFromData(Map<String, dynamic> data) {
    return Post.fromJson(data);
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
