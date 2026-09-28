# vexana migration rules

Each rule: **Detect** (a grep pattern over `lib/` and `test/`), **Action** (`edit` = apply mechanically, `flag` = report for manual review, `ask` = ask first), **Before → After**.

Rules were derived from the public API diff between the release tags `4.0.0`, `publish_5.0.2` and `publish_6.0.0`, and from the 6.0.0 CHANGELOG. Changes that only add API (new methods, new optional parameters) need no migration and are not listed.

## 4.x → 5.x

### Error and response models are immutable
`IErrorModel.statusCode`, `.description`, `.model` and `IResponseModel.data`, `.error` became `final`; their constructors became `const`.
- Detect: assignments to those fields — `\.(statusCode|description|model|data|error)\s*=[^=]` on values typed `IErrorModel`, `ErrorModel`, `IResponseModel` or `ResponseModel`.
- Action: edit — build a new object instead of mutating:
  - Before: `error.statusCode = 401;`
  - After: `error = ErrorModel(statusCode: 401, description: error.description, model: error.model);` (make the variable non-final if needed).
  - If the mutated object is not a local variable (e.g. a field another class holds), flag it instead.

### Retry count is a constructor option
`NetworkManagerParameters.maxRetryCount` was a `static const`; it is now an instance field set from `NetworkManager(maxRetryCount: …)`, default `3`.
- Detect: `NetworkManagerParameters.maxRetryCount`
- Action: edit — read the value from where the manager is built; to change it, pass `maxRetryCount:` to `NetworkManager(...)`.

## 5.x → 6.0

### Dependency
- Detect: `vexana:` in `pubspec.yaml`
- Action: edit — set `vexana: ^6.0.0`, then `flutter pub get`.

### SDK constraint
- Detect: `environment: sdk:` lower bound below 3.6.0 in `pubspec.yaml`
- Action: ask — propose `sdk: ^3.6.0`; it affects the whole app.

### dio private imports
vexana no longer re-exports `package:dio/src/...` paths. Everything they held is exported by `package:dio/dio.dart`, which vexana still re-exports.
- Detect: `import 'package:dio/src/`
- Action: edit — replace the import with `import 'package:dio/dio.dart';`, or delete it when the file already imports `package:vexana/vexana.dart`.
- Detect: `InterceptorState` or `InterceptorResultType`
- Action: flag — dio hides these internals; the code must be rewritten by hand.

### removeAll with LocalFile
- Detect: `.removeAll(` in a project whose NetworkManager uses `LocalFile(`
- Action: flag — it now removes only this manager's cache entries, not the whole application documents directory. Check the app did not rely on the old behaviour to clear other files.

### sendPrimitive / downloadFileSimple through interceptors
- Detect: `sendPrimitive` or `downloadFileSimple`, in a project that passes `interceptor:`, `onRefreshToken:` or adds to `dioInterceptors`
- Action: flag — these calls now run through the manager's interceptors, adapter and base options (they used a bare Dio before). Check auth, refresh-token and logging interceptors behave correctly for them.

## 6.0.x → 6.0.1

### Cache keys include the path and query
- Detect: `expiration:` in a `send`/`sendRequest` call
- Action: flag — cached responses are now stored per `path?query`; entries written by 6.0.0 are not read again and expire on their own. Nothing to change unless the app relied on one cache entry being shared across paths.
