import 'package:vexana/src/interface/INetworkModel.dart';

class QuatesModel extends INetworkModel<QuatesModel> {
  String? text;
  String? author;

  QuatesModel({this.text, this.author});

  QuatesModel.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    author = json['author'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['author'] = author;
    return data;
  }

  @override
  QuatesModel fromJson(Map<String, dynamic> json) {
    return QuatesModel.fromJson(json);
  }
}
