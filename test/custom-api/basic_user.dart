import 'package:vexana/vexana.dart';

class BasicUser extends INetworkModel<BasicUser> {
  String user;

  BasicUser({this.user});

  BasicUser.fromJson(Map<String, dynamic> json) {
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.user;
    return data;
  }

  @override
  BasicUser fromJson(Map<String, Object> json) => BasicUser.fromJson(json);
}
