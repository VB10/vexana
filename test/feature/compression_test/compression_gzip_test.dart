import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import '../../utils/utils.dart';
import 'compression_user.dart';

void main() {
  late INetworkManager<EmptyModel> networkManager;
  late Dio dio;

  setUp(() async {
    await startServer();
    dio = Dio();
    networkManager = NetworkManager<EmptyModel>(
      options: BaseOptions(
        baseUrl: serverUrl.toString(),
        headers: {
          'Accept-Encoding': 'gzip',
        },
      ),
    );
  });

  tearDown(stopServer);

  test('should handle gzip compressed response', () async {
    // Act
    final response = await networkManager.send<EmptyModel, EmptyModel>(
      '/gzip',
      parseModel: const EmptyModel(),
      method: RequestType.GET,
      data: const CompressionUser(
        name: 'test',
        email: 'test@test.com',
        phone: '1234567890',
        address: 'test',
        city: 'test',
        state: 'test',
        zip: '1234567890',
      ),
      compressionType: NetworkCompressionType.gzip,
    );

    // Assert
    expect(response.data, isNotNull);
    expect(response.error, isNull);
  });

  test('should decompress gzip response correctly', () async {
    // Act
    final response = await networkManager.send<EmptyModel, EmptyModel>(
      '/gzip',
      parseModel: const EmptyModel(),
      method: RequestType.GET,
    );

    // Assert
    expect(response.data, isNotNull);
    expect(response.error, isNull);

    // Verify the response body is properly decompressed
    final responseBody = response.data?.name;
    expect(responseBody, 'This is a gzip compressed response');
  });
}
