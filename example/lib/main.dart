import 'package:example/json_place_holder/json_place_holder.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: JsonPlaceHolder(),
    );
  }
}
