import 'package:vexana/vexana.dart';

class Credantial extends INetworkModel<Credantial> {
  String name;
  String token;

  Credantial({this.name, this.token});

  Credantial.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['token'] = this.token;
    return data;
  }

  @override
  Credantial fromJson(Map<String, Object> json) {
    return Credantial.fromJson(json);
  }
}
