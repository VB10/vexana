import 'package:vexana/vexana.dart';

class FileDownloadModel extends INetworkModel<FileDownloadModel> {
  FileDownloadModel({this.fileId});

  FileDownloadModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    fileId = json['fileId'] as String?;
  }
  String? fileId;

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['fileId'] = fileId ?? '';
    return data;
  }

  @override
  FileDownloadModel fromJson(Map<String, dynamic>? json) =>
      FileDownloadModel.fromJson(json);
}
