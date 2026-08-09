# vexana v6 — Tasarım Dokümanı

> Tarih: 10 Ağustos 2026
> Durum: tasarım onaylandı, implementasyon planı bekliyor
> Sahip: VB10

---

## 1. Bağlam

Bu doküman, `vexana` paketinin modernizasyonu için yapılan tasarım çalışmasının çıktısıdır.
Girdi olarak alınan teknik borç dokümanı pub.dev metadata ve README üzerinden yazılmıştı;
bu tasarım öncesinde kaynak kod satır satır okunarak o dokümanın iddiaları doğrulandı.

### 1.1 Doğrulanan durum tespiti

Aşağıdakiler kodda teyit edildi (10 Ağustos 2026, `release/5.1.0` @ `700c4c8`):

| İddia | Sonuç |
|---|---|
| "master'da yayınlanmamış FormData/uploadFile var" | **YANLIŞ.** `git diff 3d0df9c..HEAD -- lib/` boş. `lib/` yayınlanan 5.0.3 ile birebir aynı. `uploadFile` ve `IFormDataModel` en az 5.0.2'den beri yayında. |
| "6 static analysis issue" | **KISMEN.** `flutter analyze` 3 issue veriyor (`cascade_invocations`, `unnecessary_this`, `sort_pub_dependencies`). Kalan 3'ü pana'nın dartdoc tarafı. |
| "dart:io yaygın kullanımda" | **KISMEN.** 5 dosya, 3'ü zaten conditional import. Gerçek wasm blocker `dart:io` değil, koşulun kendisi: `if (dart.library.html)` wasm'da false döner ve `dart:io` branch'ine düşer. |
| "Flutter'a hard dependency" | **DOĞRU ama sebebi farklı.** `BuildContext` sadece `no_network/` altında 3 dosyada (kolay ayrılır). Asıl bağ `compute()` — parse ve cache yollarında, 10 dosya `flutter/foundation` import ediyor. |
| "INetworkModel inheritance sürtünmesi" | **DOĞRU.** 27 generic constraint sitesi. `T fromJson(...)` bir *instance* metodu; `parseModel: Todo()` API'sinin sebebi tercih değil zorunluluk. |
| "%70 test coverage" | **ÖLÇÜLMEMİŞ.** 39 test dosyası var, CI'da coverage adımı yok, lcov üretilmiyor. |

### 1.2 Dokümanda olmayan, kodda bulunan sorunlar

**C1 — Cache key endpoint içermiyor.** `lib/src/mixin/network_manager_cache.dart:18`

```dart
String _urlKeyOnLocalData(RequestType type) =>
    '${parameters.baseOptions.baseUrl}-${type.stringValue}';
```

Key = baseUrl + HTTP metodu. Path, query, header yok. Aynı `NetworkManager` üzerinden
`GET /todos` ve `GET /users` **aynı cache kaydını paylaşıyor**. Parse başarısız olursa
`ErrorModel.parseError()` döner; şekiller uyuşursa sessizce yanlış veri döner.
`removeAll` da `baseUrl` bazlı, tek endpoint invalidate edilemiyor.

Bu, issue #73'ün ("cache nasıl çalışıyor?") 3 yıldır cevapsız kalmasını açıklıyor —
yazılabilir bir davranış değil.

**C2 — Retry sayacı paylaşımlı mutable state.** `network_manager_core_operation.dart:7`
`int _noNetworkTryCount = 0;` mixin instance'ında. Aynı manager'dan eşzamanlı iki istek
aynı sayacı eziyor.

**C3 — Constructor process-genelinde yan etki yapıyor.** `_setup()` içindeki
`ssl.createAdapter().make()` `HttpOverrides.global`'ı set ediyor. Bir `NetworkManager`
nesnesi yaratmak, uygulamanın tamamının HTTP davranışını değiştiriyor.

**C4 — Her yanıtta isolate spawn.** `network_manager_initialize.dart:14` hiç `transformer`
set etmiyor → dio varsayılanı `BackgroundTransformer` → her yanıtta `compute(jsonDecode, ...)`.
200 byte'lık bir gövde için isolate spawn + string kopyası ödeniyor. Cache yolu ikinci
(`network_manager_cache.dart:31`, `:56`), `preferences.dart:65` üçüncü compute'u ekliyor.

**C5 — Refresh token yolunda tekrarlı ağır kurulum.** `network_manager_error_interceptor.dart`
- `_createError:80` her retry denemesinde yeni bir `NetworkManager<EmptyModel>` kuruyor (`_setup()` dahil)
- `_createNewRequest:95` her denemede yeni bir `Dio(...)` kuruyor → yeni `HttpClient` → yeni
  connection pool → TCP + TLS handshake baştan

`maxRetryCount: 3` ile tek bir 401, üç manager + üç Dio üretiyor.

**C6 — Liste parse'ı iki kez kopyalıyor.** `network_manager_response.dart:118-126`
`whereType().toList()` → `.map().cast<T>().toList()`.

**C7 — Refresh sonrası header sözleşmesi yazısız.** `_createNewRequest` `error.requestOptions.headers`'ı
olduğu gibi kopyalıyor. Retry'ın *yeni* token'la gitmesi, kullanıcının `onRefreshToken`
callback'inin döndürdüğü exception'ın `requestOptions`'ını güncellemiş olmasına bağlı.
Bu sözleşme hiçbir yerde belgelenmemiş; #119'un kökeni büyük ihtimalle burası.

**C8 — `errorResponseFetch` alan kaybediyor.** `ErrorModel`'i elle yeniden kurarken
`DioExceptionType` ve stack trace düşüyor.

---

## 2. Kararlar

Tasarım sürecinde alınan ve implementasyonu bağlayan kararlar:

| # | Karar | Gerekçe |
|---|---|---|
| K1 | Debugger, UI'sız ortak çekirdek + üç görünüm (DevTools / in-app / playground) | Üç yüzey tek mantığı paylaşır; website demosu bedavaya gelir |
| K2 | Tek atışta `6.0.0` (katmanlı 5.2.0 değil) | Sahibin tercihi. Riski `6.0.0-dev.N` ön sürümleriyle azaltılır |
| K3 | Tester paneli ayrı pakette (`vexana_inspector_ui`) + zorunlu policy | Production garantisi **derleme zamanında**; runtime `if`'e güvenilmez |
| K4 | Docs sitesi + gömülü canlı Flutter Web playground | Konumlandırma sorununu (README'de gömülü anlatı) çözer |
| K5 | CLI **yok**, sadece skill reposu | 2026'da iskele üretimi ajanla yapılıyor; CLI skill'in bakımı zorunlu kötü kopyası olurdu |
| K6 | Inspector `6.1.0`'a ertelendi; `NetworkObserver` hook `6.0.0`'da kalır | Breaking sürümde API yüzeyi donar, inspector additive biner |
| K7 | DevTools eklentisi `vexana`'ya değil `vexana_inspector`'a paketlenir | Derlenmiş eklenti ~1-3MB; #120'de paket boyutu zaten optimize edilmişti |
| K8 | Refresh için ayrı manager kurulmaya devam edilir | Sahibin düzeltmesi: `onRefreshToken == null` olan temiz instance, refresh isteğinin kendi 401 interceptor'ını tetikleyip sonsuz döngüye girmesini engelliyor. İzolasyon kasıtlı ve doğru. |

---

## 3. Kapsam

### 6.0.0
Core performans + hata düzeltmeleri + API modernizasyonu + `NetworkObserver` hook +
`VexanaMock` + skills reposu + docs sitesi + playground.

### 6.1.0
`vexana_inspector` çekirdeği + DevTools eklentisi + in-app overlay + certificate pinning.

### Backlog (6.2.0+)
Offline mutation queue, SSE/streaming response, Hive cache implementasyonu, saf Dart
`vexana_core` ayrımı.

> **Saf Dart ayrımı neden backlog'da:** Talep henüz doğrulanmadı. `compute()` bağımlılığı
> parse ve cache yollarında olduğu için `Isolate.run` soyutlaması gerektiriyor — büyük iş.
> Ölçme yolu: `6.0.0-dev` RFC'sine gelen geri bildirim.

---

## 4. Mimari

### 4.1 Paket düzeni (Melos monorepo)

```
vexana/
├── packages/
│   ├── vexana/                  ana paket · NetworkManager · NetworkObserver
│   ├── vexana_inspector/        [6.1.0] UI'sız çekirdek + DevTools eklentisi
│   │   └── extension/devtools/  derlenmiş eklenti
│   ├── vexana_inspector_ui/     [6.1.0] in-app overlay · dev_dependency
│   └── vexana_devtools_app/     [6.1.0] eklentinin kaynağı · yayınlanmaz
├── apps/
│   └── playground/              Flutter Web · site'a gömülür
├── site/                        VitePress docs
├── skills/                      AI ajan skill'leri · docs'un tek kaynağı
└── benchmark/                   package:benchmark_harness
```

Melos issue #65'in talebini de karşılar.

### 4.2 Observability çekirdeği

Debugger'ın, playground'un ve enterprise observability'nin tek hook'tan beslenmesi
tasarımın belkemiği.

```dart
extension type const RequestId(String value) {}

sealed class NetworkEvent {
  const NetworkEvent({required this.id, required this.at});
  final RequestId id;
  final DateTime at;
}

final class RequestStarted extends NetworkEvent {
  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final Object? body;
}

final class ResponseReceived extends NetworkEvent {
  final int? statusCode;
  final Map<String, String> headers;
  final Object? body;
  final int? contentLength;
  final Duration elapsed;
}

final class RequestFailed extends NetworkEvent {
  final DioExceptionType type;
  final int? statusCode;
  final String? message;
  final Object? body;
  final Duration elapsed;
}

final class CacheHit extends NetworkEvent {
  final String cacheKey;
  final Duration age;
  final bool stale;          // staleWhileRevalidate ayrımı için
}

final class RetryScheduled extends NetworkEvent {
  final int attempt;         // 1-tabanlı
  final int maxAttempts;
  final Duration delay;
  final String reason;       // 'status:500' · 'timeout' · 'retry-after'
}

final class TokenRefreshed extends NetworkEvent {
  final bool success;
  final int attempt;
}
```

Alan seçimleri inspector'ın 6.1.0 ihtiyaçlarından türetildi: cURL üretimi `method`/`uri`/
`headers`/`body` ister, başarılı-başarısız ayrımı `statusCode` ister, retry zinciri
gruplaması ortak `id` + `attempt` ister. `id` tüm zincir boyunca sabit kalır — bir isteğin
`RequestStarted → RetryScheduled → TokenRefreshed → ResponseReceived` olayları aynı
`RequestId`'yi taşır.

```dart

abstract interface class NetworkObserver {
  void onEvent(NetworkEvent event);
}
```

**Sıfır maliyet garantisi.** Çağrı yerleri şu formu kullanır:

```dart
observer?.onEvent(ResponseReceived(...));
```

Dart'ta `?.` seçici zincirin tamamını kısa devre yapar; `observer` null ise argüman
**hiç değerlendirilmez**, dolayısıyla event nesnesi oluşturulmaz. Production'da maliyet
tek null check. Bu, hook'u core'a koymanın önkoşuluydu.

**Uygulama kuralı:** hiçbir çağrı yeri event nesnesini ayrı bir değişkende önceden
kurmayacak. Bu kural bir lint testi ile korunur (aşağıda §9).

`CacheHit` ve `RetryScheduled` bilerek birinci sınıf event. Bugün vexana'nın cache'i ve
retry'ı tamamen görünmez — çalışıp çalışmadığını kimse bilmiyor.

`MultiObserver` kombinatörü birden fazla gözlemciyi (inspector + Crashlytics + metrics)
tek hook'a bağlar.

---

## 5. 6.0.0 — Core

### 5.1 Performans

Sıra önemli: **önce `benchmark/`, sonra optimizasyon.** "İyileştirdim" iddiasının ölçüsü olmalı.

| # | Değişiklik | Dosya | Not |
|---|---|---|---|
| P1 | `SyncTransformer(contentLengthIsolateThreshold:)` | `mixin/core/network_manager_initialize.dart:14` | Varsayılan 50KB, `NetworkManager(isolateThreshold:)` ile ayarlanabilir |
| P2 | Refresh manager'ı manager başına **bir kez** kur | `mixin/network_manager_error_interceptor.dart:80` | K8 gereği ayrı instance kalır, sadece tekrarı biter |
| P3 | Refresh `Dio`'sunu manager başına bir kez kur | `...error_interceptor.dart:95` | 3x → 1x |
| P4 | Refresh transport'unu ana adapter ile paylaş | `...error_interceptor.dart:95` | Connection pool + TLS session yeniden kullanılır. **Teyit gerekli** (§11-T2) |
| P5 | Liste parse tek geçiş | `mixin/network_manager_response.dart:118` | `whereType→toList→map→cast→toList` yerine tek `for` |
| P6 | Cache okumada gereksiz `compute` kaldır | `mixin/network_manager_cache.dart:31,56` · `cache/shared/preferences.dart:65` | P1'deki eşiğe tabi olur |
| P7 | Connection pool ayarlarını dışa aç | yeni | `maxConnectionsPerHost`, `persistentConnection` |

**P1 uyarısı:** Eşik değişikliği ölçmeden kazanç değil. Büyük payload'lı bir kullanıcı için
`BackgroundTransformer` doğru seçim olabilir. Bu yüzden eşik **yapılandırılabilir**, sabit değil.

**Benchmark kapsamı:** 200B / 20KB / 2MB payload; cold vs warm connection; cache okuma;
allocation sayımı. Sonuçlar docs sitesinde tablo olarak yayınlanır.

### 5.2 Hata düzeltmeleri

| # | Düzeltme | Kaynak |
|---|---|---|
| F1 | Cache key'e path + normalize query ekle; `keyBuilder` ile özelleştirilebilir | C1 |
| F2 | Retry sayacını request-scoped yap | C2 |
| F3 | `HttpOverrides.global` yan etkisini adapter'a hapset | C3 |
| F4 | `errorResponseFetch` `DioExceptionType` ve stack trace'i korusun | C8 |
| F5 | `parseUserResponseData`'daki ölü `R is EmptyModel` kontrolünü temizle | — |

**F1 cache geçişi:** Yeni key şeması `v2:` önekiyle yazılır. Eski kayıtlar okunmaz,
otomatik olarak terk edilir. Kullanıcı tarafında etki: sürüm yükseltmesinden sonra bir
kereye mahsus cache miss. `MIGRATION.md`'de belgelenir.

Query parametreleri key'e girmeden önce **alfabetik sıralanır**, aksi halde
`?a=1&b=2` ile `?b=2&a=1` farklı key üretir.

### 5.3 API modernizasyonu

**Parse API'si.** `INetworkModel` ve `parseModel:` korunur (deprecate edilir, kırılmaz),
yanına fonksiyon referansı alternatifi gelir:

```dart
// eski — çalışmaya devam eder, @Deprecated
send<Todo, List<Todo>>('/todos', parseModel: Todo(), method: RequestType.GET);

// yeni
sendRequest<Todo, List<Todo>>('/todos', fromJson: Todo.fromJson, method: RequestType.GET);
```

`fromJson` tipi `T Function(Map<String, dynamic>)`. Bu, `freezed` / `json_serializable`
kullanan ekiplerin `INetworkModel` extend etme zorunluluğunu kaldırır.

**Diğer:**

- `send` → `@Deprecated`, `sendRequest` (sealed `NetworkResult`) tek yol
- `INetworkManager`'a `options` erişimi — issue #80 kapanır
- `RetryPolicy(maxAttempts, backoff: Backoff.exponential(jitter: true), retryOn, respectRetryAfter)`
  — `jitter` ve `respectRetryAfter` olmadan bir backend hıçkırığı thundering herd'e döner
- `DedupePolicy.inFlight` — uçuştaki aynı isteği paylaştır; liste ekranlarındaki çift
  çağrıyı kökten çözer, rakiplerde nadir
- `CachePolicy`: `none` | `maxAge` | `staleWhileRevalidate` (ETag + `If-None-Match`, 304 desteği)
- `NetworkManager(adapter:)` — `HttpClientAdapter` enjeksiyonu. `VexanaMock` (§5.4) ve
  playground (§7) buna dayanır; bugün adapter `_setup()` içinde sabit kuruluyor ve
  dışarıdan verilemiyor
- `NetworkManager(observer:)` — `NetworkObserver` enjeksiyonu (§4.2)
- `NetworkManager(isolateThreshold:)` — P1'in eşiği
- SDK constraint `>=3.6.0 <4.0.0`
- Interface'ler `abstract interface class`
- wasm: tüm `if (dart.library.html)` koşulları `if (dart.library.js_interop)` olur;
  `HttpStatus` için `dart:io`/`dart:html`'den bağımsız sabit shim'i
  (`error_model.dart`, `network_manager_error_interceptor.dart`, `network_manager_util.dart`)
- Lint: 3 `flutter analyze` issue + dartdoc escape'leri → pub points 140 → 160

### 5.4 `VexanaMock`

```dart
final mock = VexanaMock()
  ..onGet('/todos', reply: 200, body: [{'id': 1}])
  ..onPost('/todos', reply: 422, body: {'error': 'invalid'});

final manager = NetworkManager(options: ..., adapter: mock.adapter);
```

6.0.0'da olması şart, çünkü `vexana-test` skill'i buna dayanıyor ve playground'un mock
adapter'ı da bunu kullanıyor.

---

## 6. Skills reposu

`skills/` altında yazılır. **Hem AI ajanlarının okuduğu skill hem docs sitesinin içerik
kaynağıdır** — tek yerde güncellenir, iki yerde görünür. Aksi halde 6 ay içinde skill ile
docs birbirini tutmaz.

| Skill | Kapsam |
|---|---|
| `vexana-setup` | `NetworkManager` kurulumu, flavor/baseUrl, interceptor, **refresh token header sözleşmesi** (C7) |
| `vexana-endpoint` | Model + service metodu ekleme; mapper seçimi |
| `vexana-import` | Postman collection / OpenAPI / HAR → service + model + `VexanaMock` fixture |
| `vexana-test` | `VexanaMock` ile unit test |
| `vexana-migrate` | 5.x → 6.0 geçişi |

**Mapper varsayılanı:** build_runner'sız düz model (elle yazılmış `toJson`/`fromJson`,
bir kez üretilir). `freezed` / `json_serializable` çıktısı açıkça istendiğinde üretilir.
Varsayılanın build_runner'sız olması konumlandırmayla tutarlı.

**Konumlandırma notu.** Bu yaklaşım "codegen'siz" iddiasını bozmaz, güçlendirir:

> retrofit: her build öncesi `build_runner`, `.g.dart` dosyaları repoda, watch süreci
> vexana: bir kez üretilir, çıktı senin kodun olur, aracı bir daha çalıştırmak zorunda değilsin

**`vexana-migrate`'in stratejik değeri.** Migration guide bir skill olunca okunacak
doküman olmaktan çıkıp çalıştırılabilir hale geliyor. 647 haftalık indirmelik kırılgan
tabanı breaking sürümde korumanın en gerçekçi yolu bu.

---

## 7. Docs sitesi + playground

`site/` — VitePress, GitHub Pages. İçeriği `skills/`'ten beslenir.

```
/              vexana nedir · neden retrofit değil (konumlandırma paragrafı)
/docs          kurulum · cache · retry · formdata · refresh token
/benchmarks    ölçüm sonuçları
/playground    canlı Flutter Web
/migration     5.x → 6.0
```

`apps/playground` — gerçek vexana çalıştıran Flutter Web app'i. İstekler `VexanaMock`
adapter'ına gider: CORS yok, rate limit yok, demo her zaman çalışır.

Kullanıcı `RetryPolicy`, `CachePolicy`, `dedupe` seçeneklerini değiştirir; `NetworkObserver`
üzerinden akan event'leri yandaki listede anında görür. Bu liste 6.1.0'da inspector'ın
temeli olur — yani playground, observer API'sinin ilk gerçek tüketicisi ve tasarım baskısıdır.

---

## 8. 6.1.0 — Inspector ve DevTools

### 8.1 Çekirdek (`vexana_inspector`)

UI bilmez: ring buffer, filtre, **redaksiyon**, cURL üretimi, HAR export, replay.

**Redaksiyon kayıt anında uygulanır, görüntüleme anında değil.** Hassas veri buffer'a hiç
girmez; böylece export, HAR, replay yollarının hepsi kapsanır. Görüntüleme anında maskeleyen
tasarımlar (Alice dahil) export yolunda sızdırır.

```dart
InspectorPolicy(
  redactHeaders:  {'authorization', 'cookie', 'x-api-key'},
  redactBodyKeys: {'password', 'token', 'iban', 'pan'},
  redactQuery:    {'api_key', 'access_token'},
  maxEntries: 200,
  maxBodyBytes: 256 * 1024,
  recordBodies: true,
  allowReplay: true,
  allowExport: true,
)
```

Varsayılanlar güvenli tarafta; gevşetmek açık niyet gerektirir.

### 8.2 DevTools eklentisi

İletişim `dart:developer` üzerinden: event akışı için `postEvent`, replay komutu için
`registerExtension`. Riverpod/provider entegrasyonlarının kullandığı standart yol.

Özellikler (öncelik sırasıyla — sahibin talebi):

1. **Kayıt modu** — başlat/durdur, tüm istekleri dosyaya yaz (HAR + JSON)
2. **Başarılı / başarısız ayrımı**
3. **Sadece hataları gösterme filtresi**
4. cURL kopyala
5. Düzenle & yeniden gönder (replay)
6. Retry ve refresh zincirlerini tek satır altında grupla *(event modelinden bedava)*
7. Cache hit rozeti *(event modelinden bedava)*

Kayıt dosyası `vexana-import` skill'inin girdisidir — çalışan trafikten kod üretme döngüsü
burada kapanır:

```
uygulamayı çalıştır → inspector kaydeder → HAR export
    → vexana-import skill → service + model + VexanaMock fixture
```

### 8.3 In-app overlay (`vexana_inspector_ui`)

`dev_dependencies`'e eklenir. Production `pubspec.yaml`'ında paket yoksa panel kodu
binary'e hiç girmez — garanti derleme zamanındadır (K3).

```dart
VexanaInspectorOverlay(
  openWith: OpenGesture.shake,
  policy: InspectorPolicy(...),
  child: MyApp(),
)
```

### 8.4 Certificate pinning

6.1.0'a alındı. Fintech/banking tarafı şart koşuyor, dio'da manuel iş. 6.0.0 kapsamı
zaten geniş olduğu için ertelendi.

---

## 9. Test ve doğrulama stratejisi

- **Benchmark** (`benchmark/`, `package:benchmark_harness`) — optimizasyondan **önce** yazılır;
  her perf maddesi öncesi/sonrası sayı ile raporlanır
- **Coverage** — CI'da lcov üretilir, Codecov badge README'ye eklenir. README'deki
  ölçülmemiş "%70" beyanı gerçek sayıyla değiştirilir
- **Observer sıfır-maliyet testi** — `observer: null` iken hiçbir `NetworkEvent` nesnesinin
  oluşmadığını doğrulayan test (allocation sayımı veya event ctor'ına konan sentinel)
- **Cache key testi** — farklı path/query'lerin farklı key ürettiğini, sıralamanın
  key'i etkilemediğini doğrular (C1 regresyon koruması)
- **Refresh token testi** — tek 401'de kaç `Dio`/`NetworkManager` kurulduğunu sayar
  (P2/P3 regresyon koruması); yeni token'ın retry'a taşındığını doğrular (C7)
- **wasm build** — CI'da `flutter build web --wasm` job'ı
- **CI** — issue #121'deki "Resource not accessible by integration" izin hatası düzeltilir;
  her paket için ayrı job

---

## 10. Riskler

**R1 — Efor.** 6.0.0 kapsamı geniş: core + API + skills + site + playground. Tam zamanlı
bir işin yanında yürüyecek. **Azaltma:** `6.0.0-dev.N` ön sürümleri yayınla. Kararlı sürüm
hâlâ tek atış olur, ama aylarca sessiz kalınmaz ve breaking API'ler hakkında geri bildirim
`6.0.0` donmadan gelir. Ön sürümler `pub`'da varsayılan olarak çözülmez; mevcut 647 kullanıcı
etkilenmez.

**R2 — Breaking change kaçışı.** 647 haftalık indirme kırılgan taban.
**Azaltma:** `MIGRATION.md` + `vexana-migrate` skill'i + `parseModel`/`send`'in silinmeyip
deprecate edilmesi. Kırılan tek zorunlu şey SDK constraint ve cache key şeması.

**R3 — Cache key değişimi.** Mevcut kullanıcıların cache'i bir kereliğine boşa düşer.
**Azaltma:** `v2:` öneki ile sessiz terk; hata değil, tek seferlik miss. Belgelenir.

**R4 — Kapsam kayması.** Inspector 6.1.0'a alındı (K6), CLI tamamen kesildi (K5), saf Dart
ayrımı backlog'a taşındı. Bu üç kesme korunmalı.

**R5 — Adapter paylaşımı.** P4'ün `close()` semantiği doğrulanmadı. **Azaltma:** teyit
başarısız olursa P4 düşürülür; P2/P3 tek başına 3x → 1x kazancı zaten verir.

---

## 11. Teyit edilecekler

Implementasyondan önce doğrulanacak, tasarımı değiştirebilecek noktalar:

- **T1** — `devtools_extensions` paketleme detayı: eklenti `dev_dependencies`'teki bir
  paketten keşfediliyor mu? (`.dart_tool/package_config.json` dev_dependencies'i içerdiği
  için çalışması bekleniyor, güncel dokümana karşı doğrulanacak.) Çalışmıyorsa eklenti
  `vexana`'ya taşınır ve K7 gözden geçirilir.
- **T2** — Tek `HttpClientAdapter`'ın iki `Dio` instance'ı arasında paylaşılması: `close()`
  çağrıldığında diğerini etkiliyor mu? Etkiliyorsa P4 düşer.
- **T3** — dio 5.x'te `DioMixin`'in varsayılan transformer'ının `BackgroundTransformer`
  olduğu ve her yanıtta compute çağırdığı, benchmark ile ölçülerek doğrulanacak (C4/P1'in
  tamamı buna dayanıyor).
- **T4** — `HttpStatus` shim'i: `error_model.dart`'ın `dart:html`'den `HttpStatus` import
  etmesi web'de gerçekten çalışıyor mu, yoksa ölü kod mu?
- **T5** — Açık 6 PR'ın içeriği: 6.0.0 kapsamıyla çakışan var mı? Triyaj implementasyondan
  önce yapılmalı.

---

## 12. Sıra

```
1  benchmark + Melos + wasm + CI + lint             ölçüm zemini
2  core perf (P1-P7) + bugfix (F1-F5) + NetworkObserver
3  API modernizasyonu (§5.3) + VexanaMock
4  skills reposu (§6)
5  docs sitesi + playground (§7)
6  MIGRATION.md + README + 6.0.0
────────────────────────────────────────────────────────────
7  vexana_inspector + DevTools + in-app overlay + cert pinning → 6.1.0
```

Her adım sonunda `6.0.0-dev.N` yayınlanır (R1 azaltması).

---

## 13. Kapatılacak issue'lar

| Issue | Nasıl |
|---|---|
| #65 | Melos monorepo (§4.1) |
| #73 | Cache semantiği — davranış düzeltildi (F1) + belgelendi (§7) |
| #80 | `INetworkManager`'a `options` erişimi (§5.3) |
| #98, #110 | FormData dokümantasyonu (§6, §7) |
| #117 | Saf Dart talebi — backlog'da olduğu açıkça yanıtlanır (§3) |
| #121 | CI izin düzeltmesi (§9) |
