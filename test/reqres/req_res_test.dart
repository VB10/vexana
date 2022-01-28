import 'dart:math';

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
            parseModel: ReqResModel(), method: RequestType.GET, canceltoken: cancelToken)
        .catchError((err) {
      if (CancelToken.isCancel(err)) {
        print('Request canceled! ' + err.message);
      } else {
        // handle error.
      }
    });

    cancelToken.cancel('canceled');

    await Future.delayed(const Duration(seconds: 8));
  });
}
