---
name: verify
description: vexana'yı doğrula — statik analiz, testler ve web/wasm derlemeleri tek komutta koşar, temiz özet verir. Trigger — "verify", "doğrula", "testleri koş", "her şey çalışıyor mu", "kırdım mı", "check everything", "run the checks".
---

# vexana doğrulama

`script/verify.sh` çalıştır ve sonucu raporla.

```bash
./script/verify.sh            # analiz + test + web/wasm derlemeleri (~2 dk)
./script/verify.sh --quick    # sadece analiz + test (~20 sn)
./script/verify.sh --verbose  # tüm çıktıyı ekrana bas
```

Kullanıcı "hızlı" / "kısa" dediyse `--quick`, aksi hâlde tam koşu.

## Çıktıyı yorumlarken

**Test çıktısındaki kırmızı `⛔ Error ⛔` kutuları ve 401 yığın izleri hatayı
göstermez.** Refresh-token testleri bunları kasten üretir. Tek geçerli sinyal
script'in bastığı `PASS` / `FAIL` satırlarıdır — ham log'a bakıp "hata var"
sonucuna varma.

Bir adım `FAIL` ise script zaten log'un son 25 satırını basar ve
`.verify-logs/<adım>.log` yolunu verir; tam bağlam için o dosyayı oku.

## Bilinen tuzak

PATH'teki `dart` çoğu makinede Flutter'ın dart'ı değil (homebrew'un bağımsız
Dart SDK'sı olabilir); o durumda `dart run melos ...` şu hatayı verir:
*"flutter_test from sdk which doesn't exist"*. Script Flutter'ın kendi dart'ını
bulup kullandığı için bu sorunu yaşamaz — **melos komutlarını elle çağırma,
script'i kullan.**

## Raporlama

Kullanıcıya kısa özet ver: hangi adımlar geçti, kaç test geçti, başarısız adım
varsa gerçek hata satırı. Geçtiyse uzun uzun anlatma.
