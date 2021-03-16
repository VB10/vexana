import 'package:vexana/vexana.dart';

class Credantial extends INetworkModel<Credantial> {
  String? name;
  String? token;

  Credantial({this.name, this.token});

  Credantial.fromJson(Map<String, dynamic>? json) {
    name = json!['name'] as String?;
    token = json['token'] as String?;
  }

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['name'] = name ?? '';
    data['token'] = token ?? '';
    return data;
  }

  @override
  Credantial fromJson(Map<String, dynamic>? json) {
    return Credantial.fromJson(json);
  }
}
