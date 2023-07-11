import 'package:vexana/src/interface/INetworkModel.dart';

class QuotesModel extends INetworkModel<QuotesModel> {
  QuotesModel({this.text, this.author});

  QuotesModel.fromJson(Map<String, dynamic> json) {
    text = json['text'] is String ? json['text'] as String : '';
    author = json['author'] is String ? json['author'] as String : '';
  }
  String? text;
  String? author;

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['text'] = text;
    data['author'] = author;
    return data;
  }

  @override
  QuotesModel fromJson(Map<String, dynamic> json) {
    return QuotesModel.fromJson(json);
  }
}
