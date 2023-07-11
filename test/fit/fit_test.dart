import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'quate_model.dart';

main() {
  INetworkManager? networkManager;
  setUp(() {
    networkManager = NetworkManager<Null>(
        isEnableLogger: true,
        options: BaseOptions(baseUrl: 'https://type.fit/'));
  });

  test('Primitve Type', () async {
    final response =
        await networkManager?.send<QuotesModel, List<QuotesModel>>('api/quotes',
            parseModel: QuotesModel(),
            method: RequestType.GET,
            forceUpdateDecode: true,
            options: Options(
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
                followRedirects: false,
                headers: {Headers.contentTypeHeader: Headers.jsonContentType},
                extra: {Headers.contentTypeHeader: Headers.jsonContentType},
                responseDecoder: (data, request, response) {
                  String bar = utf8.decode(data);
                  return bar;
                }));

    expect(response?.data, isNotNull);
  });
}
