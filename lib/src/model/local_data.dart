class BaseLocal {
  DateTime time;
  String model;

  BaseLocal({this.time, this.model});

  BaseLocal.fromJson(Map<String, dynamic> json) {
    time = DateTime.parse(json['time']);
    model = json['model'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time.toString();
    data['model'] = this.model;
    return data;
  }
}
