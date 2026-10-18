# Vexana 3-Paket Bölünme ve Uygulama Planı

Bu plan, **Vexana** monoreposunun 3 bağımsız fakat birbiriyle uyumlu pakete bölünmesi sürecini ve sürüm çıkış adımlarını tanımlar.

---

## 🎯 Paket Mimarisi

```
/Users/vb10/Desktop/development/vexana
├── packages/
│   ├── vexana_core/       # [YENİ] Saf Dart çekirdeği (Sıfır Flutter/sky_engine, dart2js/Jaspr uyumlu)
│   ├── vexana/            # [MEVCUT] Flutter paketi (vexana_core'u re-export eder, NoNetwork, LocalFile, LocalPrefs)
│   └── vexana_jaspr/      # [YENİ] Jaspr web paketi (LocalStorage IFileManager, Jaspr NoNetwork, web onLine check)
├── apps/
│   └── playground/        # Canlı Flutter Web demo
└── pubspec.yaml           # Monorepo workspace kökü
```

---

## 📌 Hedef Paket Versiyonları ve Rolleri

1. **`packages/vexana_core` (v1.0.0 - Pure Dart)**:
   - **Bağımlılıklar**: `dio: ^5.8.0+1`, `dio_web_adapter: ^2.1.0`, `meta: ^1.15.0`, `logger: ^2.0.2+1`, `retry: ^3.1.2`, `equatable: ^2.0.5`, `collection: ^1.17.1`.
   - **İçerik**: `INetworkModel`, `IResponseModel`, `IErrorModel`, `INetworkManager`, `IFileManager`, `IFormDataModel`, `INoNetworkHandler` (Yeni), `NetworkManager`, tüm mixin'ler (cache, error interceptor, headers, initialize, parameters, response), modeller (`EmptyModel`, `ErrorModel`, `ResponseModel`, `NetworkResult`, `RequestType`, `LocalModel`), IO/Web adaptörleri, SSL override, logger ve `Isolate.run` tabanlı pure compute soyutlaması.
   - **Kritik Kural**: `dart compile js` ile hatasız derlenir (`dart:ui` importu kesinlikle yoktur).

2. **`packages/vexana` (v6.1.0 - Flutter)**:
   - **Bağımlılıklar**: `vexana_core: ^1.0.0`, `flutter`, `path_provider`, `shared_preferences`.
   - **İçerik**: `lib/vexana.dart` dosyasından `package:vexana_core/vexana_core.dart` re-export edilir. Flutter'a bağlı olan `NoNetwork`, `NoNetworkManager`, `NoNetworkWidget`, `LocalFile` (path_provider), `LocalPreferences` (shared_preferences), `NetworkCheck` burada kalır.
   - **API Uyumluluğu**: Flutter kullanıcıları için sıfır breaking change. `NoNetwork` sınıfı `INoNetworkHandler` arayüzünü implement eder, böylece `NetworkManager(noNetwork: NoNetwork(context))` hiçbir kod değişikliği olmadan çalışmaya devam eder.

3. **`packages/vexana_jaspr` (v0.1.0 - Jaspr Web)**:
   - **Bağımlılıklar**: `vexana_core: ^1.0.0`, `jaspr: ^0.23.5`, `web: ^1.0.0`.
   - **İçerik**: `window.localStorage` tabanlı `IFileManager` (`JasprLocalStorageFileManager`), Jaspr için `INoNetworkHandler` bileşeni (`JasprNoNetwork`), `window.navigator.onLine` tabanlı ağ kontrolü (`JasprNetworkCheck`) ve örnek Jaspr web uygulaması.

---

## ✅ Tamamlanan Uygulama Adımları

### Adım 1: `packages/vexana_core` Kurulumu ve Saf Kodların Taşınması
- [x] `packages/vexana_core` klasörü ve `pubspec.yaml` oluşturulması.
- [x] Root `pubspec.yaml` altındaki `workspace:` listesine `packages/vexana_core` eklenmesi.
- [x] Saf Dart dosyalarının `git mv` ile taşınması (git geçmişi korundu).
- [x] Flutter importlarının temizlenmesi (`meta`, `void Function()`, pure compute).
- [x] `packages/vexana_core/lib/vexana_core.dart` export dosyasının hazırlanması.
- [x] Saf birim testlerinin `packages/vexana_core/test/` altına taşınması.
- [x] **Doğrulama**: 45 saf test geçti, saflık kontrolü 0 Flutter paketi ile onaylandı.

### Adım 2: Flutter-Free Compile Guard Eklenmesi
- [x] `packages/vexana_core/tool/compile_guard.dart` yazıldı.
- [x] `dart compile js` ile 0.92s içinde derlendiği doğrulandı.

### Adım 3: `packages/vexana` (Flutter) Uyumlaması
- [x] `packages/vexana/pubspec.yaml` dosyasına `vexana_core: ^1.0.0` eklendi.
- [x] `lib/vexana.dart` dosyasından `vexana_core` re-export edildi.
- [x] `NoNetwork` sınıfı `INoNetworkHandler` arayüzünü uyguladı.
- [x] `type_compatibility_test.dart` ile `identical(core.INetworkModel, vexana.INetworkModel)` olduğu kanıtlandı.
- [x] 29 Flutter testi geçti; `example` (wasm) ve `playground` web derlemeleri tamamlandı.

### Adım 4: `packages/vexana_jaspr` (Jaspr) Paketi ve Örnek Proje
- [x] `packages/vexana_jaspr` kuruldu (`jaspr: ^0.23.5`, `web: ^1.0.0`, `vexana_core`).
- [x] `JasprLocalStorageFileManager`, `JasprNoNetwork`, `JasprNetworkCheck` yazıldı.
- [x] `packages/vexana_jaspr/example` oluşturuldu ve `jaspr build` başarıyla derlendi.
- [x] 5 test geçti; `pub publish --dry-run` 0 uyarı/0 hata verdi.

### Adım 5: CI, Melos, Doğrulama Scripti ve Dry-Run
- [x] Root `pubspec.yaml` melos scriptleri güncellendi (`test:dart`, `test:flutter`, `purity`, `compile-guard`).
- [x] `.github/workflows/pr_check.yml` güncellendi.
- [x] `.github/workflows/publish.yml` hem ayrı hem tek seferde yayınlama destekleyecek şekilde güncellendi.
- [x] `script/verify.sh` güncellendi ve tüm adımları PASS verdi.
- [x] Her 3 paket için `pub publish --dry-run` 0 hata ile doğrulandı.
- [x] Kök `README.md` ve her 3 alt paketin bağımsız `README.md` dosyaları oluşturuldu.

---

## 📋 Geliştiricinin Yapması Gerekenler (Son Eylem Planı)

Sırasıyla yapılması gereken son adımlar şunlardır:

### 1. Yerel Değişiklikleri Commit Etme
Terminalde `feature/package_seperation` branch'i üzerindeyken:
```bash
git add .
git commit -m "feat: split vexana into vexana_core, vexana, and vexana_jaspr monorepo"
```

### 2. Branch'i Push Etme ve PR Açma
```bash
git push origin feature/package_seperation
```
- GitHub üzerinden `feature/package_seperation` → `master` (veya `main`) için bir Pull Request açın.
- GitHub Actions CI (`pr_check.yml`) çalışacak ve PR üzerinde otomatik olarak analiz, saflık kontrolü, JS derleme koruması ve testleri doğrulayacaktır.
- PR'ı merge edin.

### 3. pub.dev İlk Kayıt (First-Time Package Registration)
> [!IMPORTANT]
> `vexana_core` ve `vexana_jaspr` pub.dev üzerinde **yeni oluşturulan** paketler olduğu için, ilk kez yayınlanırken paket sahipliğini Google hesabınızla (`vbacik.10@gmail.com`) eşleştirmeniz önerilir:

1. **`vexana_core` ilk sürümü (1.0.0) yayınlama**:
   ```bash
   cd packages/vexana_core
   dart pub publish
   ```
   *(Terminaldeki Google Auth linkini tarayıcıda onaylayarak paketi ilk kez sahiplenin).*

2. **`vexana` (6.1.0) ve `vexana_jaspr` (0.1.0) yayınlama**:
   `vexana_core` pub.dev'de canlıya çıktıktan hemen sonra:
   ```bash
   cd ../vexana_jaspr
   dart pub publish
   
   cd ../vexana
   flutter pub publish
   ```

### 4. pub.dev'de Otomatik Yayınlamayı (GitHub Actions OIDC) Etkinleştirme
Paketler ilk kez pub.dev'e çıktıktan sonra:
1. [pub.dev/packages/vexana_core/admin](https://pub.dev/packages/vexana_core/admin) sayfasına gidin:
   - **Automated Publishing** bölümünü açın.
   - **GitHub Actions**'ı aktif edin: Repository: `VB10/vexana`, Tag pattern: `vexana_core-v{{version}}` veya `publish_{{version}}`.
2. [pub.dev/packages/vexana_jaspr/admin](https://pub.dev/packages/vexana_jaspr/admin) sayfasına gidin:
   - Aynı şekilde Repository: `VB10/vexana`, Tag pattern: `vexana_jaspr-v{{version}}` veya `publish_{{version}}` olarak ayarlayın.

### 5. Gelecek Sürümlerde Yayınlama Seçenekleri
İlk kurulum tamamlandıktan sonra artık terminalden hiçbir şifre/token girmeden tek komutla CI üzerinden yayınlayabilirsiniz:

* **Tüm paketleri tek seferde çıkarmak için**:
  ```bash
  ./script/push_version.sh 6.1.0
  ```
* **Sadece tek bir paketi çıkarmak için**:
  ```bash
  ./script/push_version.sh core 1.0.1
  ./script/push_version.sh vexana 6.1.1
  ./script/push_version.sh jaspr 0.1.1
  ```
* **GitHub Actions Arayüzünden**:
  GitHub repository > **Actions** > **Publish to pub.dev** > **Run workflow** diyerek istediğiniz paketi seçip tek tıkla yayınlayabilirsiniz.

---

## 👥 Flutter Kullanıcıları İçin Ne Değişiyor? (Kullanıcı İletişimi)

Mevcut Vexana kullanıcıları için **hiçbir şey kırılmadı ve değişmedi**:

1. **Sıfır Kod Değişikliği**:
   Flutter projelerinde sadece `pubspec.yaml`'daki sürümü yükseltmeleri yeterli:
   ```yaml
   dependencies:
     vexana: ^6.1.0
   ```
   Mevcut tüm kodlar (`NetworkManager`, `INetworkModel`, `NoNetwork`, `LocalFile`, `LocalPreferences`) eskisi gibi birebir çalışmaya devam eder.

2. **Kazanılan Yeni Süper Güç**:
   İsterlerse artık modellerini (`INetworkModel`) Flutter bağımlılığı olmayan saf bir Dart paketine (`vexana_core`) taşıyabilir ve aynı modeli Jaspr web sitelerinde veya backend servislerinde ortak kullanabilirler.
