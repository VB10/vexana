import 'package:vexana/vexana.dart';

class BasicErrorModel extends INetworkModel<BasicErrorModel> {
  int statusCode;
  String message;
  String screenMessage;

  BasicErrorModel({this.statusCode, this.message, this.screenMessage});

  BasicErrorModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    screenMessage = json['screenMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    data['screenMessage'] = this.screenMessage;
    return data;
  }

  @override
  BasicErrorModel fromJson(Map<String, Object> json) => BasicErrorModel.fromJson(json);
}
