// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';

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
      options: BaseOptions(baseUrl: 'https://pdfobject.com/pdf/'),
    );
  });
  test('Primitive Type', () async {
    final response = await networkManager.downloadFileSimple(
        'https://pdfobject.com/pdf/sample.pdf', (count, total) {
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

  // NetworkManager.download, DioMixin.download'ı override ediyor ama gövdesinde
  // `this.download(...)` çağırıyordu. Virtual dispatch en türemiş implementasyona
  // gittiği için bu kendini çağırıyor ve StackOverflowError'a düşüyordu.
  // DioMixin.download'ın kendisi `throw UnimplementedError()` olduğu için
  // super'e delege etmek de mümkün değil; gerçek bir Dio örneğine delege ediyoruz.
  test('download sonsuz özyinelemeye girmez', () async {
    // download() INetworkManager'da değil, sadece concrete NetworkManager'da
    // (DioMixin override'ı). Bu yüzden concrete tip kullanılıyor.
    final manager = NetworkManager<EmptyModel>(
      isEnableTest: true,
      options: BaseOptions(baseUrl: 'https://pdfobject.com/pdf/'),
    );
    final cancelToken = CancelToken()..cancel('test');

    await expectLater(
      manager.download(
        'sample.pdf',
        '${Directory.systemTemp.path}/vexana_download_test.pdf',
        cancelToken: cancelToken,
      ),
      throwsA(isA<DioException>()),
    );
  });
}
