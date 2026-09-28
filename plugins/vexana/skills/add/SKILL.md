---
name: add
description: Generate a vexana INetworkModel (with nested classes), a sendRequest service method and a round-trip model test from a JSON sample, a JSON file or an existing model, for a Flutter project using vexana 6.x. Use when the user says "vexana add", "bu JSON'dan model yap", "model oluştur", "servise endpoint ekle", "create a model from this JSON", or pastes a JSON response and wants it in the app.
---

# vexana add

Targets vexana `^6.0.0`. Read `references/vexana-api.md` and `references/templates.md` first; generate code only from those templates.

## 0. Preconditions

- Find the network setup (`AppNetworkManager` or a `NetworkManager<` construction in `lib/`). If there is none, stop and tell the user to run `/vexana:init`.
- Take `{{E}}` from that setup (`EmptyModel` or the generated error model), `{{networkPath}}` from its folder, and `{{package}}` from `pubspec.yaml` `name`.
- Features root: the first of `lib/features/`, `lib/feature/`, `lib/src/features/` that exists, even if it is empty; if none exists, `lib/features/`. `{{featurePath}}` is that root without `lib/`, plus the feature name: `features/post`.
- If the project uses json_serializable or freezed, still generate from the "Model" template, and tell the user the model was written by hand so they can convert it to their generator.
- Write every file under the project root you are working in, using paths relative to it.

## 1. Inputs

- JSON: pasted text, a file path, or an existing Dart model class to convert to `INetworkModel`.
- Read large JSON files only as far as needed to infer types (e.g. the first elements plus a key scan); do not echo them back.
- Optional: endpoint(s) as `METHOD /path` (`GET /posts`, `GET /posts/{id}`), feature name (default: the model name in snake_case), model name (default: from the path's last static segment, singular UpperCamel: `/posts` → `Post`).
- Invalid JSON → stop and show the parse error position. Do not guess.

## 2. Infer types

Apply the "Type inference" table and naming rules in `templates.md`. For a top-level array, infer from all elements. Collect every `Object?` and `List<Object?>?` field, and every key whose Dart field name differs from the key, for the report.

## 3. Check for collisions

If a class with the same name exists anywhere in `lib/`, or a target file exists, ask the user (reuse, rename, or skip) before writing anything. Do not write files for that input until they answer.

## 4. Write files

1. Model file (+ nested classes in the same file) from "Model".
2. If endpoints were given: create `<feature>_service.dart` from "Service" with only those methods, or add the methods (and interface entries) to the existing service.
3. Save the JSON sample to `test/fixtures/<model_snake>.json`, values unchanged:
   - input is a file → copy it with `cp <input> test/fixtures/<model_snake>.json`. Never re-type a file's contents: a large API response would be regenerated token by token.
   - input was pasted → write it as given.
4. Model test from "Model test" (array form for array samples). Make sure `test/helpers/fixture_reader.dart` has `dropNulls`.

## 5. Verify

```bash
dart analyze
flutter test test/{{featurePath}}/
```
Fix and retry at most twice; then report failures verbatim. Never edit a fixture or weaken an assertion to make a test pass.

## 6. Report

Files created/changed, the service methods added, values replaced in a fake sample, fields typed `Object?` / `List<Object?>?` (the sample did not show their type — ask the user to tighten them), and renamed keys (JSON key → Dart field).
