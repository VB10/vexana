# vexana_core

<p align="center">
  <a href="https://pub.dev/packages/vexana_core"><img src="https://img.shields.io/pub/v/vexana_core.svg" alt="Pub"></a>
  <a href="https://github.com/VB10/vexana/actions/workflows/pr_check.yml"><img src="https://github.com/VB10/vexana/actions/workflows/pr_check.yml/badge.svg" alt="CI"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

**`vexana_core`** is the pure Dart networking engine behind [Vexana](https://pub.dev/packages/vexana). It provides type-safe model parsing, automated token refreshing, retry interceptors, and a pluggable caching architecture — **with 100% zero Flutter SDK and zero `dart:ui` dependencies**.

It compiles cleanly with `dart2js`, Dart Native VM, and WebAssembly, making it the perfect foundation for:
- **Shared Domain Layers**: Share the same `INetworkModel` definitions across Flutter, Jaspr web, and backend services.
- **Jaspr Web Applications**: Use full Vexana networking inside Jaspr with [vexana_jaspr](https://pub.dev/packages/vexana_jaspr).
- **Dart Servers & CLI Tools**: Use robust Dio-powered networking in Dart Frog, Shelf, or command-line apps.

---

## Features

- **Zero Flutter Dependencies**: Verified in CI to ensure 0 `flutter` or `sky_engine` packages in its transitive tree. Compiles directly with `dart compile js`.
- **Type-Safe Dynamic Model Parsing**: Automatically parses single models (`send<T, T>`), lists of models (`send<T, List<T>>`), or primitive types (`send<T, String>`).
- **Unified Error Handling**: Strongly-typed `IErrorModel` and `NetworkResult<T>` with HTTP status codes and Dio error propagation.
- **Refresh Token Interceptor**: Built-in refresh token locking mechanism (`onRefreshToken` and `onRefreshFail`) to automatically refresh expired auth credentials.
- **Configurable Retry**: Automatically retries failed idempotent requests.
- **Pluggable Architecture**:
  - `IFileManager`: Bring your own cache storage (in-memory, local file, Redis, SQLite).
  - `INoNetworkHandler`: Intercept requests when offline and trigger retries when connectivity is restored.
- **Pure Isolate Compute**: Parses large JSON bodies off the main thread using pure Dart `Isolate.run` (IO) or inline processing (Web).

---

## Installation

Add `vexana_core` to your `pubspec.yaml`:

```yaml
dependencies:
  vexana_core: ^1.0.0
```

---

## Quick Start

### 1. Define an `INetworkModel`

All models extending `INetworkModel<T>` must implement `fromJson` and `toJson`:

```dart
import 'package:vexana_core/vexana_core.dart';

final class Todo extends INetworkModel<Todo> {
  Todo({this.userId, this.id, this.title, this.completed});

  final int? userId;
  final int? id;
  final String? title;
  final bool? completed;

  @override
  Todo fromJson(Map<String, dynamic> json) => Todo(
        userId: json['userId'] as int?,
        id: json['id'] as int?,
        title: json['title'] as String?,
        completed: json['completed'] as bool?,
      );

  @override
  Map<String, dynamic>? toJson() => {
        'userId': userId,
        'id': id,
        'title': title,
        'completed': completed,
      };
}
```

### 2. Initialize `NetworkManager`

```dart
import 'package:vexana_core/vexana_core.dart';

void main() async {
  final networkManager = NetworkManager<EmptyModel>(
    isEnableLogger: true,
    options: BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  // Fetch a single item
  final singleResponse = await networkManager.send<Todo, Todo>(
    '/todos/1',
    parseModel: Todo(),
    method: RequestType.GET,
  );
  print('Single: ${singleResponse.data?.title}');

  // Fetch a list of items
  final listResponse = await networkManager.send<Todo, List<Todo>>(
    '/todos',
    parseModel: Todo(),
    method: RequestType.GET,
  );
  print('Total items: ${listResponse.data?.length}');
}
```

---

## Advanced Capabilities

### Unified Error Model

Define a custom error model to automatically parse server errors (e.g., 400, 422, 500):

```dart
final class ApiErrorModel extends INetworkModel<ApiErrorModel> {
  ApiErrorModel({this.message, this.statusCode});

  final String? message;
  final int? statusCode;

  @override
  ApiErrorModel fromJson(Map<String, dynamic> json) => ApiErrorModel(
        message: json['message'] as String?,
        statusCode: json['statusCode'] as int?,
      );

  @override
  Map<String, dynamic>? toJson() => {'message': message, 'statusCode': statusCode};
}

final networkManager = NetworkManager<ApiErrorModel>(
  errorModel: ApiErrorModel(),
  options: BaseOptions(baseUrl: 'https://api.example.com'),
);

final response = await networkManager.send<Todo, Todo>(
  '/todos/invalid',
  parseModel: Todo(),
  method: RequestType.GET,
);

if (response.error != null) {
  print('API Error: ${response.error?.model?.message}');
}
```

### Automatic Token Refreshing

When a request returns `401 Unauthorized`, `NetworkManager` can automatically pause outgoing requests, refresh the authentication token, and replay the original request:

```dart
final networkManager = NetworkManager<EmptyModel>(
  options: BaseOptions(baseUrl: 'https://api.example.com'),
  onRefreshToken: (error, newService) async {
    // 1. Call refresh endpoint with newService (which bypasses interceptors)
    final refreshResponse = await newService.send<AuthToken, AuthToken>(
      '/auth/refresh',
      parseModel: AuthToken(),
      method: RequestType.POST,
      data: {'refreshToken': currentRefreshToken},
    );

    // 2. Update default Authorization header for subsequent requests
    networkManager.addBaseHeader(
      MapEntry('Authorization', 'Bearer ${refreshResponse.data?.accessToken}'),
    );

    // 3. Return updated Header with new token for the queued request
    return Header(
      key: 'Authorization',
      value: 'Bearer ${refreshResponse.data?.accessToken}',
    );
  },
  onRefreshFail: () {
    print('Token refresh failed. Redirect to login.');
  },
);
```

---

## Multi-Platform Ecosystem

- **Looking for Flutter?** Check out [`vexana`](https://pub.dev/packages/vexana) which re-exports `vexana_core` and adds Flutter widgets (`NoNetworkWidget`) and mobile file/shared-preferences cache adapters.
- **Looking for Jaspr Web?** Check out [`vexana_jaspr`](https://pub.dev/packages/vexana_jaspr) for browser `window.localStorage` caching and Jaspr offline components.

---

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file.
