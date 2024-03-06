// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'file_download_model.dart';

// ignore: always_declare_return_types
void main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager<EmptyModel>(
      isEnableLogger: true,
      isEnableTest: true,
      options: BaseOptions(baseUrl: 'http://www.africau.edu/images/default/'),
    );
  });
  test('Primitive Type', () async {
    final response = await networkManager.downloadFileSimple(
        'http://www.africau.edu/images/default/sample.pdf', (count, total) {
      print('${count}');
    });
    expect(response.data, isList);
  });
  test('Download File', () async {
    final response = await networkManager.downloadFile(
      'sample.pdf',
      (count, total) {
        print('${count}');
      },
      method: RequestType.GET,
      data: FileDownloadModel(),
    );
    expect(response.data, isList);
  });
}
