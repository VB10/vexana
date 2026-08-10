import 'package:vexana/vexana.dart';

enum Endpoint {
  posts('GET /posts', '/posts', RequestType.GET, isList: true),
  singlePost('GET /posts/1', '/posts/1', RequestType.GET),
  notFound('GET /nope (404)', '/nope', RequestType.GET),
  createPost('POST /posts', '/posts', RequestType.POST);

  const Endpoint(this.label, this.path, this.method, {this.isList = false});

  final String label;
  final String path;
  final RequestType method;
  final bool isList;

  String get methodLabel => method.name.toUpperCase();
}
