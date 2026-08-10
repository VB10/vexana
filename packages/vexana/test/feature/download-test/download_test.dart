import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import '../../utils/utils.dart';

void main() {
  setUp(startServer);
  tearDown(stopServer);

  test('download writes the response body to the given path', () async {
    final networkManager = NetworkManager<EmptyModel>(
      isEnableTest: true,
      options: BaseOptions(baseUrl: serverUrl.toString()),
    );
    final tempDirectory =
        Directory.systemTemp.createTempSync('vexana_download_test');
    addTearDown(() => tempDirectory.deleteSync(recursive: true));
    final savePath = '${tempDirectory.path}/download.txt';
    var interceptorCalled = false;
    var progressCallCount = 0;
    var lastReceived = 0;
    networkManager.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptorCalled = true;
          handler.next(options);
        },
      ),
    );

    final response = await networkManager.download(
      '/download',
      savePath,
      onReceiveProgress: (received, total) {
        progressCallCount++;
        lastReceived = received;
      },
    );

    expect(response.statusCode, 200);
    expect(File(savePath).readAsStringSync(), 'I am a text file');
    expect(interceptorCalled, isTrue);
    expect(progressCallCount, greaterThan(0));
    expect(lastReceived, 'I am a text file'.length);
  });

  test('download resolves the save path from a callback', () async {
    final networkManager = NetworkManager<EmptyModel>(
      isEnableTest: true,
      options: BaseOptions(baseUrl: serverUrl.toString()),
    );
    final tempDirectory =
        Directory.systemTemp.createTempSync('vexana_download_test');
    addTearDown(() => tempDirectory.deleteSync(recursive: true));

    await networkManager.download(
      '/download',
      (Headers headers) => '${tempDirectory.path}/from_headers.txt',
    );

    expect(
      File('${tempDirectory.path}/from_headers.txt').readAsStringSync(),
      'I am a text file',
    );
  });

  test('download preserves removal of the implied content type', () async {
    final networkManager = NetworkManager<EmptyModel>(
      isEnableTest: true,
      options: BaseOptions(baseUrl: serverUrl.toString()),
    );
    final tempDirectory =
        Directory.systemTemp.createTempSync('vexana_download_test');
    addTearDown(() => tempDirectory.deleteSync(recursive: true));
    String? observedContentType;
    networkManager.interceptors
      ..removeImplyContentTypeInterceptor()
      ..add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            observedContentType = options.contentType;
            handler.next(options);
          },
        ),
      );

    await networkManager.download(
      '/download',
      '${tempDirectory.path}/without_implied_content_type.txt',
      data: 'request body',
    );

    expect(observedContentType, isNull);
  });
}
