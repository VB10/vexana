import 'package:test/test.dart';
import 'package:vexana_core/src/utility/index.dart';
import 'package:vexana_core/src/utility/logger/log_items.dart';
import 'package:vexana_core/vexana_core.dart';

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
        responseBody: const EmptyModel(),
      );

      LogItems.formDataLog<EmptyModel>(isEnableLogger: true);
      LogItems.jsonDecodeError();
    });
  });
}
