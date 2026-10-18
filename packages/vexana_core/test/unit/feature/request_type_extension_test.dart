import 'package:test/test.dart';
import 'package:vexana_core/src/utility/extension/request_type_extension.dart';
import 'package:vexana_core/vexana_core.dart';

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
