import 'package:test/test.dart';
import 'package:vexana_core/vexana_core.dart';

final class _FakeNoNetwork implements INoNetworkHandler {
  _FakeNoNetwork({required this.retry});

  final bool retry;
  int calls = 0;

  @override
  Future<void> handle({
    required Future<void> Function() onRetry,
    String? host,
  }) async {
    calls++;
    if (retry) await onRetry();
  }
}

void main() {
  late int requests;

  NetworkManager<EmptyModel> createManager(
    INoNetworkHandler noNetwork, {
    int maxRetryCount = 3,
  }) {
    return NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: 'https://example.com'),
      noNetwork: noNetwork,
      maxRetryCount: maxRetryCount,
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

  setUp(() => requests = 0);

  test('send stops retrying at maxRetryCount', () async {
    final noNetwork = _FakeNoNetwork(retry: true);
    final manager = createManager(noNetwork);

    final response = await manager.send<EmptyModel, EmptyModel>(
      '/x',
      parseModel: const EmptyModel(),
      method: RequestType.GET,
      isErrorDialog: true,
    );

    expect(requests, 4);
    expect(noNetwork.calls, 3);
    expect(response.error?.statusCode, 404);
  });

  test('sendRequest stops retrying at maxRetryCount', () async {
    final noNetwork = _FakeNoNetwork(retry: true);
    final manager = createManager(noNetwork, maxRetryCount: 2);

    final result = await manager.sendRequest<EmptyModel, EmptyModel>(
      '/x',
      parseModel: const EmptyModel(),
      method: RequestType.GET,
      isErrorDialog: true,
    );

    expect(requests, 3);
    expect(noNetwork.calls, 2);
    expect(result, isA<NetworkErrorResult<EmptyModel, EmptyModel>>());
  });

  test('retry budget is restored for the next request', () async {
    final manager = createManager(_FakeNoNetwork(retry: true));

    for (var i = 0; i < 2; i++) {
      await manager.send<EmptyModel, EmptyModel>(
        '/x',
        parseModel: const EmptyModel(),
        method: RequestType.GET,
        isErrorDialog: true,
      );
    }

    expect(requests, 8);
  });

  test('no retry when handler does not ask for it', () async {
    final noNetwork = _FakeNoNetwork(retry: false);
    final manager = createManager(noNetwork);

    await manager.send<EmptyModel, EmptyModel>(
      '/x',
      parseModel: const EmptyModel(),
      method: RequestType.GET,
      isErrorDialog: true,
    );

    expect(requests, 1);
    expect(noNetwork.calls, 1);
  });

  test('handler is ignored without isErrorDialog', () async {
    final noNetwork = _FakeNoNetwork(retry: true);
    final manager = createManager(noNetwork);

    await manager.send<EmptyModel, EmptyModel>(
      '/x',
      parseModel: const EmptyModel(),
      method: RequestType.GET,
    );

    expect(requests, 1);
    expect(noNetwork.calls, 0);
  });
}
