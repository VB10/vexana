# vexana v6 — Plan A: Ölçüm Zemini ve Monorepo

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** vexana'yı Melos monorepo'ya taşı, pub puanını 140'tan 160'a çıkar, ve sonraki planların performans iddialarını doğrulayacak benchmark zeminini kur.

**Architecture:** Mevcut tek paket `packages/vexana/`'ya taşınır; kök `pubspec.yaml` Dart native pub workspace kökü olur, Melos script katmanı olarak üstüne biner. Wasm uyumsuzluğu `dart.library.html` koşullarının `dart.library.js_interop`'a çevrilmesi ve `HttpStatus` için saf Dart shim'i ile çözülür. Benchmark paketi, Plan B'nin optimize edeceği kod yollarının **önce** ölçülmesini sağlar.

**Tech Stack:** Dart 3.12 / Flutter 3.44 · Melos · pub workspaces · `benchmark_harness` · `pana` · Codecov

## Global Constraints

- SDK constraint: `^3.6.0` (spec §5.3 — pub workspaces bunu zorunlu kılıyor)
- Yayınlanan paket adı `vexana`, konumu `packages/vexana/`
- Sürüm bu planın sonunda `6.0.0-dev.1` (spec §12 — her adım sonunda ön sürüm)
- Lint tabanı `package:very_good_analysis` (mevcut `^6.0.0` korunur)
- Hiçbir public API bu planda değişmez — sadece dosya konumu, build ve altyapı
- Mevcut 39 test dosyasının tamamı her task sonunda geçiyor olmalı

---

## Dosya yapısı

Bu planın sonunda repo:

```
vexana/
├── pubspec.yaml              workspace kökü (yayınlanmaz)
├── melos.yaml                script katmanı
├── analysis_options.yaml     paylaşılan lint tabanı
├── packages/
│   └── vexana/               ← yayınlanan paket
│       ├── pubspec.yaml
│       ├── lib/              (kökten taşındı)
│       └── test/             (kökten taşındı)
├── example/                  workspace üyesi
├── benchmark/                workspace üyesi · yayınlanmaz
│   ├── pubspec.yaml
│   ├── test/                 flutter test ile koşan benchmark'lar
│   └── RESULTS.md            baseline sayıları
└── .github/workflows/
    ├── pr_check.yml          analyze + test + coverage + wasm
    └── publish.yml           packages/vexana'dan yayınlar
```

Sorumluluklar:
- **kök `pubspec.yaml`** — sadece workspace üyelerini listeler ve melos'u dev dependency olarak tutar. Kod içermez.
- **`melos.yaml`** — `analyze` / `test` / `coverage` script'leri. Tek yerden tüm paketlerde koşar.
- **`benchmark/`** — Flutter binding gerektiren ölçümler (`compute`) `flutter test` altında koşar. Yayınlanmaz.

---

## Task 1: Melos + pub workspace'e taşı

**Files:**
- Create: `melos.yaml`
- Create: `packages/vexana/pubspec.yaml` (kökten taşınıp değiştirilir)
- Modify: `pubspec.yaml` (workspace köküne dönüştürülür)
- Modify: `example/pubspec.yaml`
- Move: `lib/` → `packages/vexana/lib/`
- Move: `test/` → `packages/vexana/test/`
- Move: `CHANGELOG.md`, `README.md`, `LICENSE` → `packages/vexana/` (pub bunları paket kökünde arar)

**Interfaces:**
- Consumes: yok (ilk task)
- Produces: `packages/vexana/` yolu — sonraki tüm task'lar ve Plan B/C bu yolu kullanır. Melos script'leri: `melos run analyze`, `melos run test`.

- [ ] **Step 1: Mevcut testlerin geçtiğini doğrula (baseline)**

Taşımadan önce yeşil olduğunu bil, yoksa taşıma mı bozdu bilemezsin.

```bash
flutter test 2>&1 | tail -5
```

Beklenen: tüm testler geçer. Geçen test sayısını not et — Step 8'de aynı sayı olmalı.

- [ ] **Step 2: Dosyaları git ile taşı**

`git mv` kullan, `mv` değil — geçmiş korunur.

```bash
mkdir -p packages/vexana
git mv lib packages/vexana/lib
git mv test packages/vexana/test
git mv CHANGELOG.md packages/vexana/CHANGELOG.md
git mv README.md packages/vexana/README.md
git mv LICENSE packages/vexana/LICENSE
git mv pubspec.yaml packages/vexana/pubspec.yaml
git rm pubspec.lock
```

- [ ] **Step 3: Paket pubspec'ini güncelle**

`packages/vexana/pubspec.yaml` içinde `environment` bloğunu değiştir ve `resolution` ekle:

```yaml
version: 6.0.0-dev.1

environment:
  sdk: ^3.6.0

resolution: workspace
```

`dependencies` ve `dev_dependencies` blokları aynen kalır. `resolution: workspace` satırı `environment` bloğundan sonra, `dependencies`'ten önce gelmeli.

- [ ] **Step 4: Workspace kökünü yaz**

Yeni `pubspec.yaml` (repo kökü):

```yaml
name: vexana_workspace
description: vexana monorepo workspace root. Not published.
publish_to: none

environment:
  sdk: ^3.6.0

workspace:
  - packages/vexana
  - example
```

- [ ] **Step 5: melos.yaml yaz**

```yaml
name: vexana

packages:
  - packages/*
  - example

scripts:
  analyze:
    run: dart analyze --fatal-infos --fatal-warnings
    description: Tüm paketleri analiz et

  test:
    run: melos exec --dir-exists=test -- flutter test
    description: Testi olan her pakette flutter test koş

  coverage:
    run: melos exec --dir-exists=test -- flutter test --coverage
    description: Coverage ile test koş
```

- [ ] **Step 6: Melos'u kök dev dependency olarak ekle**

Sürümü elle yazma — pub çözsün:

```bash
dart pub add dev:melos
```

- [ ] **Step 7: example'ı workspace üyesi yap**

`example/pubspec.yaml` içinde üç değişiklik:

```yaml
environment:
  sdk: ^3.6.0

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  vexana:
    path: ../packages/vexana
```

Ayrıca `dev_dependencies` içindeki `flutter_lints: ^1.0.4` satırını **sil** — 2021 sürümü, SDK 3.6 ile çözülmez ve tüm workspace resolution'ını bloklar.

```bash
git rm example/pubspec.lock
```

- [ ] **Step 8: Resolution ve testleri doğrula**

```bash
dart pub get
melos run test
```

Beklenen: `dart pub get` tek `pubspec.lock` üretir (repo kökünde). Test sayısı Step 1'deki ile aynı.

Eğer `dart pub get` "workspace" ile ilgili hata verirse: `dart --version` çıktısının 3.6+ olduğunu doğrula.

- [ ] **Step 9: analyze'ın hâlâ çalıştığını doğrula**

```bash
melos run analyze
```

Beklenen: Task 2'de düzeltilecek olan 3 issue görünür (`cascade_invocations`, `unnecessary_this`, `sort_pub_dependencies`). Bu task'ta düzeltilmiyorlar — sadece komutun çalıştığını doğruluyoruz.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "refactor: melos monorepo ve pub workspace yapısına geç

lib/, test/ ve paket metadata'sı packages/vexana/ altına taşındı.
Kök pubspec artık workspace kökü. SDK constraint ^3.6.0'a yükseltildi
(pub workspaces gerektiriyor). example workspace üyesi yapıldı ve
çözülemeyen flutter_lints ^1.0.4 kaldırıldı."
```

---

## Task 2: Lint issue'larını sıfırla

**Files:**
- Modify: `packages/vexana/lib/src/feature/adapter/web_adapter.dart:9`
- Modify: `packages/vexana/lib/src/network_manager.dart:275`
- Modify: `packages/vexana/pubspec.yaml` (dependency sıralaması)

**Interfaces:**
- Consumes: Task 1'in `packages/vexana/` yolu
- Produces: `melos run analyze` sıfır issue döner. Task 3 ve Plan B bu temiz tabanın üstüne yazar.

- [ ] **Step 1: pana baseline'ını al ve kaydet**

Kayıp puanın gerçek dağılımını gör — tahminle çalışma.

```bash
dart pub global activate pana
dart pub global run pana --no-warning packages/vexana 2>&1 | tail -40
```

Çıktıdaki puan tablosunu bir yere not et. Beklenen: 140/160, −10 wasm, −10 static analysis.

- [ ] **Step 2: cascade_invocations'ı düzelt**

`packages/vexana/lib/src/feature/adapter/web_adapter.dart`:

```dart
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// The function creates and returns an instance of the BrowserHttpClientAdapter
/// class, which implements the HttpClientAdapter
/// interface.
HttpClientAdapter createAdapter({bool isEnableTest = false}) {
  return HttpClientAdapter() as BrowserHttpClientAdapter
    ..withCredentials = true;
}
```

- [ ] **Step 3: unnecessary_this'i düzelt**

`packages/vexana/lib/src/network_manager.dart:275` civarındaki `download` override'ında `this.download(...)` çağrısı var. `this.` niteleyicisi burada **gerekli** olabilir — metot kendi adını çağırıyorsa `super.download` mu `this.download` mu olduğuna dikkat et.

Önce satırı oku:

```bash
sed -n '265,295p' packages/vexana/lib/src/network_manager.dart
```

`this.download` çağrısı `DioMixin`'in `download`'ına gidiyorsa ve `this.` kaldırıldığında sonsuz özyineleme oluşuyorsa, `this.`'i **kaldırma** — bunun yerine satıra ignore koy ve sebebini yaz:

```dart
// ignore: unnecessary_this — DioMixin.download ile ad çakışması, this. niyeti belirtiyor
```

Kaldırmak güvenliyse kaldır. Karar ölçütü: kaldırdıktan sonra Step 6'daki testler geçiyor mu?

- [ ] **Step 4: sort_pub_dependencies'i düzelt**

`packages/vexana/pubspec.yaml` içinde `dependencies` bloğunu alfabetik sırala. Mevcut yorum satırlarını (`# Core`, `# Log`, `# Database`, `# Utility`) **sil** — gruplama yorumları alfabetik sırayı bozuyor, lint'in şikayet ettiği şey bu.

```yaml
dependencies:
  collection: ^1.17.1
  dio: ^5.8.0+1
  dio_web_adapter: ^2.1.0
  equatable: ^2.0.5
  flutter:
    sdk: flutter
  logger: ^2.0.2+1
  path_provider: ^2.0.1
  retry: ^3.1.2
  shared_preferences: ^2.0.3
```

- [ ] **Step 5: analyze'ın temiz olduğunu doğrula**

```bash
melos run analyze
```

Beklenen: `No issues found!`

- [ ] **Step 6: Testlerin hâlâ geçtiğini doğrula**

```bash
melos run test
```

Beklenen: Task 1 Step 1'deki test sayısı, hepsi geçiyor.

- [ ] **Step 7: pana puanının 150'ye çıktığını doğrula**

```bash
dart pub global run pana --no-warning packages/vexana 2>&1 | tail -40
```

Beklenen: 150/160. Kalan −10 wasm, Task 3'te kapanacak.

Eğer hâlâ static analysis puanı eksikse: pana'nın çıktısındaki tam gerekçeyi oku. `dart doc` uyarıları da bu puana giriyor olabilir; çıktıda hangi dosya/satır dendiğini takip et ve düzelt.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "style: analyzer issue'larını temizle

cascade_invocations (web_adapter), unnecessary_this (network_manager),
sort_pub_dependencies (pubspec). pana static analysis puanı 0/10 -> 10/10."
```

---

## Task 3: wasm uyumu

**Files:**
- Create: `packages/vexana/lib/src/utility/http_status.dart`
- Modify: `packages/vexana/lib/src/model/error_model.dart:1`
- Modify: `packages/vexana/lib/src/mixin/network_manager_error_interceptor.dart:1`
- Modify: `packages/vexana/lib/src/utility/network_manager_util.dart:2`
- Modify: `packages/vexana/lib/src/network_manager.dart:6,9`
- Modify: `packages/vexana/lib/src/cache/file/local_file.dart:2`
- Modify: `packages/vexana/lib/src/utility/custom_logger.dart:3`
- Test: `packages/vexana/test/utils/http_status_test.dart`

**Interfaces:**
- Consumes: Task 2'nin temiz analyze tabanı
- Produces: `HttpStatus` sınıfı — `packages/vexana/lib/src/utility/http_status.dart`, statik `int` sabitler: `ok = 200`, `multipleChoices = 300`, `unauthorized = 401`, `clientClosedRequest = 499`, `internalServerError = 500`. Plan B ve C bu shim'i kullanır, `dart:io`'yu import etmez.

**Sabit listesi kodun tamamı taranarak çıkarıldı** (`grep -rn "HttpStatus\." lib/`) — bu beş sabit dışında kullanım yok. Yeni bir kullanım eklersen shim'e de eklemen gerekir, aksi halde derleme hatası alırsın.

**Arka plan:** Sorun `dart:io` değil, koşulun kendisi. `if (dart.library.html)` wasm derlemesinde **false** döner ve `dart:io` branch'ine düşer — wasm'da `dart:io` yok, derleme patlar. `dart.library.js_interop` doğru koşul. Ayrıca `HttpStatus` yalnızca `dart:io`'da var (`dart:html`'de yok), bu yüzden shim gerekiyor.

Web tarafındaki dosyaların (`local_file_web.dart`, `html_custom_override.dart`, `logger_web.dart`, `web_adapter.dart`, `html_path_provider.dart`) hiçbiri `dart:html` import etmiyor — doğrulandı. Yani sadece koşullar ve `HttpStatus` değişecek.

- [ ] **Step 1: HttpStatus shim'i için başarısız test yaz**

`packages/vexana/test/utils/http_status_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/utility/http_status.dart';

void main() {
  group('HttpStatus', () {
    test('dart:io ile aynı sabitleri verir', () {
      expect(HttpStatus.ok, 200);
      expect(HttpStatus.multipleChoices, 300);
      expect(HttpStatus.unauthorized, 401);
      expect(HttpStatus.clientClosedRequest, 499);
      expect(HttpStatus.internalServerError, 500);
    });
  });
}
```

- [ ] **Step 2: Testin başarısız olduğunu doğrula**

```bash
cd packages/vexana && flutter test test/utils/http_status_test.dart
```

Beklenen: FAIL — `http_status.dart` dosyası yok, import çözülemiyor.

- [ ] **Step 3: Shim'i yaz**

`packages/vexana/lib/src/utility/http_status.dart`:

```dart
/// Platform bağımsız HTTP durum kodları.
///
/// `dart:io`'nun `HttpStatus`'unun yerine geçer. `dart:io` wasm derlemesinde
/// bulunmadığı ve `dart:html`'de `HttpStatus` hiç olmadığı için vexana bu
/// sabitleri kendi taşır.
abstract final class HttpStatus {
  /// 200 OK
  static const int ok = 200;

  /// 300 Multiple Choices
  static const int multipleChoices = 300;

  /// 401 Unauthorized
  static const int unauthorized = 401;

  /// 499 Client Closed Request (nginx uzantısı)
  static const int clientClosedRequest = 499;

  /// 500 Internal Server Error
  static const int internalServerError = 500;
}
```

- [ ] **Step 4: Testin geçtiğini doğrula**

```bash
cd packages/vexana && flutter test test/utils/http_status_test.dart
```

Beklenen: PASS

- [ ] **Step 5: `dart:io` HttpStatus import'larını shim ile değiştir**

Üç dosyada ilk satırdaki koşullu import'u sil, yerine shim import'u koy.

`packages/vexana/lib/src/model/error_model.dart` — satır 1'i sil:
```dart
import 'dart:io' if (dart.library.html) 'dart:html' show HttpStatus;
```
yerine:
```dart
import 'package:vexana/src/utility/http_status.dart';
```

`packages/vexana/lib/src/mixin/network_manager_error_interceptor.dart` — satır 1'i sil:
```dart
import 'dart:io' if (dart.library.html) 'dart:html';
```
yerine:
```dart
import 'package:vexana/src/utility/http_status.dart';
```

`packages/vexana/lib/src/utility/network_manager_util.dart` — satır 2'yi sil:
```dart
import 'dart:io' if (dart.library.html) 'dart:html';
```
yerine:
```dart
import 'package:vexana/src/utility/http_status.dart';
```

- [ ] **Step 6: Kalan koşulları js_interop'a çevir**

Dört yerde `dart.library.html` → `dart.library.js_interop`:

`packages/vexana/lib/src/network_manager.dart` satır 6 ve 9:
```dart
import 'package:vexana/src/feature/adapter/native_adapter.dart'
    if (dart.library.js_interop) 'package:vexana/src/feature/adapter/web_adapter.dart'
    as adapter;
import 'package:vexana/src/feature/ssl/io_custom_override.dart'
    if (dart.library.js_interop) 'package:vexana/src/feature/ssl/html_custom_override.dart'
    as ssl;
```

`packages/vexana/lib/src/cache/file/local_file.dart` satır 2:
```dart
    if (dart.library.js_interop) 'local_file_web.dart' as adapter;
```

`packages/vexana/lib/src/utility/custom_logger.dart` satır 3:
```dart
    if (dart.library.js_interop) '../feature/logger/logger_web.dart' as logger;
```

- [ ] **Step 7: Hiç `dart.library.html` kalmadığını doğrula**

```bash
grep -rn "dart.library.html\|dart:html" packages/vexana/lib
```

Beklenen: hiç çıktı yok.

- [ ] **Step 8: Tüm testlerin geçtiğini doğrula**

```bash
melos run test
```

Beklenen: tüm testler geçer. `dart:io`'nun `HttpStatus`'u ile shim aynı değerleri taşıdığı için davranış değişmemeli.

- [ ] **Step 9: wasm derlemesinin gerçekten çalıştığını doğrula**

Asıl kanıt bu — pana puanı değil, derleyici.

```bash
cd example && flutter build web --wasm
```

Beklenen: derleme başarılı.

Hata alırsan çıktıdaki dosyayı takip et: `dart:io` kullanan başka bir yol kalmış olabilir (`local_file_io.dart` ve `io_custom_override.dart` `dart:io`'yu **koşulsuz** import ediyor ama bunlar conditional import'un io tarafı olduğu için wasm'da hiç yüklenmemeli — yükleniyorsa koşullardan biri atlanmıştır).

- [ ] **Step 10: pana puanının 160 olduğunu doğrula**

```bash
dart pub global run pana --no-warning packages/vexana 2>&1 | tail -40
```

Beklenen: 160/160.

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "fix: wasm uyumluluğu

dart.library.html koşulu wasm'da false döndüğü için dart:io branch'ine
düşülüyordu. Tüm koşullar dart.library.js_interop'a çevrildi.
HttpStatus için saf Dart shim'i eklendi (dart:io'ya özgü, dart:html'de yok).
pana 150/160 -> 160/160."
```

---

## Task 4: CI'ı yenile

**Files:**
- Modify: `.github/workflows/pr_check.yml`
- Modify: `.github/workflows/publish.yml`
- Delete: `scripts/code_coverage.sh`
- Modify: `packages/vexana/README.md` (coverage badge)

**Interfaces:**
- Consumes: Task 1'in melos script'leri (`melos run analyze`, `melos run coverage`)
- Produces: her PR'da analyze + test + coverage + wasm build doğrulaması. Plan B'nin regresyon testleri bu boru hattında koşacak.

**Arka plan (#121):** Mevcut `pr_check.yml`'daki son adım `github-script` ile PR'a yorum atıyor. Fork'tan gelen PR'larda `pull_request` event'i `GITHUB_TOKEN`'ı salt-okunur verir — üstteki `permissions: contents: write` bloğu bunu değiştirmez. "Resource not accessible by integration" hatasının sebebi bu. Yorum adımı zaten gereksiz: CI durumu PR'da görünüyor. Kaldırılıyor.

- [ ] **Step 1: pr_check.yml'i yeniden yaz**

```yaml
name: CI

on:
  pull_request:
    branches:
      - master
  workflow_dispatch:

permissions:
  contents: read

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Bağımlılıkları çöz
        run: dart pub get

      - name: Analiz
        run: dart pub global run melos run analyze

      - name: Test + coverage
        run: dart pub global run melos run coverage

      - name: Coverage yükle
        uses: codecov/codecov-action@v4
        with:
          files: packages/vexana/coverage/lcov.info
          fail_ci_if_error: false

  wasm-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Bağımlılıkları çöz
        run: dart pub get

      - name: wasm derle
        working-directory: example
        run: flutter build web --wasm
```

- [ ] **Step 2: melos'un CI'da erişilebilir olduğunu doğrula**

Yukarıdaki `dart pub global run melos` çağrısı melos'un global aktive edilmiş olmasını bekler. Kök `pubspec.yaml`'da dev dependency olarak durduğu için doğru çağrı `dart run melos`. Adımları düzelt:

```yaml
      - name: Analiz
        run: dart run melos run analyze

      - name: Test + coverage
        run: dart run melos run coverage
```

- [ ] **Step 3: publish.yml'i yeni yola göre güncelle**

```yaml
name: Publish to pub.dev

on:
  push:
    tags:
      - "publish_[0-9]+.[0-9]+.[0-9]+*"
  workflow_dispatch:

jobs:
  publish:
    permissions:
      id-token: write
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Bağımlılıkları çöz
        run: dart pub get

      - name: Testler
        run: dart run melos run test

      - name: Yayınla
        working-directory: packages/vexana
        run: dart pub publish --force
```

- [ ] **Step 4: Eski coverage script'ini sil**

`scripts/code_coverage.sh` içeriğinin çoğu zaten yorum satırı ve melos script'i onun yerini aldı.

```bash
git rm scripts/code_coverage.sh
rmdir scripts 2>/dev/null || true
```

- [ ] **Step 5: Coverage'ı lokalde çalıştır ve gerçek sayıyı öğren**

README'deki "%70" beyanı ölçülmemiş. Gerçek sayıyı öğren:

```bash
dart run melos run coverage
```

Sonra `packages/vexana/coverage/lcov.info` üzerinden yüzdeyi hesapla:

```bash
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=packages/vexana/coverage --report-on=lib 2>/dev/null | head -1 || \
  awk -F: '/^LF:/{f+=$2} /^LH:/{h+=$2} END{printf "coverage: %.1f%%\n", h/f*100}' packages/vexana/coverage/lcov.info
```

Çıkan sayıyı not et.

- [ ] **Step 6: README'deki coverage beyanını gerçek sayıyla değiştir**

`packages/vexana/README.md` içinde "%70" veya "70%" geçen yeri bul:

```bash
grep -n "70" packages/vexana/README.md
```

Ölçülmemiş beyanı sil, yerine Codecov badge'i koy (badge her zaman güncel kalır, elle yazılan sayı bayatlar):

```markdown
[![codecov](https://codecov.io/gh/VB10/vexana/branch/master/graph/badge.svg)](https://codecov.io/gh/VB10/vexana)
```

- [ ] **Step 7: Workflow YAML'larının geçerli olduğunu doğrula**

```bash
python3 -c "import yaml,sys; [yaml.safe_load(open(f)) for f in ['.github/workflows/pr_check.yml','.github/workflows/publish.yml']]; print('YAML geçerli')"
```

Beklenen: `YAML geçerli`

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "ci: analyze + coverage + wasm build ekle, #121'i düzelt

Fork PR'larında salt-okunur GITHUB_TOKEN nedeniyle patlayan github-script
yorum adımı kaldırıldı (#121). Coverage Codecov'a yükleniyor, wasm derlemesi
ayrı job'da doğrulanıyor. publish.yml packages/vexana yolundan yayınlıyor.
README'deki ölçülmemiş %70 beyanı badge ile değiştirildi."
```

---

## Task 5: Benchmark zemini ve baseline

**Files:**
- Create: `benchmark/pubspec.yaml`
- Create: `benchmark/test/json_decode_benchmark_test.dart`
- Create: `benchmark/test/list_parse_benchmark_test.dart`
- Create: `benchmark/RESULTS.md`
- Modify: `pubspec.yaml` (workspace'e `benchmark` ekle)
- Modify: `melos.yaml` (packages listesine `benchmark` ekle)

**Interfaces:**
- Consumes: `packages/vexana/lib/src/mixin/network_manager_response.dart`'taki mevcut liste parse mantığı
- Produces: `benchmark/RESULTS.md` — Plan B'nin P1 ve P5 maddelerinin kabul kriteri. Plan B her optimizasyondan sonra bu dosyayı güncelleyecek.

**Bu task neden optimizasyondan önce:** Spec §11-T3 diyor ki "dio'nun `BackgroundTransformer`'ının her yanıtta compute çağırdığı ve bunun küçük payload'da kayıp olduğu **ölçülerek** doğrulanacak; C4/P1'in tamamı buna dayanıyor". Ölçüm P1'i doğrulamazsa **P1 düşer.** Bu task o kararı verecek veriyi üretir.

- [ ] **Step 1: benchmark paketini oluştur**

`benchmark/pubspec.yaml`:

```yaml
name: benchmark
description: vexana performans ölçümleri. Yayınlanmaz.
publish_to: none

environment:
  sdk: ^3.6.0

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  vexana:
    path: ../packages/vexana

dev_dependencies:
  flutter_test:
    sdk: flutter
```

- [ ] **Step 2: workspace ve melos'a kaydet**

Kök `pubspec.yaml`:

```yaml
workspace:
  - packages/vexana
  - example
  - benchmark
```

`melos.yaml`:

```yaml
packages:
  - packages/*
  - example
  - benchmark
```

- [ ] **Step 3: Resolution'ı doğrula**

```bash
dart pub get
```

Beklenen: hata yok, `benchmark` workspace üyesi olarak çözülür.

- [ ] **Step 4: compute vs senkron decode ölçümünü yaz**

`benchmark/test/json_decode_benchmark_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verilen boyutta gerçekçi bir JSON gövdesi üretir.
String makeBody(int itemCount) {
  final items = List.generate(
    itemCount,
    (i) => {
      'id': i,
      'title': 'item $i başlık metni',
      'completed': i.isEven,
      'tags': ['a', 'b', 'c'],
    },
  );
  return jsonEncode(items);
}

Future<Duration> timeAsync(Future<void> Function() body, int runs) async {
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    await body();
  }
  sw.stop();
  return Duration(microseconds: sw.elapsedMicroseconds ~/ runs);
}

Duration timeSync(void Function() body, int runs) {
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    body();
  }
  sw.stop();
  return Duration(microseconds: sw.elapsedMicroseconds ~/ runs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('compute vs senkron jsonDecode — payload boyutuna göre', () async {
    final sizes = <String, int>{
      'küçük (~200B)': 1,
      'orta (~20KB)': 150,
      'büyük (~2MB)': 15000,
    };

    final lines = <String>[];
    for (final entry in sizes.entries) {
      final body = makeBody(entry.value);
      final runs = entry.value > 1000 ? 5 : 50;

      final sync = timeSync(() => jsonDecode(body), runs);
      final async = await timeAsync(() async => compute(jsonDecode, body), runs);

      lines.add(
        '| ${entry.key} | ${body.length} B | '
        '${sync.inMicroseconds} µs | ${async.inMicroseconds} µs | '
        '${(async.inMicroseconds / sync.inMicroseconds).toStringAsFixed(1)}x |',
      );
    }

    // ignore: avoid_print — benchmark çıktısı
    print('\n| payload | boyut | senkron | compute | oran |');
    // ignore: avoid_print
    print('|---|---|---|---|---|');
    for (final l in lines) {
      // ignore: avoid_print
      print(l);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
```

- [ ] **Step 5: Ölçümü çalıştır ve sayıları oku**

```bash
cd benchmark && flutter test test/json_decode_benchmark_test.dart --reporter expanded
```

Beklenen: tablo yazdırılır. **Sayıları kaydet** — Step 8'de RESULTS.md'ye gidecekler.

Yorumlama: `oran > 1` ise compute o boyutta **kayıp**. Küçük payload'da oranın 1'in belirgin üstünde olması beklenir (isolate spawn maliyeti). Büyük payload'da 1'in altına inmesi beklenir.

- [ ] **Step 6: Mevcut liste parse ölçümünü yaz**

`benchmark/test/list_parse_benchmark_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

/// Mevcut implementasyon:
/// network_manager_response.dart:118-126
/// whereType().toList() -> map().cast<T>().toList()
List<Todo> currentImpl(List<dynamic> body, Todo model) {
  final items = body.whereType<Map<String, dynamic>>().toList();
  return items.map(model.fromJson).cast<Todo>().toList();
}

/// Plan B'de gelecek tek geçişli hali. Karşılaştırma tabanı.
List<Todo> singlePass(List<dynamic> body, Todo model) {
  final out = <Todo>[];
  for (final item in body) {
    if (item is Map<String, dynamic>) out.add(model.fromJson(item));
  }
  return out;
}

class Todo {
  const Todo({this.id, this.title});
  final int? id;
  final String? title;

  Todo fromJson(Map<String, dynamic> json) =>
      Todo(id: json['id'] as int?, title: json['title'] as String?);
}

Duration timeSync(void Function() body, int runs) {
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    body();
  }
  sw.stop();
  return Duration(microseconds: sw.elapsedMicroseconds ~/ runs);
}

void main() {
  test('liste parse — mevcut vs tek geçiş', () {
    const model = Todo();
    for (final count in [10, 1000, 50000]) {
      final body = List<dynamic>.generate(
        count,
        (i) => <String, dynamic>{'id': i, 'title': 'item $i'},
      );
      final runs = count > 10000 ? 20 : 200;

      final current = timeSync(() => currentImpl(body, model), runs);
      final single = timeSync(() => singlePass(body, model), runs);

      // ignore: avoid_print
      print(
        '| $count eleman | ${current.inMicroseconds} µs | '
        '${single.inMicroseconds} µs | '
        '${(current.inMicroseconds / single.inMicroseconds).toStringAsFixed(2)}x |',
      );
    }
  });
}
```

- [ ] **Step 7: Liste parse ölçümünü çalıştır**

```bash
cd benchmark && flutter test test/list_parse_benchmark_test.dart --reporter expanded
```

Beklenen: her satır için üç sayı. `oran > 1` ise tek geçiş daha hızlı.

- [ ] **Step 8: RESULTS.md'yi gerçek sayılarla yaz**

`benchmark/RESULTS.md` — Step 5 ve Step 7'nin **gerçek çıktılarını** yapıştır, uydurma:

```markdown
# vexana benchmark — baseline

> Ölçüm tarihi: <bugünün tarihi>
> Ortam: <flutter --version çıktısının ilk satırı> · <cihaz/OS>
> Commit: <git rev-parse --short HEAD>

Bu sayılar Plan B'nin optimizasyon öncesi tabanıdır. Her optimizasyondan
sonra bu dosya güncellenir ve öncesi/sonrası karşılaştırılır.

## compute() vs senkron jsonDecode

| payload | boyut | senkron | compute | oran |
|---|---|---|---|---|
<Step 5 çıktısı buraya>

**Yorum:** <oran 1'in üstündeyse: "compute küçük payload'da kayıp; spec P1
doğrulandı". Altındaysa: "compute bu boyutlarda da kazançlı; spec P1 gözden
geçirilmeli">

## Liste parse

| eleman | mevcut | tek geçiş | oran |
|---|---|---|---|
<Step 7 çıktısı buraya>

**Yorum:** <ölçüme göre>

## Karar

- **P1 (transformer eşiği):** <doğrulandı | düşürüldü> — gerekçe
- **P5 (tek geçiş parse):** <doğrulandı | düşürüldü> — gerekçe
```

- [ ] **Step 9: Benchmark'ların CI'ı yavaşlatmadığını doğrula**

Benchmark testleri `melos run test` ile koşuyorsa CI'ı uzatır. `melos.yaml`'daki test script'inden hariç tut:

```yaml
  test:
    run: melos exec --dir-exists=test --ignore="benchmark" -- flutter test
    description: Testi olan her pakette flutter test koş (benchmark hariç)
```

Doğrula:

```bash
dart run melos run test
```

Beklenen: benchmark paketi atlanır, sadece `packages/vexana` testleri koşar.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "test: benchmark zemini ve baseline ölçümleri

compute() vs senkron jsonDecode ve liste parse ölçümleri eklendi.
Plan B'deki P1 ve P5 optimizasyonlarının kabul kriteri RESULTS.md.
Benchmark'lar CI test koşusundan hariç tutuldu."
```

---

## Task 6: 6.0.0-dev.1 ön sürümünü yayınla

**Files:**
- Modify: `packages/vexana/CHANGELOG.md`

**Interfaces:**
- Consumes: Task 1-5'in tamamı
- Produces: pub.dev'de `6.0.0-dev.1`. Spec §10-R1'in azaltma stratejisi: kararlı sürüm tek atış kalır ama aylarca sessizlik olmaz.

- [ ] **Step 1: CHANGELOG'a giriş ekle**

`packages/vexana/CHANGELOG.md` en üstüne:

```markdown
# [6.0.0-dev.1]

> Ön sürüm. `pub` bunu varsayılan olarak çözmez; mevcut 5.x kullanıcıları etkilenmez.

- Melos monorepo ve pub workspace yapısına geçildi (#65)
- SDK constraint `^3.6.0`'a yükseltildi
- WebAssembly uyumluluğu düzeltildi — `dart.library.html` koşulları
  `dart.library.js_interop` ile değiştirildi, `HttpStatus` için saf Dart shim'i eklendi
- Tüm analyzer issue'ları temizlendi — pub points 140 → 160
- CI: analiz, coverage ve wasm derlemesi eklendi; fork PR'larında patlayan
  yorum adımı kaldırıldı (#121)
- Benchmark zemini eklendi

**Public API değişmedi.** Bu sürüm yapı, build ve altyapı çalışmasıdır.
```

- [ ] **Step 2: Yayın öncesi kontrolü çalıştır**

```bash
cd packages/vexana && dart pub publish --dry-run
```

Beklenen: uyarı yok. Uyarı varsa düzelt — özellikle eksik dosya (README/CHANGELOG/LICENSE `packages/vexana/` altında olmalı, Task 1 Step 2'de taşındı).

- [ ] **Step 3: Commit ve tag**

```bash
git add -A
git commit -m "chore: 6.0.0-dev.1 sürümü"
git tag publish_6.0.0-dev.1
```

- [ ] **Step 4: Push (kullanıcı onayı ile)**

Tag push'u `publish.yml`'ı tetikler ve pub.dev'e **gerçekten yayınlar**. Bu geri alınamaz —
pub.dev'de sürüm silinemez. Push etmeden önce kullanıcıya sor.

```bash
git push origin <branch>
git push origin publish_6.0.0-dev.1
```

---

## Plan A tamamlandığında

- `melos run analyze` → sıfır issue
- `melos run test` → 39 test dosyası geçiyor, coverage ölçülüyor
- `flutter build web --wasm` → çalışıyor
- pana → 160/160
- `benchmark/RESULTS.md` → P1 ve P5 hakkında **veriye dayalı** karar
- pub.dev'de `6.0.0-dev.1`

**Sonraki:** Plan B — core performans (P1-P7) ve hata düzeltmeleri (F1-F5). Plan B'nin ilk task'ı `benchmark/RESULTS.md`'yi okuyup P1'in hâlâ geçerli olup olmadığını teyit etmekle başlar.
