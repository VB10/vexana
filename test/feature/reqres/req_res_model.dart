import 'package:vexana/vexana.dart';

class ReqResModel extends INetworkModel<ReqResModel> {
  ReqResModel({
    this.page,
    this.perPage,
    this.total,
    this.totalPages,
    this.data,
    this.support,
  });

  ReqResModel.fromJson(Map<String, dynamic> json) {
    page = json['page'] is int ? json['page'] as int : 0;
    perPage = json['per_page'] is int ? json['per_page'] as int : 0;
    total = json['total'] is int ? json['total'] as int : 0;
    totalPages = json['total_pages'] is int ? json['total_pages'] as int : 0;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        if (v is Map<String, dynamic>) {
          data?.add(Data.fromJson(v));
        }
      });
    }
    support = json['support'] is Map<String, dynamic>
        ? Support.fromJson(json['support'] as Map<String, dynamic>)
        : null;
  }
  int? page;
  int? perPage;
  int? total;
  int? totalPages;
  List<Data>? data;
  Support? support;

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['page'] = page;
    data['per_page'] = perPage;
    data['total'] = total;
    data['total_pages'] = totalPages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (support != null) {
      data['support'] = support!.toJson();
    }
    return data;
  }

  @override
  ReqResModel fromJson(Map<String, dynamic> json) {
    return ReqResModel.fromJson(json);
  }
}

class Data {
  Data({this.id, this.email, this.firstName, this.lastName, this.avatar});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] as int : 0;
    email = json['email'] is String ? json['email'] as String : '';
    firstName =
        json['first_name'] is String ? json['first_name'] as String : '';
    lastName = json['last_name'] is String ? json['last_name'] as String : '';
    avatar = json['avatar'] is String ? json['avatar'] as String : '';
  }
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? avatar;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['avatar'] = avatar;
    return data;
  }
}

class Support {
  Support({this.url, this.text});

  Support.fromJson(Map<String, dynamic> json) {
    url = json['url'] is String ? json['url'] as String : '';
    text = json['text'] is String ? json['text'] as String : '';
  }
  String? url;
  String? text;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['url'] = url;
    data['text'] = text;
    return data;
  }
}
