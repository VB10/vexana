---
name: refactor
description: Migrate a Flutter project that already uses an older vexana (4.x or 5.x) to vexana 6.x — bumps the dependency, rewrites removed imports and immutable-model mutations, and flags call sites whose behaviour changed (removeAll, sendPrimitive, downloadFileSimple, cache keys). Use when the user says "vexana refactor", "vexana'yı güncelle", "6.x'e geçir", "migrate vexana", "upgrade vexana", or analyze errors appear after bumping vexana.
---

# vexana refactor

Target: vexana `^6.0.0`. Read `references/migration.md` and `../add/references/vexana-api.md` first. This skill only migrates vexana usage; it does not convert raw dio/http code or restyle models.

## 1. Detect the current version

Read the resolved vexana version from `pubspec.lock` (fallback: `pubspec.yaml`). Already 6.x → say so and stop without changing any file. No vexana → stop and suggest `/vexana:init`.

## 2. Baseline

Run `flutter test` before changing anything and keep the result, so migration regressions can be told apart from failures that already existed.

## 3. Scan and plan

For every rule in `migration.md` from the current version up to the target, run its Detect pattern over `lib/` and `test/`. Build a list: file:line, rule, action (edit / flag / ask). Show it and **wait for confirmation** — unless the user explicitly said to proceed. Ask the `ask` rules' questions now; a rule whose condition does not hold (e.g. the SDK constraint is already ≥ 3.6.0) is skipped and listed as "not needed".

## 4. Apply

Apply `edit` rules, set `vexana: ^6.0.0`, apply accepted `ask` rules, run `flutter pub get`.

## 5. Verify

`dart analyze`, then `flutter test`. Analyze errors caused by the migration: fix and retry at most twice. Do not change test expectations to make tests pass.

## 6. Report

- edits made (file:line, before → after);
- flagged call sites to review by hand, each with the rule's explanation;
- rules not needed, and why;
- test results compared with the baseline: newly failing tests (regressions) vs. failures that already existed.
