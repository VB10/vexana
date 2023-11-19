import 'dart:ui';

import 'package:vexana/vexana.dart';

import 'mock_parameters.dart';

final class MockErrorNetworkManager extends NetworkManager<EmptyModel> {
  MockErrorNetworkManager()
      : super(
          options: MockNetworkManagerLocalParameters().baseOptions,
          isEnableTest: true,
        );

  // @override
  // Future<IResponseModel<R?, EmptyModel?>> send<T extends INetworkModel<T>, R>(
  //   String path, {
  //   required T parseModel,
  //   required RequestType method,
  //   String? urlSuffix = '',
  //   Map<String, dynamic>? queryParameters,
  //   Options? options,
  //   Duration? expiration,
  //   data,
  //   ProgressCallback? onReceiveProgress,
  //   bool isErrorDialog = false,
  //   CancelToken? cancelToken,
  // }) {
  //   final defaultOptions = Options();

  //   options ??= defaultOptions;
  //   options.method = method.stringValue;

  //   final requestOptions = RequestOptions(
  //     path: path,
  //     method: method.stringValue,
  //     queryParameters: queryParameters,
  //   );

  //   throw DioException.badResponse(
  //     statusCode: 401,
  //     requestOptions: requestOptions,
  //     response: Response(
  //       requestOptions: requestOptions,
  //     ),
  //   );

  //   return handleNetworkError<T, R>(
  //     path: path,
  //     cancelToken: cancelToken,
  //     data: data,
  //     isErrorDialog: isErrorDialog,
  //     options: options,
  //     urlSuffix: urlSuffix,
  //     queryParameters: queryParameters,
  //     parseModel: parseModel,
  //     method: method,
  //     error: DioException.badResponse(
  //       statusCode: 401,
  //       requestOptions: requestOptions,
  //       response: Response(requestOptions: requestOptions),
  //     ),
  //     onError: errorResponseFetch,
  //   );
  // }
}

final class MockErrorCustomNetworkManager extends NetworkManager<EmptyModel> {
  MockErrorCustomNetworkManager(String baseUrl, VoidCallback onRefresh)
      : super(
          options: BaseOptions(
            baseUrl: baseUrl,
          ),
          isEnableTest: true,
          onRefreshFail: () {
            print('onRefreshFail x1');
          },
          onRefreshToken: (e, networkManager) async {
            await Future.delayed(const Duration(seconds: 1));
            onRefresh.call();
            return e;
          },
        );
}
