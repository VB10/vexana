# vexana benchmark — baseline

> Ölçüm tarihi: 10 Ağustos 2026
> Ortam: Flutter 3.44.8 stable · Dart 3.12.2 · macOS 26.5.1 · Apple M1 Ultra
> Commit: `305ead5` (optimizasyon öncesi)
> Koşum: `melos run benchmark`

Bu sayılar Plan B'nin optimizasyon öncesi tabanıdır. Her optimizasyondan sonra
bu dosya güncellenir ve öncesi/sonrası karşılaştırılır.

---

## 1. `compute()` vs senkron `jsonDecode`

dio'nun varsayılan `BackgroundTransformer`'ı **her yanıtta** `compute()` çağırıyor
(`packages/vexana/lib/src/mixin/core/network_manager_initialize.dart` hiç
transformer set etmiyor, dio varsayılana düşüyor).

| payload | boyut | senkron | compute | oran |
|---|---|---|---|---|
| küçük | 78 B | 12 µs | 315 µs | **26.3x** |
| orta | 12 006 B | 442 µs | 367 µs | 0.8x |
| büyük | 1 260 281 B | 14 291 µs | 25 257 µs | **1.8x** |

`oran > 1` ⇒ `compute` o boyutta toplam süre olarak kayıp.

### Yorum

**Spec §5.1-P1 doğrulandı, ama gerekçesi düzeltilmeli.**

Spec, "büyük payload'da `BackgroundTransformer` doğru seçim olabilir, o yüzden
eşik yapılandırılabilir olsun" varsayımıyla yazılmıştı. Ölçüm bunu çürütüyor:
`compute` **1.26 MB'ta da 1.8x daha yavaş**. Sebebi decode değil transfer —
string isolate'e kopyalanıyor, sonuç nesne grafiği geri kopyalanıyor. Kazanç
sadece ~12 KB civarında dar bir bantta var ve orada bile yalnızca %20.

Buradan "compute'u tamamen kaldır" sonucu **çıkmaz.** Benchmark duvar saati
ölçüyor, jank ölçmüyor:

| payload | senkron süre | 16 ms frame bütçesi |
|---|---|---|
| 78 B | 0.012 ms | sorun yok |
| 12 KB | 0.44 ms | sorun yok |
| 1.26 MB | 14.3 ms | **frame düşürür** |

Yani `compute`'un değeri hızda değil, **UI isolate'ini boşaltmakta.** Küçük
payload'da ise savunulacak hiçbir şey yok: 12 µs'lik bir işi 315 µs'ye çıkarıyor
ve ortada engellenecek jank yok.

### P1 için sonuçlanan karar

`SyncTransformer(contentLengthIsolateThreshold: N)` kullan. Eşik, senkron
decode'un frame bütçesini tehdit etmeye başladığı yerde olmalı — bu ölçümlere
göre ~50-100 KB civarı. Eşiğin altında senkron (26x kazanç), üstünde isolate
(jank koruması). Eşik yapılandırılabilir kalır.

---

## 2. Liste parse

Mevcut implementasyon
(`packages/vexana/lib/src/mixin/network_manager_response.dart:118-126`)
listeyi iki kez kopyalıyor: `whereType().toList()` sonra
`.map().cast<T>().toList()`.

| eleman | mevcut | tek geçiş | oran |
|---|---|---|---|
| 10 | 17 µs | 6 µs | **2.83x** |
| 1 000 | 101 µs | 55 µs | **1.84x** |
| 50 000 | 6 436 µs | 5 149 µs | 1.25x |

`oran > 1` ⇒ tek geçiş daha hızlı.

### Yorum

**Spec §5.1-P5 doğrulandı.**

Kazanç küçük listelerde en yüksek (2.83x) — çünkü orada sabit maliyetler
(iki liste allocation'ı, `cast` wrapper'ı) baskın. Tipik API yanıtları (10-100
eleman) tam bu bantta. Büyük listelerde oran düşüyor ama hiçbir boyutta
mevcut hali kazanmıyor.

---

## Karar özeti

| Madde | Durum | Gerekçe |
|---|---|---|
| **P1** — transformer eşiği | ✅ doğrulandı | Küçük payload'da 26.3x kayıp. Eşik ~50-100 KB. |
| **P5** — tek geçiş parse | ✅ doğrulandı | Her boyutta kazanç; tipik yanıt boyutunda 1.84-2.83x. |

Ölçülmeyen ve Plan B'de ölçülecekler: P2/P3/P4 (refresh token'da tekrarlı
`Dio`/`NetworkManager` kurulumu ve connection pool yeniden kullanımı) —
bunlar duvar saati değil, kurulum sayısı ve handshake maliyeti üzerinden
ölçülecek.
