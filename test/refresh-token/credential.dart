import 'package:vexana/vexana.dart';

class Credential extends INetworkModel<Credential> {
  Credential({this.name, this.token});

  Credential.fromJson(Map<String, dynamic>? json) {
    name = json!['name'] as String?;
    token = json['token'] as String?;
  }
  String? name;
  String? token;

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['name'] = name ?? '';
    data['token'] = token ?? '';
    return data;
  }

  @override
  Credential fromJson(Map<String, dynamic>? json) {
    return Credential.fromJson(json);
  }
}
