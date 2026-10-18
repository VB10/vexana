import 'package:test/test.dart';
import 'package:vexana_jaspr/vexana_jaspr.dart';

void main() {
  late int requests;

  NetworkManager<EmptyModel> createManager(JasprNoNetwork noNetwork) {
    return NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: 'https://example.com'),
      noNetwork: noNetwork,
      interceptor: InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 404),
            ),
            true,
          );
        },
      ),
    );
  }

  Future<IResponseModel<EmptyModel?, EmptyModel?>> send(
    NetworkManager<EmptyModel> manager,
  ) {
    return manager.send<EmptyModel, EmptyModel>(
      '/x',
      parseModel: const EmptyModel(),
      method: RequestType.GET,
      isErrorDialog: true,
    );
  }

  setUp(() => requests = 0);

  test('without onNetworkLoss a failed request is not retried', () async {
    final manager = createManager(JasprNoNetwork(isOnline: () async => false));

    final response = await send(manager);

    expect(requests, 1);
    expect(response.error?.statusCode, 404);
  });

  test('online errors are not treated as network loss', () async {
    var lossCalls = 0;
    final manager = createManager(
      JasprNoNetwork(
        isOnline: () async => true,
        onNetworkLoss: (retry, dismiss) {
          lossCalls++;
          retry();
        },
      ),
    );

    await send(manager);

    expect(requests, 1);
    expect(lossCalls, 0);
  });

  test('offline retry is capped at maxRetryCount', () async {
    final manager = createManager(
      JasprNoNetwork(
        isOnline: () async => false,
        onNetworkLoss: (retry, dismiss) => retry(),
      ),
    );

    await send(manager);

    expect(requests, 4);
  });

  test('dismiss completes the request without retrying', () async {
    final manager = createManager(
      JasprNoNetwork(
        isOnline: () async => false,
        onNetworkLoss: (retry, dismiss) => dismiss(),
      ),
    );

    final response = await send(manager);

    expect(requests, 1);
    expect(response.error?.statusCode, 404);
  });

  test('retry after dismiss is ignored', () async {
    var retried = false;
    final handler = JasprNoNetwork(
      isOnline: () async => false,
      onNetworkLoss: (retry, dismiss) {
        dismiss();
        retry();
        retry();
      },
    );

    await handler.handle(onRetry: () async => retried = true);

    expect(retried, isFalse);
  });
}
