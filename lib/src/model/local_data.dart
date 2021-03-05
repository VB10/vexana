class LocalModel {
  DateTime? time;
  String? model;

  LocalModel({this.time, this.model});

  LocalModel.fromJson(Map<String, dynamic> json) {
    time = DateTime.parse(json['time']);
    model = json['model'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time.toString();
    data['model'] = model;
    return data;
  }
}
