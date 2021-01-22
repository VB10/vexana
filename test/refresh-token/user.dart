import 'package:vexana/src/interface/INetworkModel.dart';

class User extends INetworkModel<User> {
  String name;
  String date;
  String place;

  User({this.name, this.date, this.place});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    date = json['date'];
    place = json['place'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['date'] = date;
    data['place'] = place;
    return data;
  }

  @override
  User fromJson(Map<String, Object> json) {
    return User.fromJson(json);
  }
}
