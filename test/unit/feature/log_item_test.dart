import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/utility/index.dart';
import 'package:vexana/src/utility/logger/log_items.dart';
import 'package:vexana/vexana.dart';

void main() {
  const customLogger = CustomLogger(data: 'test', isEnabled: true);
  group('LogItems', () {
    // You can set up a MockCustomLogger here if needed

    test('bodyParseErrorLog should log the correct message', () {
      LogItems.bodyParseErrorLog(
        data: customLogger,
        isEnableLogger: true,
      );

      LogItems.bodyParseGeneralLog<EmptyModel, EmptyModel>(
        data: customLogger,
        isEnableLogger: false,
        responseBody: EmptyModel(),
      );

      LogItems.formDataLog<EmptyModel>(isEnableLogger: true);
      LogItems.jsonDecodeError();
    });
  });
}
