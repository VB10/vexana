import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'req_res_model.dart';

void main() {
  late INetworkManager<EmptyModel> networkManager;
  setUp(() {
    networkManager = NetworkManager<EmptyModel>(
      isEnableLogger: true,
      options: BaseOptions(baseUrl: 'https://reqres.in/api'),
      isEnableTest: true,
    );
  });
  test('Delay Request', () async {
    final cancelToken = CancelToken();
    await networkManager
        .send<ReqResModel, ReqResModel>(
      '/users?delay=5',
      parseModel: ReqResModel(),
      method: RequestType.GET,
      cancelToken: cancelToken,
    )
        .catchError((err) {
      if (err is DioException) {
        if (CancelToken.isCancel(err)) {
          print('Request canceled! ${err.message}');
        }
      }
    });

    cancelToken.cancel('canceled');

    await Future.delayed(const Duration(seconds: 8));
  });

  test('error Request', () async {
    final response = await networkManager.send<ReqResModel, ReqResModel>(
      '/users/23',
      parseModel: ReqResModel(),
      method: RequestType.GET,
    );

    print(response.error);

    await Future.delayed(const Duration(seconds: 8));
  });
}
