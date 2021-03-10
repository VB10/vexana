import 'package:vexana/src/interface/INetworkModel.dart';

class User extends INetworkModel<User> {
  String? name;
  String? date;
  String? place;

  User({this.name, this.date, this.place});

  User.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    name = json['name'] as String?;
    date = json['date'] as String?;
    place = json['place'] as String?;
  }

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['name'] = name ?? '';
    data['date'] = date ?? '';
    data['place'] = place ?? '';
    return data;
  }

  @override
  User fromJson(Map<String, dynamic>? json) {
    return User.fromJson(json);
  }
}
