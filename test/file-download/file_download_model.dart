import 'package:vexana/vexana.dart';

class FileDownloadModel extends INetworkModel {
  String? reportId;

  FileDownloadModel({this.reportId});

  FileDownloadModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    reportId = json['reportId'] as String?;
  }

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['reportId'] = reportId ?? '';
    return data;
  }

  @override
  FileDownloadModel fromJson(Map<String, dynamic>? json) => FileDownloadModel.fromJson(json);
}