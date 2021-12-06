import '../interface/INetworkModel.dart';

class EmptyModel extends INetworkModel<EmptyModel> {
  String? name;

  EmptyModel({this.name});

  EmptyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    name = json['name'] as String?;
  }

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['name'] = name ?? '';
    return data;
  }

  @override
  EmptyModel fromJson(Map<String, dynamic>? json) {
    return EmptyModel.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmptyModel && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
