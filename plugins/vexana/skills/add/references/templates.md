# Templates

Placeholders: `{{Model}}` UpperCamel class name, `{{Models}}` its English plural in UpperCamel (`Post` → `Posts`, `Company` → `Companies`, `Address` → `Addresses`; when the endpoint path names the resource, use that segment: `/companies` → `Companies`), `{{model}}` lowerCamel, `{{model_snake}}` snake_case file name, `{{Feature}}` / `{{feature}}` / `{{feature_snake}}` likewise, `{{package}}` the project's pubspec `name`, `{{E}}` the error model type (`EmptyModel` or the generated one), `{{path}}` the endpoint path without the leading `/` (`posts`).

Paths: `{{networkPath}}` is the network folder under `lib/` (`core/network`, `product/network`). `{{featurePath}}` is the feature folder under `lib/`: the project's features root plus the feature name (`features/post`, `feature/post`, `src/features/post`). Every file path below is written with these; never put `lib/` inside them.

## Type inference (JSON value → Dart field)

| JSON sample | Dart type | fromJson expression for key `k` | toJson expression |
|---|---|---|---|
| string | `String?` | `json['k'] as String?` | `f` |
| integer in every sample | `int?` | `json['k'] as int?` | `f` |
| any sample has a fraction | `double?` | `(json['k'] as num?)?.toDouble()` | `f` |
| bool | `bool?` | `json['k'] as bool?` | `f` |
| object | `Child?` | `json['k'] == null ? null : Child.fromMap(json['k'] as Map<String, dynamic>)` | `f?.toJson()` |
| array of objects | `List<Child>?` | `(json['k'] as List<dynamic>?)?.map((e) => Child.fromMap(e as Map<String, dynamic>)).toList()` | `f?.map((e) => e.toJson()).toList()` |
| array of strings/ints/doubles/bools | `List<String>?` etc. | `(json['k'] as List<dynamic>?)?.cast<String>()` (doubles: `?.map((e) => (e as num).toDouble()).toList()`) | `f` |
| empty array | `List<Object?>?` | `(json['k'] as List<dynamic>?)?.cast<Object?>()` | `f` — report it |
| only `null` in every sample | `Object?` | `json['k']` | `f` — report it |

For a top-level array, infer the element model from **all** elements: the union of keys, and a key's type widened (`int` + fraction → `double`). Nested classes are named after the key in UpperCamel singular (`address` → `Address`, `tags` → `Tag`); on a clash prefix with the parent (`UserAddress`).

**Field names:** lowerCamelCase of the key (`user_name`, `user-name` → `userName`). A key that is a Dart reserved word gets a trailing `_` (`class` → `class_`). A key starting with a digit gets an `n` prefix (`2fa` → `n2fa`). The JSON key string in `fromMap`/`toJson` always stays the original key.

## Network setup — `lib/{{networkPath}}/app_network_manager.dart`

```dart
import 'package:vexana/vexana.dart';

/// Builds the app's single [INetworkManager].
///
/// The base URL comes from `--dart-define=BASE_URL=...`.
final class AppNetworkManager {
  AppNetworkManager._();

  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '{{defaultBaseUrl}}',
  );

  static final INetworkManager<{{E}}> instance = NetworkManager<{{E}}>(
    options: BaseOptions(baseUrl: _baseUrl),
    // errorModel line only when an error model was generated:
    errorModel: const {{E}}(),
    // fileManager line only when a cache was chosen (LocalFile() or LocalPreferences()):
    fileManager: LocalFile(),
  );
}
```
Delete the two `//` instruction comments and any option line that does not apply; keep the `///` doc comment.

In every template below, the `// only when …` import line is kept without its comment when `{{E}}` is a generated error model, and deleted when `{{E}}` is `EmptyModel`.

## Model — `lib/{{featurePath}}/model/{{model_snake}}.dart`

One file per top-level model; nested classes go in the same file below it.

```dart
import 'package:vexana/vexana.dart';

final class {{Model}} extends INetworkModel<{{Model}}> {
  const {{Model}}({
    this.id,
    this.title,
  });

  factory {{Model}}.fromMap(Map<String, dynamic> json) => {{Model}}(
        id: json['id'] as int?,
        title: json['title'] as String?,
      );

  final int? id;
  final String? title;

  @override
  {{Model}} fromJson(Map<String, dynamic> json) => {{Model}}.fromMap(json);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };
}
```
Fields, `fromMap` entries and `toJson` entries follow the JSON key order.

## Service — `lib/{{featurePath}}/service/{{feature_snake}}_service.dart`

```dart
import 'package:vexana/vexana.dart';
import 'package:{{package}}/{{networkPath}}/api_error_model.dart'; // only when {{E}} is not EmptyModel
import 'package:{{package}}/{{featurePath}}/model/{{model_snake}}.dart';

abstract interface class I{{Feature}}Service {
  Future<NetworkResult<List<{{Model}}>, {{E}}>> fetch{{Models}}();
  Future<NetworkResult<{{Model}}, {{E}}>> fetch{{Model}}(int id);
}

final class {{Feature}}Service implements I{{Feature}}Service {
  {{Feature}}Service(this._manager);

  final INetworkManager<{{E}}> _manager;

  @override
  Future<NetworkResult<List<{{Model}}>, {{E}}>> fetch{{Models}}() {
    return _manager.sendRequest<{{Model}}, List<{{Model}}>>(
      '/{{path}}',
      parseModel: const {{Model}}(),
      method: RequestType.GET,
    );
  }

  @override
  Future<NetworkResult<{{Model}}, {{E}}>> fetch{{Model}}(int id) {
    return _manager.sendRequest<{{Model}}, {{Model}}>(
      '/{{path}}/$id',
      parseModel: const {{Model}}(),
      method: RequestType.GET,
    );
  }
}
```
Generate only the methods for the endpoints the user gave. Method names: `GET` list → `fetch<Models>` (proper plural, never `<Model>` + `s`: `fetchCompanies`, not `fetchCompanys`), `GET` one → `fetch<Model>`, `POST` → `create<Model>` with a `{{Model}} body` parameter passed as `data: body`, `PUT`/`PATCH` → `update<Model>(int id, {{Model}} body)`, `DELETE` → `delete<Model>(int id)` returning `NetworkResult<EmptyModel, {{E}}>` with `parseModel: const EmptyModel()`. Path parameters (`/posts/{id}`) become method parameters: `int` when the name is `id` or ends in `Id`, otherwise `String` (`{slug}` → `String slug`).

## Fake service — `lib/{{featurePath}}/service/fake_{{feature_snake}}_service.dart`

Embeds at most the first 3 elements of the fixture (or the whole object) so it works in the running app, where `test/fixtures` is not available. The sample ships inside the app: replace anything that looks like a token, password, email, phone number or personal name with a placeholder (`"user@example.com"`, `"<token>"`) and say so in the report. If the model has no `int id` field, `fetch{{Model}}` returns `_items.first`.

```dart
import 'dart:convert';

import 'package:vexana/vexana.dart';
import 'package:{{package}}/{{networkPath}}/api_error_model.dart'; // only when {{E}} is not EmptyModel
import 'package:{{package}}/{{featurePath}}/model/{{model_snake}}.dart';
import 'package:{{package}}/{{featurePath}}/service/{{feature_snake}}_service.dart';

/// Returns sample data for building UI before the API is ready.
final class Fake{{Feature}}Service implements I{{Feature}}Service {
  const Fake{{Feature}}Service();

  static const String _sample = r'''
[{"id": 1, "title": "sample"}]
''';

  List<{{Model}}> get _items => (jsonDecode(_sample) as List<dynamic>)
      .map((e) => {{Model}}.fromMap(e as Map<String, dynamic>))
      .toList();

  @override
  Future<NetworkResult<List<{{Model}}>, {{E}}>> fetch{{Models}}() async =>
      NetworkSuccessResult(_items);

  @override
  Future<NetworkResult<{{Model}}, {{E}}>> fetch{{Model}}(int id) async =>
      NetworkSuccessResult(_items.firstWhere((e) => e.id == id, orElse: () => _items.first));
}
```

## Fixture reader — `test/helpers/fixture_reader.dart`

```dart
import 'dart:io';

/// Reads `test/fixtures/<name>` as a string.
String readFixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Removes null values recursively. A model writes `"k": null` for a key an
/// API sample omitted, so round-trip tests compare both sides without nulls.
Object? dropNulls(Object? value) => switch (value) {
      Map<dynamic, dynamic>() => {
          for (final entry in value.entries)
            if (entry.value != null) entry.key: dropNulls(entry.value),
        },
      List<dynamic>() => [for (final item in value) dropNulls(item)],
      _ => value,
    };
```
If the project's `fixture_reader.dart` exists without `dropNulls`, add the function to it.

## Model test — `test/{{featurePath}}/model/{{model_snake}}_test.dart`

Object fixture:
```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:{{package}}/{{featurePath}}/model/{{model_snake}}.dart';

import '<relative>/helpers/fixture_reader.dart';

void main() {
  test('{{Model}} round-trips {{model_snake}}.json', () {
    final json = jsonDecode(readFixture('{{model_snake}}.json')) as Map<String, dynamic>;
    expect(dropNulls(const {{Model}}().fromJson(json).toJson()), dropNulls(json));
  });
}
```
Array fixture: decode as `List<dynamic>` and assert the round trip for every element:
```dart
final json = jsonDecode(readFixture('{{model_snake}}.json')) as List<dynamic>;
for (final item in json.cast<Map<String, dynamic>>()) {
  expect(dropNulls(const {{Model}}().fromJson(item).toJson()), dropNulls(item));
}
```

## Service test — `test/{{featurePath}}/service/{{feature_snake}}_service_test.dart`

Mock `INetworkManager<{{E}}>` with mocktail; `registerFallbackValue(const {{Model}}())` and `registerFallbackValue(RequestType.GET)` in `setUpAll`. Every named argument the service method passes to `sendRequest` must appear in `when(...)` and `verify(...)` as `any(named: '...')` — mocktail treats a missing one as `null` and the stub never matches. A `POST`/`PUT`/`PATCH` method passes `data`, so its stub has `data: any(named: 'data')`. For each service method write two tests: success (stub returns `NetworkSuccessResult`, `verify` exact path and method, `.called(1)`) and error (stub returns `NetworkErrorResult(ErrorModel<{{E}}>(statusCode: 500, description: 'boom'))`, assert the error is returned unchanged).

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vexana/vexana.dart';
import 'package:{{package}}/{{networkPath}}/api_error_model.dart'; // only when {{E}} is not EmptyModel
import 'package:{{package}}/{{featurePath}}/model/{{model_snake}}.dart';
import 'package:{{package}}/{{featurePath}}/service/{{feature_snake}}_service.dart';

class _MockNetworkManager extends Mock implements INetworkManager<{{E}}> {}

void main() {
  late _MockNetworkManager manager;
  late {{Feature}}Service service;

  setUpAll(() {
    registerFallbackValue(const {{Model}}());
    registerFallbackValue(RequestType.GET);
  });

  setUp(() {
    manager = _MockNetworkManager();
    service = {{Feature}}Service(manager);
  });

  test('fetch{{Models}} sends GET /{{path}} and returns the success result', () async {
    const items = [{{Model}}(id: 1)];
    when(
      () => manager.sendRequest<{{Model}}, List<{{Model}}>>(
        any(),
        parseModel: any(named: 'parseModel'),
        method: any(named: 'method'),
      ),
    ).thenAnswer((_) async => const NetworkSuccessResult(items));

    final result = await service.fetch{{Models}}();

    expect((result as NetworkSuccessResult<List<{{Model}}>, {{E}}>).data, items);
    verify(
      () => manager.sendRequest<{{Model}}, List<{{Model}}>>(
        '/{{path}}',
        parseModel: any(named: 'parseModel'),
        method: RequestType.GET,
      ),
    ).called(1);
  });

  test('fetch{{Models}} returns the error result unchanged', () async {
    const error = ErrorModel<{{E}}>(statusCode: 500, description: 'boom');
    when(
      () => manager.sendRequest<{{Model}}, List<{{Model}}>>(
        any(),
        parseModel: any(named: 'parseModel'),
        method: any(named: 'method'),
      ),
    ).thenAnswer((_) async => const NetworkErrorResult(error));

    final result = await service.fetch{{Models}}();

    expect((result as NetworkErrorResult<List<{{Model}}>, {{E}}>).error.statusCode, 500);
  });
}
```
A method with a path parameter stubs `sendRequest<{{Model}}, {{Model}}>` and verifies the resolved path (`'/{{path}}/7'` for `fetch{{Model}}(7)`). The success stub's sample uses a field the model actually has.
