import 'package:vexana/vexana.dart';

class BasicUser extends INetworkModel<BasicUser> {
  String? user;

  BasicUser({this.user});

  BasicUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    user = json['user'] as String?;
  }

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['user'] = user ?? '';
    return data;
  }

  @override
  BasicUser fromJson(Map<String, dynamic>? json) => BasicUser.fromJson(json);
}
