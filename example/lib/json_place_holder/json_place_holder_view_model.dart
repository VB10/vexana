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
    networkManager =
        NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
  }

  Future<void> getAllPosts() async {
    changeLoading();
    final response = await networkManager.send<Post, List<Post>>('/posts', parseModel: Post(), method: RequestType.GET);

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
}
