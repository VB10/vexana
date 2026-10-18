import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/utility/http_status.dart';

void main() {
  group('HttpStatus', () {
    // Shim, dart:io'nun HttpStatus'unun yerine geçiyor. dart:io wasm
    // derlemesinde yok, dart:html'de ise HttpStatus hiç yok. Değerlerin
    // dart:io ile birebir aynı olduğunu doğruluyoruz.
    test('dart:io ile aynı değerleri verir', () {
      expect(HttpStatus.ok, io.HttpStatus.ok);
      expect(HttpStatus.multipleChoices, io.HttpStatus.multipleChoices);
      expect(HttpStatus.unauthorized, io.HttpStatus.unauthorized);
      expect(HttpStatus.clientClosedRequest, io.HttpStatus.clientClosedRequest);
      expect(
        HttpStatus.internalServerError,
        io.HttpStatus.internalServerError,
      );
    });

    test('beklenen sayısal değerler', () {
      expect(HttpStatus.ok, 200);
      expect(HttpStatus.multipleChoices, 300);
      expect(HttpStatus.unauthorized, 401);
      expect(HttpStatus.clientClosedRequest, 499);
      expect(HttpStatus.internalServerError, 500);
    });
  });
}
