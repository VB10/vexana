import 'package:vexana/vexana.dart';

class Credantial extends INetworkModel<Credantial> {
  String name;
  String token;

  Credantial({this.name, this.token});

  Credantial.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    token = json['token'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['token'] = token;
    return data;
  }

  @override
  Credantial fromJson(Map<String, Object> json) {
    return Credantial.fromJson(json);
  }
}
