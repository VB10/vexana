import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'req_res_model.dart';

void main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager(
        isEnableLogger: true, options: BaseOptions(baseUrl: 'https://reqres.in/api'), isEnableTest: true);
  });
  test('Delay Request', () async {
    final cancelToken = CancelToken();
    networkManager
        .send<ReqResModel, ReqResModel>('/users?delay=5',
            parseModel: ReqResModel(), method: RequestType.GET, cancelToken: cancelToken)
        .catchError((err) {
      if (CancelToken.isCancel(err)) {
        print('Request canceled! ' + err.message);
      }
    });

    cancelToken.cancel('canceled');

    await Future.delayed(const Duration(seconds: 8));
  });
}
