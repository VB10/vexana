import 'package:example/json_place_holder/json_place_holder_view.dart';
import 'package:flutter/material.dart';

import 'json_place_holder/json_place_holder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: JsonPlaceHolder());
  }
}
