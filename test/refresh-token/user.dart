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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['date'] = this.date;
    data['place'] = this.place;
    return data;
  }

  @override
  User fromJson(Map<String, Object> json) {
    return User.fromJson(json);
  }
}
