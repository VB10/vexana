import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'req_res_model.dart';
import 'reqres_error_model.dart';

void main() {
  late INetworkManager<UserError> networkManager;
  setUp(() {
    networkManager = NetworkManager<UserError>(
        errorModel: UserError(),
        isEnableLogger: true,
        options: BaseOptions(baseUrl: 'https://reqres.in/api'),
        isEnableTest: true);
  });
  test('Delay Request', () async {
    final cancelToken = CancelToken();
    networkManager
        .send<ReqResModel, ReqResModel>('/users?delay=5',
            parseModel: ReqResModel(),
            method: RequestType.GET,
            cancelToken: cancelToken)
        .catchError((err) {
      if (CancelToken.isCancel(err)) {
        print('Request canceled! ' + err.message);
      }
    });

    cancelToken.cancel('canceled');

    await Future.delayed(const Duration(seconds: 8));
  });

  test('ERro request', () async {
    final response = await networkManager.send<ReqResModel, ReqResModel>(
      '/login',
      parseModel: ReqResModel(),
      data: {"email": "peter@klaven"},
      method: RequestType.POST,
    );

    print(response);
  });
}
