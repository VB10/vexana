// ignore_for_file: public_member_api_docs

import 'package:vexana/src/utility/index.dart';

final class LogItems {
  LogItems._init();
  static void bodyParseErrorLog({
    required dynamic data,
    required bool? isEnableLogger,
  }) =>
      CustomLogger(
        isEnabled: isEnableLogger,
        data: 'Response body is not a'
            'List or a Map<String, dynamic> response,:'
            '$data',
      ).printError();

  static void bodyParseGeneralLog<T, R>({
    required dynamic data,
    required dynamic responseBody,
    required bool? isEnableLogger,
  }) =>
      CustomLogger(
        isEnabled: isEnableLogger,
        data: 'Parse Error: $data - response body: $responseBody'
            'T model: $T , R model: $R ',
      ).printError();

  static void formDataLog<T>({required bool? isEnableLogger}) => CustomLogger(
        isEnabled: isEnableLogger,
        data: 'FormData is parsed $T',
      ).printError();

  static void jsonDecodeError() => const CustomLogger(
        isEnabled: true,
        data: 'JSON Decode Error ⛔',
      ).printError();
}
