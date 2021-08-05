import 'package:example/json_place_holder/custom_http_client_adapter.dart';
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
    networkManager = NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));

    //for example: you can add your custom http client adapter when initializing manager
    //networkManager = NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'), customHttpClientAdapter: CustomHttpClientAdapter());
  }

  Future<void> getAllPosts() async {
    changeLoading();
    final response = await networkManager.send<Post, List<Post>>('/posts', parseModel: Post(), method: RequestType.GET);

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
}
