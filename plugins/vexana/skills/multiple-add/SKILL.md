---
name: multiple-add
description: Generate vexana models, services, fake services, mocktail service tests and model tests for several JSON samples at once (a folder, several files or a pasted list), deduplicating shared nested types. Use when the user says "vexana multiple add", "bu JSON'ların hepsini ekle", "toplu model/servis üret", "generate services and tests for these endpoints", or gives more than one JSON response to wire up.
---

# vexana multiple-add

Targets vexana `^6.0.0`. Uses the `add` skill's procedure and its templates: read `../add/SKILL.md`, `../add/references/vexana-api.md` and `../add/references/templates.md` first.

## 1. Plan and confirm

Collect every input (folder → each `*.json`; files; pasted blocks). For each, determine JSON source, model name, feature, endpoint(s) and method. Show this as a table and **wait for the user's confirmation before writing any file** — unless the user explicitly said to proceed without confirming. Invalid JSON in any input → stop and name the file and the parse error.

## 2. Deduplicate shared types

Across all inputs, nested object types with the same set of keys and the same field types are one class. Define it once, in the file of the first model that uses it, and import it elsewhere. Also reuse a top-level model if another input's nested type matches it exactly — for example `companies.json` elements with the same keys as `User.company` → one `Company` class, used by both.

## 3. Per model

Run `add` sections 0–4 (model, fixture, model test, service methods). Fixtures from files are copied with `cp`, never re-typed. A model reused from step 2 gets no second model file; its feature still gets its fixture and model test.

## 4. Per feature

- Service interface and implementation with all of the feature's endpoints ("Service").
- `Fake<Feature>Service` from "Fake service", embedding at most 3 elements of the fixture (shorten long strings; replace secrets and personal data as the template says).
- Service test from "Service test": a success and an error test per method.
- A test for the fake: it returns non-empty data.

## 5. Verify

```bash
dart analyze
flutter test
```
Fix and retry at most twice; then report failures verbatim. Never edit a fixture or weaken an assertion to make a test pass.

## 6. Report

A table of created files per feature, deduplicated types (which inputs share them), values replaced in fake samples, fields typed `Object?` / `List<Object?>?`, renamed keys, and the final test result line.
