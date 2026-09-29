---
name: init
description: Set up vexana (the dio-based Flutter networking layer) in a Flutter project — adds the dependency, builds one NetworkManager, an optional error model and the test fixture helper, placed in the project's existing folder structure. Use when the user says "vexana kur", "vexana init", "set up vexana", "network katmanını kur", or before /vexana:add in a project without vexana.
---

# vexana init

Targets vexana `^6.0.0`. Read `../add/references/vexana-api.md` and `../add/references/templates.md` (sections "Network setup" and "Fixture reader") before writing code.

## 1. Detect

1. Confirm `pubspec.yaml` exists and depends on the `flutter` SDK. If not, stop: this skill is for Flutter apps.
2. Read the vexana version from `pubspec.lock` (or `pubspec.yaml`). Below 6.0.0 → stop and suggest `/vexana:refactor`. Already set up (`AppNetworkManager` or another `NetworkManager(` construction exists in `lib/`) → report where and stop without changing any file.
3. Pick the network directory from the existing layout, first match wins:
   - `lib/product/service/` or `lib/product/network/` → `lib/product/network/`
   - `lib/core/` → `lib/core/network/`
   - `lib/src/` → `lib/src/core/network/`
   - otherwise → `lib/core/network/`

   Record the features root too: the first of `lib/features/`, `lib/feature/`, `lib/src/features/` that exists (even if empty), else `lib/features/`. Report both so `/vexana:add` uses the same ones (`{{networkPath}}` and `{{featurePath}}` in `templates.md`).
4. Note whether json_serializable, freezed, equatable or get_it are dependencies. Do not add any of them.

## 2. Ask only what was not given

- Base URL (used as `defaultValue`; the app can override it with `--dart-define=BASE_URL=...`).
- Cache: none, `LocalFile` or `LocalPreferences`.
- An error response JSON. If given, generate `api_error_model.dart` in the network directory with the "Model" template (class `ApiErrorModel`) and use `ApiErrorModel` as `{{E}}`; otherwise `{{E}}` is `EmptyModel`.

## 3. Dependencies

```bash
flutter pub add vexana:^6.0.0
flutter pub add dev:mocktail
```

## 4. Generate

- `lib/{{networkPath}}/app_network_manager.dart` from "Network setup". Keep the `errorModel:` line only with an error model, the `fileManager:` line only with a cache, and delete the template's two `//` instruction comments. Keep the `///` doc comment.
- `lib/{{networkPath}}/api_error_model.dart` only with an error JSON.
- `test/helpers/fixture_reader.dart` from "Fixture reader"; create `test/fixtures/`.

Never overwrite an existing file: if a target exists, leave it and say so.

## 5. Verify and report

Run `dart analyze` on the created files. Fix and retry at most twice; then report remaining issues verbatim.

Report:
- files created, and files skipped because they already existed;
- the network folder and the features root;
- how to pass the base URL: `flutter run --dart-define=BASE_URL=...`.
