import '../interface/INetworkModel.dart';

class EmptyModel extends INetworkModel<EmptyModel> {
  String name;

  EmptyModel({this.name});

  EmptyModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }

  @override
  EmptyModel fromJson(Map<String, Object> json) {
    return EmptyModel.fromJson(json);
  }
}
