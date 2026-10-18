# vexana_jaspr

<p align="center">
  <a href="https://pub.dev/packages/vexana_jaspr"><img src="https://img.shields.io/pub/v/vexana_jaspr.svg" alt="Pub"></a>
  <a href="https://github.com/VB10/vexana/actions/workflows/pr_check.yml"><img src="https://github.com/VB10/vexana/actions/workflows/pr_check.yml/badge.svg" alt="CI"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

**`vexana_jaspr`** brings the full power of [Vexana](https://pub.dev/packages/vexana) to the [Jaspr](https://pub.dev/packages/jaspr) web framework.

It allows you to share identical `INetworkModel` classes between your Flutter apps and Jaspr web apps while providing web-native storage caching and reactive offline UI components.

---

## Features

- **Built on `vexana_core`**: Share the exact same `INetworkModel` classes across Flutter mobile apps, Jaspr web apps, and backend services.
- **Web LocalStorage Cache**: Built-in [`JasprLocalStorageFileManager`](lib/src/cache/jaspr_local_storage_file_manager.dart) backed by `window.localStorage` with duration-based cache expiration (falls back gracefully to in-memory storage during SSR or VM tests).
- **Jaspr No-Network Handler**: [`JasprNoNetwork`](lib/src/feature/no_network/jaspr_no_network.dart) implements `INoNetworkHandler` to intercept requests made without an active internet connection.
- **Reactive Offline Component**: Drop-in [`JasprNoNetworkComponent`](lib/src/feature/no_network/jaspr_no_network.dart) component rendering an interactive banner with a "Retry" button when connectivity drops.
- **Navigator Connectivity Check**: [`JasprNetworkCheck`](lib/src/feature/network_check/jaspr_network_check.dart) checks connection state via `window.navigator.onLine`.

---

## Installation

Add `vexana_jaspr` to your Jaspr project's `pubspec.yaml`:

```yaml
dependencies:
  jaspr: ^0.23.5
  vexana_jaspr: ^0.1.0
```

---

## Quick Start

### 1. Define a Shared Model

```dart
import 'package:vexana_jaspr/vexana_jaspr.dart';

final class Post extends INetworkModel<Post> {
  Post({this.id, this.title, this.body});

  final int? id;
  final String? title;
  final String? body;

  @override
  Post fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int?,
        title: json['title'] as String?,
        body: json['body'] as String?,
      );

  @override
  Map<String, dynamic>? toJson() => {'id': id, 'title': title, 'body': body};
}
```

### 2. Configure `NetworkManager` with Web Cache & NoNetwork

```dart
import 'package:vexana_jaspr/vexana_jaspr.dart';

final jasprNoNetwork = JasprNoNetwork();

final networkManager = NetworkManager<EmptyModel>(
  isEnableLogger: true,
  options: BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
  ),
  // Caches responses in browser window.localStorage
  fileManager: JasprLocalStorageFileManager(),
  // Handles offline requests
  noNetwork: jasprNoNetwork,
);
```

### 3. Display Offline Banner in your Jaspr Component Tree

Use `JasprNoNetworkComponent` anywhere in your Jaspr component tree to automatically notify users when requests fail due to lack of network:

```dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:vexana_jaspr/vexana_jaspr.dart';

class App extends StatelessComponent {
  const App({required this.noNetwork, super.key});

  final JasprNoNetwork noNetwork;

  @override
  Component build(BuildContext context) {
    return div([
      // Renders an offline alert bar with a "Retry" button when offline
      JasprNoNetworkComponent(noNetwork: noNetwork),

      h1([Component.text('Welcome to My Jaspr App')]),
      // ... your other components
    ]);
  }
}
```

---

## Complete Example

Check out the full working Jaspr web application in the [example](example) directory:

```bash
cd packages/vexana_jaspr/example
jaspr serve
```

---

## Related Packages

- [`vexana_core`](https://pub.dev/packages/vexana_core): Pure Dart core engine (zero Flutter SDK dependencies).
- [`vexana`](https://pub.dev/packages/vexana): Flutter package with mobile disk cache and Flutter widgets.

---

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file.
