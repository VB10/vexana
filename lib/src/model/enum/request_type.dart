// ignore_for_file: constant_identifier_names

enum RequestType {
  GET,
  POST,
  DELETE,
  PUT,
  PATCH,
}

extension NetworkTypeExtension on RequestType {
  /// [RequestType] convert to string value.
  String get stringValue {
    switch (this) {
      case RequestType.GET:
        return 'GET';
      case RequestType.POST:
        return 'POST';
      case RequestType.DELETE:
        return 'DELETE';
      case RequestType.PUT:
        return 'PUT';
      case RequestType.PATCH:
        return 'PATCH';
      default:
        throw 'Method Not Found';
    }
  }
}
