import 'package:example/json_place_holder/custom_http_client_adapter.dart';
import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';

import './json_place_holder.dart';
import 'model/post.dart';

abstract class JsonPlaceHolderViewModel extends State<JsonPlaceHolder> {
  List<Post> posts = [];

  late INetworkManager networkManager;

  bool isLoading = false;

  // You don't have to set this parameter in your project. We used that for showing two different case at the same time.
  bool setCustomHttpClientExample = false;

  @override
  void initState() {
    super.initState();
    // Default usage:
    // networkManager = NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'), customHttpClientAdapter: CustomHttpClientAdapter());
    networkManager = setCustomHttpClientExample
        ? NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'), customHttpClientAdapter: CustomHttpClientAdapter())
        :
        //for example: you can add your custom http client adapter when initializing manager
        NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
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
