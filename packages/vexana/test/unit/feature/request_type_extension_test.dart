import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/utility/extension/request_type_extension.dart';
import 'package:vexana/vexana.dart';

void main() {
  setUp(() {});
  test('Request type is valid', () {
    var requestType = RequestType.POST;
    expect(requestType.stringValue, 'POST');

    requestType = RequestType.GET;

    expect(requestType.stringValue, 'GET');

    requestType = RequestType.DELETE;

    expect(requestType.stringValue, 'DELETE');

    requestType = RequestType.PUT;

    expect(requestType.stringValue, 'PUT');
  });
}
