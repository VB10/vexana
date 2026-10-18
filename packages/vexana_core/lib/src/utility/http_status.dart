/// Platform bağımsız HTTP durum kodları.
///
/// `dart:io`'nun `HttpStatus`'unun yerine geçer.
///
/// Neden gerekli: `dart:io` WebAssembly derlemesinde bulunmuyor ve
/// `dart:html`'de `HttpStatus` diye bir sınıf hiç yok. Koşullu import ile
/// ikisi arasında seçim yapmak wasm'da çalışmıyordu. Bu sabitler saf Dart
/// olduğu için her platformda derleniyor.
///
/// Değerlerin `dart:io` ile birebir aynı olduğu testle doğrulanıyor:
/// `test/utils/http_status_test.dart`.
abstract final class HttpStatus {
  /// 200 OK
  static const int ok = 200;

  /// 300 Multiple Choices
  static const int multipleChoices = 300;

  /// 401 Unauthorized
  static const int unauthorized = 401;

  /// 499 Client Closed Request (nginx uzantısı)
  static const int clientClosedRequest = 499;

  /// 500 Internal Server Error
  static const int internalServerError = 500;
}
