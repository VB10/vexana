import '../interface/INetworkModel.dart';

class EmptyModel extends INetworkModel<EmptyModel> {
  String name;

  EmptyModel({this.name});

  EmptyModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }

  @override
  EmptyModel fromJson(Map<String, Object> json) {
    return EmptyModel.fromJson(json);
  }
}
