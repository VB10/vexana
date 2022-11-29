// T is mean that any model but extends from network model so we can say it's definlty have tojson and from json method
abstract class IErrorModel<T> {
  int? statusCode;
  String? description;
  T? model;
  dynamic response;
}
