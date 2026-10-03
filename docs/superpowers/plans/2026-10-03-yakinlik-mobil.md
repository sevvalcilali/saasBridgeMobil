# Yakınlık Panosu Mobil (Flutter) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tasarım teslim paketindeki 1a (Liste) varyantını, gömülü sahte veriyle çalışan, iOS + Android Flutter uygulaması olarak yazmak.

**Architecture:** Dört katman: `tema/` (renk ve yazı token'ları), `veri/` (modeller, sahte veri, `EtkinlikDeposu`), `mantik/` (saf Dart fonksiyonlar), `ekranlar/` + `bilesenler/` (yalnız gösterir). Durum `ChangeNotifier` ile tutulur ve kurucu parametresiyle aktarılır; grafik ve ağ çizgileri `CustomPaint` ile çizilir. Görevler aşağıdan yukarı sıralıdır: her dosya bir kez, son hâliyle yazılır; uygulama en sonda (Task 15) birleşir.

**Tech Stack:** Flutter 3.44.6, Dart 3.12.2, Material 3. Paketler yalnız SDK'dan: `flutter`, `flutter_localizations`, `flutter_test`, `integration_test`; lint için `flutter_lints ^6.0.0`.

**Spec:** `docs/superpowers/specs/2026-10-03-yakinlik-mobil-design.md` (ölçüler: Ek A; sapmalar: §3 S1–S17)

## Global Constraints

- Proje kökü: `~/Desktop/Projects/yakinlik_mobil/`. Tüm komutlar bu klasörde çalıştırılır.
- Flutter 3.44.6 / Dart 3.12.2. pub.dev'den **yeni paket eklenmez**.
- Ağ yok, kalıcılık yok. Onayla / Geri al / İade al sahte veriyi **değiştirmez**, yalnız bant gösterir.
- Yalnız 1a varyantı, yalnız `web` teması (açık), yalnız dikey yön.
- Kod adları Türkçe (ASCII), yorumlar Türkçe. Kullanıcıya görünen tüm metinler Türkçe ve prototiptekiyle birebir aynı.
- Renk sabiti (`Color(0x…)`, `Colors.x`) yalnız `lib/tema/` altında yazılır (`Colors.transparent` serbest).
- `lib/mantik/` saf Dart'tır: `package:flutter` ve `dart:ui` içe aktarmaz; renk yerine `DurumTonu` döndürür.
- `sahte_veri.dart`'ı yalnız `etkinlik_deposu.dart` içe aktarır; ekranlar veriye depo üzerinden erişir.
- Yeşil (`Renkler.birlikte`, `Renkler.birlikteZemin`) yalnız "şu an birlikte" anlamında kullanılır.
- Kalın metin ağırlığı 600. Eksi işareti her yerde `−` (U+2212). Süre biçimi: `19 sn`, `2 dk`, `1 dk 14 sn`, `1 sa 16 dk`.
- Dokunma hedefleri en az 44 px. İstisna: Pano bölüm anahtarı (README: 40 px) ve Ağ satırları (30 px aralık).
- Sistem yazı ölçeği 1.0–1.3 arasına sınırlanır.
- Her görev sonunda: `flutter analyze` → `No issues found!`, `flutter test` → tamamı yeşil, sonra commit.
- Commit iletileri Türkçe, `Adım N: …` biçiminde ve şu satırla biter: `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`. Push yok, uzak depo yok.
- Sonsuz animasyon (Nabız) olan ekranlarda testlerde `pumpAndSettle` kullanılmaz; `pump(süre)` kullanılır.

## Review Focus

Şartnamenin ima ettiği, ama kendiliğinden sınanmayacak beş durum. Her birinin testi ilgili görevdedir.

1. **360 dp genişlikte Android telefon** (şartname 390–430 der; 360 dp çok yaygındır): hiçbir ekran taşmamalı. → Task 15 `tasma_test.dart`.
2. **Büyük sistem yazı boyutu:** ölçek 2.0 olsa da 1.3'e sınırlanmalı ve hiçbir satır taşmamalı. → Task 15 `tasma_test.dart`.
3. **Sihirbazda hızlı/sıra dışı dokunuşlar:** "Demo"ya basıp 1,4 sn dolmadan geri dönmek ya da başka kişi seçmek; eski `Kart 88 bulundu` sonradan belirmemeli. → Task 11 `kart_ver_durumu_test.dart`, Task 12 `kart_ver_ekrani_test.dart`.
4. **Kart numarası girdisi:** `0`, `00`, `100`, `007`, harf yapıştırma, çok uzun rakam dizisi; çökmemeli, `Bu kartı seç` yalnız 1–99'da görünmeli. → Task 3 `kart_no_test.dart`, Task 12.
5. **Uzun oturum:** bir saati aşan süreler (`1 sa 16 dk`), gece yarısını geçen saat (`00:00:00`), KPI değeri kartına sığmalı. → Task 2 `bicim_test.dart`, Task 14 `rapor_ekrani_test.dart`.

---

## Dosya yapısı

```
lib/
  main.dart                       giriş: dikey kilit + runApp                       (Task 1 geçici, Task 15 son)
  uygulama.dart                   MaterialApp: tema, tr yereli, yazı ölçeği sınırı  (Task 15)
  tema/        renkler.dart  olculer.dart  yazi.dart  tema.dart                     (Task 6)
  veri/        modeller.dart  sahte_veri.dart                                        (Task 1)
               etkinlik_deposu.dart                                                  (Task 5)
  mantik/      metin.dart  bicim.dart  kisi_gorunum.dart                             (Task 2)
               pano_filtre.dart  ag.dart  kart_no.dart                               (Task 3)
               kurulum.dart  rapor.dart                                              (Task 4)
  bilesenler/  dokunma_hedefi.dart  hap_dugme.dart  etiket.dart  cip.dart
               bolmeli_anahtar.dart  arama_alani.dart  kicker.dart  rol_sekli.dart
               basili_opaklik.dart  etiketli_deger.dart  kesik_cizgi.dart            (Task 7)
  ekranlar/
    pano/        pano_durumu.dart  pano_ust.dart  kisiler_bolumu.dart                (Task 8)
                 ag_bolumu.dart  bildirimler_bolumu.dart  pano_ekrani.dart           (Task 9)
    kisi_detayi/ kisi_detay_sayfasi.dart                                             (Task 10)
    kart_ver/    kart_ver_durumu.dart                                                (Task 11)
                 kart_ver_ekrani.dart  adim_gostergesi.dart  kisi_adimi.dart
                 kart_adimi.dart  nabiz.dart  kontrol_adimi.dart  iade_paneli.dart   (Task 12)
    kurulum/     kurulum_ekrani.dart  esik_bolumu.dart  sinyal_grafigi.dart
                 kart_sagligi_bolumu.dart                                            (Task 13)
    rapor/       rapor_ekrani.dart                                                   (Task 14)
    kabuk.dart                                                                       (Task 15)
test/
  flutter_test_config.dart  yazi_tipi_test.dart  mimari_test.dart                    (Task 1)
  yardimci.dart                                                                      (Task 7)
  veri/  mantik/  tema/  bilesenler/  ekranlar/                                      (ilgili görevlerde)
integration_test/ekran_goruntuleri_test.dart  test_driver/integration_test.dart     (Task 16)
docs/teslim/  README.md                                                              (Task 16)
```

## Kod blokları hakkında

Başlığında `title=<yol>` olan her kod bloğu, o dosyanın **tam içeriğidir**; dosya o içerikle oluşturulur. Dosyalar bir kez yazılır; sonraki görevler onları değiştirmez (tek istisna `lib/main.dart`: Task 1'de geçici, Task 15'te son hâli).

Blokları elle kopyalamak yerine şu yardımcıyla çıkarabilirsiniz (depoya eklenmez; geçici bir klasöre kaydedin). Görev numarası verilir, çünkü `lib/main.dart` iki görevde de geçer. TDD sırası için önce test yollarını, sonra kod yollarını verin:

```python title=(depo dışı) cikar.py
"""Kullanım: python3 cikar.py PLAN.md GOREV_NO [yol ...]
Planın "### Task GOREV_NO" bölümündeki title=yol bloklarını dosyaya yazar.
Yol verilmezse o görevin tüm bloklarını yazar."""
import pathlib, re, sys

plan = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
gorev = re.search(rf"^### Task {sys.argv[2]}:.*?(?=^### Task \d+:|\Z)", plan, flags=re.S | re.M).group(0)
bloklar = dict(re.findall(r"^```\w+ title=(\S+)\n(.*?)^```$", gorev, flags=re.S | re.M))
for yol in sys.argv[3:] or bloklar:
    hedef = pathlib.Path(yol)
    hedef.parent.mkdir(parents=True, exist_ok=True)
    hedef.write_text(bloklar[yol], encoding="utf-8")
    print("yazıldı:", yol)
```

README ve teslim notu blokları (Task 16) dört ters tırnakla çevrilidir; onlar elle yazılır.

---

### Task 1: Proje iskeleti, veri modeli ve sahte veri

**Files:**
- Create (araçla): `flutter create` çıktısı (`android/`, `ios/`, `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, …)
- Create: `pubspec.yaml` (şablonun yerine), `lib/main.dart` (geçici), `test/flutter_test_config.dart`, `test/yazi_tipi_test.dart`, `test/mimari_test.dart`, `test/veri/sahte_veri_test.dart`, `lib/veri/modeller.dart`, `lib/veri/sahte_veri.dart`
- Delete: `test/widget_test.dart` (şablonun sayaç testi)
- Modify: `ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml` (görünen ad)

**Interfaces:**
- Consumes: yok.
- Produces:
  - `enum Rol { yatirimci, girisimci, misafir }`, `enum KisiRengi { mavi, turuncu, hardal, pembe, mor, mercan, petrol, gri }`, `enum Onem { ciddi, uyari, olumlu }`, `enum DurumTonu { birlikte, uyari, ikincil, ciddi }`
  - `class Kisi { String id; String? ad; String? kurum; Rol rol; KisiRengi renk; String? ile; int sn; int pil; int yildiz; bool gorunmuyor; bool hic; }`
  - `class Bildirim { String baslik, detay, saat; Onem onem; List<String> kisiler; }`, `class Cift { String a, b; int rssi; }`, `class AcikKart { String no; bool atanmis; }`
  - `abstract final class SahteVeri` → `etkinlikAdi`, `tarihMekan`, `raporTarihi`, `cizelgeBaslangici`, `baslangicSaatSn`, `baslangicEsik`, `duyulanKartSayisi`, `kayitliKatilimci`, `kisiler`, `bildirimler`, `ciftler`, `seriRenkleri`, `acikKartlar`

- [ ] **Step 1: Flutter projesini oluştur**

```bash
cd ~/Desktop/Projects/yakinlik_mobil
flutter create --org com.saasbridge --project-name yakinlik_mobil --platforms=ios,android \
  --description "Yakınlık Panosu — saha görevlileri için mobil uygulama." .
```

Beklenen: çıktının sonunda `All done!`. `docs/` ve `.git/` yerinde kalır.

- [ ] **Step 2: Şablon dosyalarını projeye uyarla**

Şablonun sayaç testini sil:

```bash
rm test/widget_test.dart
```

`pubspec.yaml`'ı şu içerikle değiştir (şablondaki `cupertino_icons` çıkar; `flutter_localizations` ve `integration_test` eklenir):

```yaml title=pubspec.yaml
name: yakinlik_mobil
description: "Yakınlık Panosu — saha görevlileri için mobil uygulama."
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.12.2

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

Şablonun `lib/main.dart`'ı `Colors.deepPurple` içerir ve mimari testini bozar. Geçici giriş noktasıyla değiştir (son hâli Task 15'te):

```dart title=lib/main.dart
import 'package:flutter/widgets.dart';

// Geçici giriş noktası: Kabuk hazır olunca (Task 15) gerçek uygulama bağlanır.
void main() => runApp(const SizedBox.shrink());
```

```bash
flutter pub get
```

Beklenen: `Got dependencies!`

- [ ] **Step 3: Görünen adı "Yakınlık Panosu" yap**

```bash
sed -i '' 's|<string>Yakinlik Mobil</string>|<string>Yakınlık Panosu</string>|' ios/Runner/Info.plist
sed -i '' 's|android:label="yakinlik_mobil"|android:label="Yakınlık Panosu"|' android/app/src/main/AndroidManifest.xml
grep -n "Yakınlık Panosu" ios/Runner/Info.plist android/app/src/main/AndroidManifest.xml
```

Beklenen: iki satır (biri `Info.plist`, biri `AndroidManifest.xml`).

- [ ] **Step 4: Testlere gerçek yazı tipini yükle**

Widget testlerinin varsayılan yazı tipi her harfi kare çizer; gerçekte sığan satırlar taşmış görünür ve test düşer. SDK ile gelen Roboto yüklenir.

```dart title=test/flutter_test_config.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget testlerinin varsayılan yazı tipi her harfi kare çizer; gerçekte sığan
/// satırlar taşmış görünür. Flutter SDK ile gelen Roboto yüklenir, böylece
/// ölçüler Android'deki gerçek ölçülere yakın olur.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _robotoYukle();
  await testMain();
}

Directory? _yaziTipiKlasoru() {
  final kok = Platform.environment['FLUTTER_ROOT'];
  final adaylar = [
    if (kok != null) '$kok/bin/cache/artifacts/material_fonts',
    // flutter_tester: <kök>/bin/cache/artifacts/engine/<platform>/flutter_tester
    '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts',
  ];
  for (final yol in adaylar) {
    final klasor = Directory(yol);
    if (klasor.existsSync()) return klasor;
  }
  return null;
}

Future<void> _robotoYukle() async {
  final klasor = _yaziTipiKlasoru();
  if (klasor == null) return;
  final yukleyici = FontLoader('Roboto');
  const dosyalar = ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Italic.ttf'];
  for (final ad in dosyalar) {
    final dosya = File('${klasor.path}/$ad');
    if (dosya.existsSync()) {
      yukleyici.addFont(Future<ByteData>.value(ByteData.sublistView(dosya.readAsBytesSync())));
    }
  }
  await yukleyici.load();
}
```

```dart title=test/yazi_tipi_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('testlerde gerçek yazı tipi (Roboto) yüklü', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Text('iiiiiiiiii', style: TextStyle(fontFamily: 'Roboto', fontSize: 10)),
        ),
      ),
    );
    // Kare yazı tipinde 10 harf × 10 px = 100 px olurdu.
    expect(tester.getSize(find.byType(Text)).width, lessThan(50));
  });
}
```

```bash
flutter test test/yazi_tipi_test.dart
```

Beklenen: `All tests passed!` (Düşerse `ls "$(dirname "$(which flutter)")/cache/artifacts/material_fonts"` ile Roboto dosyalarının yerini doğrula.)

- [ ] **Step 5: Başarısız testleri yaz (mimari + sahte veri)**

```dart title=test/mimari_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Katman kurallarını (şartname §4) denetler.
List<File> _dartDosyalari(String klasor) {
  final dizin = Directory(klasor);
  if (!dizin.existsSync()) return const [];
  return [
    for (final f in dizin.listSync(recursive: true))
      if (f is File && f.path.endsWith('.dart')) f,
  ];
}

String _yol(File f) => f.path.replaceAll(r'\', '/');

void main() {
  test('renk sabiti yalnız lib/tema altında yazılır', () {
    final renkSabiti = RegExp(r'Color\(0x|Color\.from(ARGB|RGBO)\(|Colors\.(?!transparent\b)');
    final ihlaller = [
      for (final f in _dartDosyalari('lib'))
        if (!_yol(f).startsWith('lib/tema/') && renkSabiti.hasMatch(f.readAsStringSync())) _yol(f),
    ];
    expect(ihlaller, isEmpty);
  });

  test('lib/mantik saf Dart: Flutter ve dart:ui içe aktarmaz', () {
    final yasak = RegExp('''import\\s+['"](package:flutter/|dart:ui)''');
    final ihlaller = [
      for (final f in _dartDosyalari('lib/mantik'))
        if (yasak.hasMatch(f.readAsStringSync())) _yol(f),
    ];
    expect(ihlaller, isEmpty);
  });

  test('sahte veriye yalnız EtkinlikDeposu erişir', () {
    final ihlaller = [
      for (final f in _dartDosyalari('lib'))
        if (!_yol(f).startsWith('lib/veri/') && f.readAsStringSync().contains('sahte_veri.dart')) _yol(f),
    ];
    expect(ihlaller, isEmpty);
  });
}
```

```dart title=test/veri/sahte_veri_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  const kisiler = SahteVeri.kisiler;

  test('26 kayıt: 12 girişimci, 10 yatırımcı, 4 misafir; biri adsız', () {
    expect(kisiler, hasLength(26));
    expect(kisiler.where((k) => k.rol == Rol.girisimci), hasLength(12));
    expect(kisiler.where((k) => k.rol == Rol.yatirimci), hasLength(10));
    expect(kisiler.where((k) => k.rol == Rol.misafir), hasLength(4));
    expect(kisiler.where((k) => k.ad == null).map((k) => k.id), ['14']);
  });

  test('kart numaraları benzersiz', () {
    expect(kisiler.map((k) => k.id).toSet(), hasLength(kisiler.length));
  });

  test('her "ile" kayıtlı bir kişiyi gösterir, karşılıklıdır ve süreleri eşittir', () {
    final harita = {for (final k in kisiler) k.id: k};
    for (final k in kisiler.where((k) => k.ile != null)) {
      final es = harita[k.ile];
      expect(es, isNotNull, reason: '${k.id} → ${k.ile} bulunamadı');
      expect(es!.ile, k.id, reason: '${k.id} ↔ ${k.ile} karşılıklı değil');
      expect(es.sn, k.sn, reason: '${k.id} ↔ ${k.ile} süreleri farklı');
    }
  });

  test('yalnız yatırımcının yıldızı vardır', () {
    for (final k in kisiler) {
      expect(k.yildiz, k.rol == Rol.yatirimci ? inInclusiveRange(1, 5) : 0, reason: k.id);
    }
  });

  test('bildirimler kayıtlı kişileri gösterir: 2 uyarı, 1 olumlu, 1 ciddi', () {
    final idler = kisiler.map((k) => k.id).toSet();
    expect(SahteVeri.bildirimler, hasLength(4));
    for (final b in SahteVeri.bildirimler) {
      expect(b.kisiler, isNotEmpty, reason: b.baslik);
      expect(idler.containsAll(b.kisiler), isTrue, reason: b.baslik);
    }
    int adet(Onem o) => SahteVeri.bildirimler.where((b) => b.onem == o).length;
    expect([adet(Onem.uyari), adet(Onem.olumlu), adet(Onem.ciddi)], [2, 1, 1]);
  });

  test('çiftler, seri renkleri ve açık kartlar', () {
    expect(SahteVeri.ciftler, hasLength(10));
    expect(SahteVeri.ciftler.first.rssi, -51);
    expect(SahteVeri.ciftler.last.rssi, -78);
    expect(SahteVeri.seriRenkleri, hasLength(6));
    expect(SahteVeri.acikKartlar.map((k) => k.no), ['88', '89', '90', '96', '97', '61', '46', '24', '5']);
    expect(SahteVeri.acikKartlar.where((k) => k.atanmis).map((k) => k.no), ['61', '46', '24', '5']);
  });

  test('etkinlik sabitleri', () {
    expect(SahteVeri.etkinlikAdi, 'Yatırımcı Buluşması');
    expect(SahteVeri.tarihMekan, '28.09.2026 · Demo Salonu');
    expect(SahteVeri.baslangicSaatSn, 15 * 3600 + 10 * 60 + 9);
    expect(SahteVeri.baslangicEsik, -72);
    expect(SahteVeri.duyulanKartSayisi, 32);
    expect(SahteVeri.kayitliKatilimci, kisiler.where((k) => k.ad != null).length);
  });
}
```

- [ ] **Step 6: Testin düştüğünü gör**

```bash
flutter test test/veri/sahte_veri_test.dart
```

Beklenen: derleme hatası — `Error: Error when reading 'lib/veri/modeller.dart': No such file or directory`.

- [ ] **Step 7: Veri modelini ve sahte veriyi yaz**

```dart title=lib/veri/modeller.dart
/// Sunucudaki rol adlarının karşılığı: investor / founder / guest.
enum Rol { yatirimci, girisimci, misafir }

/// Kişi paleti adları. Renk değerleri tema/renkler.dart'tadır.
enum KisiRengi { mavi, turuncu, hardal, pembe, mor, mercan, petrol, gri }

/// Bildirim önemi.
enum Onem { ciddi, uyari, olumlu }

/// Durum yazısının anlamsal tonu; rengini tema eşler (mantık renk bilmez).
enum DurumTonu { birlikte, uyari, ikincil, ciddi }

/// Bir karta atanmış kişi. `id` kart numarasıdır; `ad == null` kayıtsız karttır.
class Kisi {
  const Kisi({
    required this.id,
    required this.rol,
    required this.renk,
    required this.pil,
    this.ad,
    this.kurum,
    this.ile,
    this.sn = 0,
    this.yildiz = 0,
    this.gorunmuyor = false,
    this.hic = false,
  });

  final String id;
  final String? ad;
  final String? kurum;
  final Rol rol;
  final KisiRengi renk;

  /// Şu an birlikte olduğu kişinin kart numarası.
  final String? ile;

  /// Başlangıçtaki süre (saniye).
  final int sn;

  /// Pil yüzdesi.
  final int pil;

  /// 0–5; yatırımcı değilse 0.
  final int yildiz;
  final bool gorunmuyor;

  /// Hiç görüşmemiş.
  final bool hic;
}

class Bildirim {
  const Bildirim({
    required this.baslik,
    required this.detay,
    required this.saat,
    required this.onem,
    required this.kisiler,
  });

  final String baslik;
  final String detay;
  final String saat;
  final Onem onem;

  /// İlgili kişilerin kart numaraları; satıra dokununca ilki açılır.
  final List<String> kisiler;
}

/// Sinyali ölçülen kart çifti (dBm).
class Cift {
  const Cift(this.a, this.b, this.rssi);

  final String a;
  final String b;
  final int rssi;
}

/// Alıcının şu an duyduğu kart.
class AcikKart {
  const AcikKart(this.no, {this.atanmis = false});

  final String no;
  final bool atanmis;
}
```

```dart title=lib/veri/sahte_veri.dart
import 'modeller.dart';

/// Prototipteki (docs/tasarim/Yakinlik Mobil.dc.html) sabit veri — birebir.
/// Bu dosyayı yalnız etkinlik_deposu.dart içe aktarır.
abstract final class SahteVeri {
  static const etkinlikAdi = 'Yatırımcı Buluşması';
  static const tarihMekan = '28.09.2026 · Demo Salonu';
  static const raporTarihi = '02.10.2026';
  static const cizelgeBaslangici = '15:10';
  static const baslangicSaatSn = 15 * 3600 + 10 * 60 + 9;
  static const baslangicEsik = -72;
  static const duyulanKartSayisi = 32;
  static const kayitliKatilimci = 25;

  static const kisiler = <Kisi>[
    Kisi(id: '24', ad: 'Cem Erdem', kurum: 'Nova Robotik', rol: Rol.girisimci, renk: KisiRengi.hardal, ile: '19', sn: 19, pil: 92),
    Kisi(id: '31', ad: 'İrem Korkmaz', kurum: 'Peak Enerji', rol: Rol.girisimci, renk: KisiRengi.pembe, ile: '65', sn: 74, pil: 81),
    Kisi(id: '33', ad: 'Onur Çelik', kurum: 'Bitki Teknoloji', rol: Rol.girisimci, renk: KisiRengi.mor, ile: '46', sn: 15, pil: 77),
    Kisi(id: '35', ad: 'Gizem Polat', kurum: 'Akıllı Tarım', rol: Rol.girisimci, renk: KisiRengi.mercan, ile: '71', sn: 59, pil: 88),
    Kisi(id: '37', ad: 'Ece Arslan', kurum: 'Sağlık Cebi', rol: Rol.girisimci, renk: KisiRengi.turuncu, ile: '61', sn: 59, pil: 69),
    Kisi(id: '39', ad: 'Tolga Koç', kurum: 'Hızlı Kargo', rol: Rol.girisimci, renk: KisiRengi.petrol, ile: '47', sn: 72, pil: 90),
    Kisi(id: '41', ad: 'Naz Özkan', kurum: 'Temiz Deniz', rol: Rol.girisimci, renk: KisiRengi.hardal, ile: '4', sn: 70, pil: 83),
    Kisi(id: '43', ad: 'Pelin Güneş', kurum: 'Fin Radar', rol: Rol.girisimci, renk: KisiRengi.mor, ile: '52', sn: 64, pil: 95),
    Kisi(id: '45', ad: 'Uğur Demir', kurum: 'Eğitim Yıldızı', rol: Rol.girisimci, renk: KisiRengi.mercan, ile: '58', sn: 71, pil: 72),
    Kisi(id: '5', ad: 'Aslı Kılıç', kurum: 'Şehir Sensör', rol: Rol.girisimci, renk: KisiRengi.mavi, ile: '44', sn: 19, pil: 65),
    Kisi(id: '49', ad: 'Can Yıldız', kurum: 'Veri Köprüsü', rol: Rol.girisimci, renk: KisiRengi.mavi, pil: 84, hic: true),
    Kisi(id: '51', ad: 'Serkan Doğan', kurum: 'Oyun Evreni', rol: Rol.girisimci, renk: KisiRengi.pembe, pil: 86, hic: true),
    Kisi(id: '61', ad: 'Ayşe Demir', rol: Rol.yatirimci, renk: KisiRengi.mavi, yildiz: 4, ile: '37', sn: 59, pil: 91),
    Kisi(id: '46', ad: 'Mehmet Kılıç', rol: Rol.yatirimci, renk: KisiRengi.turuncu, yildiz: 5, ile: '33', sn: 15, pil: 16),
    Kisi(id: '83', ad: 'Zeynep Tekin', rol: Rol.yatirimci, renk: KisiRengi.petrol, yildiz: 2, pil: 79, hic: true),
    Kisi(id: '65', ad: 'Emre Kaya', rol: Rol.yatirimci, renk: KisiRengi.hardal, yildiz: 3, ile: '31', sn: 74, pil: 88),
    Kisi(id: '19', ad: 'Elif Aydın', rol: Rol.yatirimci, renk: KisiRengi.pembe, yildiz: 3, ile: '24', sn: 19, pil: 87),
    Kisi(id: '52', ad: 'Burak Aksoy', rol: Rol.yatirimci, renk: KisiRengi.mor, yildiz: 4, ile: '43', sn: 64, pil: 93),
    Kisi(id: '71', ad: 'Selin Şahin', rol: Rol.yatirimci, renk: KisiRengi.mercan, yildiz: 3, ile: '35', sn: 59, pil: 80),
    Kisi(id: '44', ad: 'Merve Bulut', rol: Rol.yatirimci, renk: KisiRengi.turuncu, yildiz: 2, ile: '5', sn: 19, pil: 76),
    Kisi(id: '58', ad: 'Deniz Yılmaz', rol: Rol.yatirimci, renk: KisiRengi.petrol, yildiz: 4, ile: '45', sn: 71, pil: 70),
    Kisi(id: '40', ad: 'Kaan Öztürk', rol: Rol.yatirimci, renk: KisiRengi.mavi, yildiz: 3, pil: 82, gorunmuyor: true),
    Kisi(id: '47', ad: 'Kerem Tekin', rol: Rol.misafir, renk: KisiRengi.turuncu, ile: '39', sn: 72, pil: 74),
    Kisi(id: '4', ad: 'Duygu Kaya', rol: Rol.misafir, renk: KisiRengi.petrol, ile: '41', sn: 70, pil: 72),
    Kisi(id: '22', ad: 'Volkan Aydın', rol: Rol.misafir, renk: KisiRengi.hardal, pil: 87, hic: true),
    Kisi(id: '14', rol: Rol.misafir, renk: KisiRengi.pembe, pil: 66, hic: true),
  ];

  static const bildirimler = <Bildirim>[
    Bildirim(
      baslik: 'Pil düşük',
      detay: 'Kart 46 · Mehmet Kılıç · %16 — kartı masada değiştirin',
      saat: '15:09',
      onem: Onem.uyari,
      kisiler: ['46'],
    ),
    Bildirim(
      baslik: 'Yeni görüşme',
      detay: 'Nova Robotik · Cem Erdem, Elif Aydın ile',
      saat: '15:09',
      onem: Onem.olumlu,
      kisiler: ['24', '19'],
    ),
    Bildirim(
      baslik: 'Yalnız kaldı',
      detay: "Veri Köprüsü · Can Yıldız 8 dk'dır görüşmüyor",
      saat: '15:04',
      onem: Onem.uyari,
      kisiler: ['49'],
    ),
    Bildirim(
      baslik: 'Kart kayboldu',
      detay: "Kart 40 · Kaan Öztürk 3 dk'dır duyulmuyor",
      saat: '15:02',
      onem: Onem.ciddi,
      kisiler: ['40'],
    ),
  ];

  static const ciftler = <Cift>[
    Cift('27', '28', -51),
    Cift('61', '90', -49),
    Cift('4', '94', -55),
    Cift('5', '80', -57),
    Cift('47', '58', -60),
    Cift('44', '67', -63),
    Cift('19', '24', -66),
    Cift('39', '51', -69),
    Cift('33', '46', -74),
    Cift('35', '71', -78),
  ];

  /// Grafikte ilk 6 çiftin renkleri (kişi paletinden).
  static const seriRenkleri = <KisiRengi>[
    KisiRengi.pembe,
    KisiRengi.mavi,
    KisiRengi.petrol,
    KisiRengi.mor,
    KisiRengi.turuncu,
    KisiRengi.mercan,
  ];

  static const acikKartlar = <AcikKart>[
    AcikKart('88'),
    AcikKart('89'),
    AcikKart('90'),
    AcikKart('96'),
    AcikKart('97'),
    AcikKart('61', atanmis: true),
    AcikKart('46', atanmis: true),
    AcikKart('24', atanmis: true),
    AcikKart('5', atanmis: true),
  ];
}
```

- [ ] **Step 8: Testler geçsin, çözümleme temiz olsun**

```bash
flutter test
flutter analyze
```

Beklenen: `All tests passed!` (yazı tipi 1 + mimari 3 + sahte veri 7 = 11 test) ve `No issues found!`

- [ ] **Step 9: Commit**

```bash
git add -A
git status --short | head -20
git commit -m "Adım 1: Proje iskeleti, veri modeli ve sahte veri

- flutter create (iOS + Android), yalnız SDK paketleri, görünen ad Yakınlık Panosu
- Testlerde Roboto yüklenir (gerçekçi ölçüler); mimari kuralları testle denetlenir
- Prototipteki sahte veri birebir: 26 kişi, 4 bildirim, 10 çift, 9 açık kart

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---
### Task 2: Mantık — metin, biçim, kişi görünümü

**Files:**
- Create: `lib/mantik/metin.dart`, `lib/mantik/bicim.dart`, `lib/mantik/kisi_gorunum.dart`
- Test: `test/mantik/metin_test.dart`, `test/mantik/bicim_test.dart`, `test/mantik/kisi_gorunum_test.dart`

**Interfaces:**
- Consumes: `Kisi`, `Rol`, `DurumTonu` (Task 1).
- Produces:
  - `String trKucuk(String s)`, `String trBuyuk(String s)`
  - `String sureYazisi(int saniye)`, `String saatYazisi(int saniye)`, `String kisaSaatYazisi(int saniye)`, `String dbmYazisi(int v)`, `String yildizlar(int n)`
  - `String gorunenAd(Kisi k)`, `String baslik(Kisi k)`, `String altAd(Kisi k)`, `String tamAd(Kisi k)`, `String rolAdi(Rol rol)`, `String rolSatiri(Kisi k)`, `String kartMetni(Kisi k)`
  - `int gecenSn(Kisi k, int tick)`, `DurumTonu durumTonu(Kisi k)`, `String durumCumlesi(Kisi k, int tick, Kisi Function(String id) bul)`, `String sureMetni(Kisi k, int tick)`, `String sonDuyulma(Kisi k)`, `double cizelgeOrani(Kisi k, int tick)`

- [ ] **Step 1: Başarısız testleri yaz**

```dart title=test/mantik/metin_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/metin.dart';

void main() {
  test('trKucuk: I → ı, İ → i', () {
    expect(trKucuk('IŞIK'), 'ışık');
    expect(trKucuk('İREM'), 'irem');
    expect(trKucuk('Şehir Sensör'), 'şehir sensör');
    expect(trKucuk('NOVA'), 'nova');
    expect(trKucuk(''), '');
  });

  test('trBuyuk: i → İ, ı → I', () {
    expect(trBuyuk('girişimciler'), 'GİRİŞİMCİLER');
    expect(trBuyuk('yatırımcı'), 'YATIRIMCI');
    expect(trBuyuk('Kart sağlığı'), 'KART SAĞLIĞI');
    expect(trBuyuk(''), '');
  });
}
```

```dart title=test/mantik/bicim_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/bicim.dart';

void main() {
  test('sureYazisi: saniye, dakika, saat', () {
    expect(sureYazisi(0), '0 sn');
    expect(sureYazisi(19), '19 sn');
    expect(sureYazisi(59), '59 sn');
    expect(sureYazisi(60), '1 dk');
    expect(sureYazisi(74), '1 dk 14 sn');
    expect(sureYazisi(522), '8 dk 42 sn');
    expect(sureYazisi(3599), '59 dk 59 sn');
  });

  test('sureYazisi: uzun oturum (bir saat ve üstü)', () {
    expect(sureYazisi(3600), '1 sa');
    expect(sureYazisi(4560), '1 sa 16 dk');
    expect(sureYazisi(7199), '2 sa');
    expect(sureYazisi(36000), '10 sa');
  });

  test('sureYazisi: eksi değer sıfır sayılır', () {
    expect(sureYazisi(-5), '0 sn');
  });

  test('saat: gün içinde döner', () {
    expect(saatYazisi(54609), '15:10:09');
    expect(kisaSaatYazisi(54609), '15:10');
    expect(saatYazisi(86399), '23:59:59');
    expect(saatYazisi(86400), '00:00:00');
    expect(kisaSaatYazisi(86400 + 61), '00:01');
  });

  test('dbmYazisi: gerçek eksi işareti (U+2212)', () {
    expect(dbmYazisi(-72), '−72');
    expect(dbmYazisi(-35), '−35');
    expect(dbmYazisi(0), '0');
  });

  test('yildizlar', () {
    expect(yildizlar(3), '★★★');
    expect(yildizlar(0), '');
  });
}
```

```dart title=test/mantik/kisi_gorunum_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kisi_gorunum.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

Kisi bul(String id) => SahteVeri.kisiler.firstWhere((k) => k.id == id);

void main() {
  final cem = bul('24'); // girişimci, Nova Robotik, Elif Aydın (19) ile, 19 sn
  final ayse = bul('61'); // yatırımcı ★★★★, birlikte
  final zeynep = bul('83'); // yatırımcı ★★, boşta
  final kaan = bul('40'); // görünmüyor
  final can = bul('49'); // hiç görüşmemiş girişimci
  final adsiz = bul('14'); // kayıtsız kart

  test('adlar', () {
    expect(gorunenAd(cem), 'Cem Erdem');
    expect(gorunenAd(adsiz), 'Kart 14');
    expect(baslik(cem), 'Nova Robotik');
    expect(baslik(ayse), 'Ayşe Demir');
    expect(baslik(adsiz), 'Kart 14');
    expect(altAd(cem), '· Cem Erdem');
    expect(altAd(ayse), '· ★★★★');
    expect(altAd(adsiz), '');
    expect(tamAd(cem), 'Nova Robotik · Cem Erdem');
    expect(tamAd(ayse), 'Ayşe Demir');
    expect(tamAd(adsiz), 'Kart 14');
  });

  test('rol ve kart metni', () {
    expect(rolAdi(Rol.yatirimci), 'Yatırımcı');
    expect(rolAdi(Rol.girisimci), 'Girişimci');
    expect(rolAdi(Rol.misafir), 'Misafir');
    expect(rolSatiri(ayse), 'Yatırımcı · ★★★★');
    expect(rolSatiri(cem), 'Girişimci');
    expect(kartMetni(ayse), 'Kart 61 · ★★★★');
    expect(kartMetni(cem), 'Kart 24');
  });

  test('süre yalnız birlikte olan kişide akar', () {
    expect(gecenSn(cem, 0), 19);
    expect(gecenSn(cem, 10), 29);
    expect(gecenSn(can, 10), 0);
    expect(sureMetni(cem, 0), '19 sn');
    expect(sureMetni(cem, 41), '1 dk');
    expect(sureMetni(can, 41), '—');
  });

  test('durum cümlesi ve tonu', () {
    expect(durumCumlesi(cem, 0, bul), 'Elif Aydın ile · 19 sn');
    expect(durumTonu(cem), DurumTonu.birlikte);
    expect(durumCumlesi(kaan, 0, bul), 'Görünmüyor · 3 dk önce duyuldu');
    expect(durumTonu(kaan), DurumTonu.uyari);
    expect(durumCumlesi(zeynep, 5, bul), 'Boşta');
    expect(durumTonu(zeynep), DurumTonu.ikincil);
  });

  test('son duyulma', () {
    expect(sonDuyulma(kaan), '3 dk önce');
    expect(sonDuyulma(cem), 'az önce');
  });

  test('çizelge oranı: birlikte değilse 0, en çok 1', () {
    expect(cizelgeOrani(can, 100), 0);
    expect(cizelgeOrani(cem, 0), closeTo(0.2633, 0.0001));
    expect(cizelgeOrani(cem, 1000), 1);
  });
}
```

- [ ] **Step 2: Testlerin düştüğünü gör**

```bash
flutter test test/mantik
```

Beklenen: derleme hatası — `Error when reading 'lib/mantik/metin.dart': No such file or directory` (ve diğer iki dosya için aynısı).

- [ ] **Step 3: Kodu yaz**

```dart title=lib/mantik/metin.dart
// Dart'ın büyük/küçük harf çevirisi yerelsizdir: 'I'.toLowerCase() → 'i',
// 'i'.toUpperCase() → 'I'. Türkçede I ↔ ı ve İ ↔ i eşleşir.

/// Türkçe küçük harf (arama karşılaştırması için).
String trKucuk(String s) => s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// Türkçe büyük harf (kicker başlıkları için).
String trBuyuk(String s) => s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
```

```dart title=lib/mantik/bicim.dart
// Birim ve metin çevirileri. Ekranlar hesap yapmaz, buradan okur.

/// Saniye → "19 sn" / "2 dk" / "1 dk 14 sn" / "1 sa 16 dk".
/// (Web: src/api/format.js sureYazisi ile aynı kural.)
String sureYazisi(int saniye) {
  final toplam = saniye < 0 ? 0 : saniye;
  if (toplam >= 3600) {
    var sa = toplam ~/ 3600;
    var dk = ((toplam % 3600) / 60).round();
    if (dk == 60) {
      sa += 1;
      dk = 0;
    }
    return dk == 0 ? '$sa sa' : '$sa sa $dk dk';
  }
  final dk = toplam ~/ 60;
  final sn = toplam % 60;
  if (dk == 0) return '$sn sn';
  return sn == 0 ? '$dk dk' : '$dk dk $sn sn';
}

String _iki(int n) => n.toString().padLeft(2, '0');

/// Günün saniyesi → "15:10:09". Gün içinde döner.
String saatYazisi(int saniye) {
  final s = saniye % 86400;
  return '${_iki(s ~/ 3600)}:${_iki((s % 3600) ~/ 60)}:${_iki(s % 60)}';
}

/// Günün saniyesi → "15:10".
String kisaSaatYazisi(int saniye) {
  final s = saniye % 86400;
  return '${_iki(s ~/ 3600)}:${_iki((s % 3600) ~/ 60)}';
}

/// dBm değeri gerçek eksi işaretiyle (U+2212): −72.
String dbmYazisi(int v) => v < 0 ? '−${-v}' : '$v';

/// Yatırımcı yıldızları: "★★★".
String yildizlar(int n) => '★' * n;
```

```dart title=lib/mantik/kisi_gorunum.dart
import '../veri/modeller.dart';
import 'bicim.dart';

// Kişiden türetilen ad, durum ve süre yazıları.

/// Kayıtsız kart "Kart 14" diye gösterilir.
String gorunenAd(Kisi k) => k.ad ?? 'Kart ${k.id}';

/// Liste satırının kalın başlığı: kurum varsa kurum, yoksa ad.
String baslik(Kisi k) => k.kurum ?? gorunenAd(k);

/// Başlığın yanındaki ikincil yazı: "· Cem Erdem" ya da "· ★★★★".
String altAd(Kisi k) {
  if (k.kurum != null) return '· ${gorunenAd(k)}';
  return k.yildiz > 0 ? '· ${yildizlar(k.yildiz)}' : '';
}

/// "Nova Robotik · Cem Erdem" (kurum yoksa yalnız ad).
String tamAd(Kisi k) => k.kurum != null ? '${k.kurum} · ${gorunenAd(k)}' : gorunenAd(k);

String rolAdi(Rol rol) => switch (rol) {
  Rol.yatirimci => 'Yatırımcı',
  Rol.girisimci => 'Girişimci',
  Rol.misafir => 'Misafir',
};

/// "Yatırımcı · ★★★★" (yıldız yoksa yalnız rol).
String rolSatiri(Kisi k) => k.yildiz > 0 ? '${rolAdi(k.rol)} · ${yildizlar(k.yildiz)}' : rolAdi(k.rol);

/// "Kart 61 · ★★★★" (yıldız yoksa "Kart 24").
String kartMetni(Kisi k) => k.yildiz > 0 ? 'Kart ${k.id} · ${yildizlar(k.yildiz)}' : 'Kart ${k.id}';

/// Süre yalnız şu an birlikte olan kişide akar.
int gecenSn(Kisi k, int tick) => k.ile != null ? k.sn + tick : k.sn;

DurumTonu durumTonu(Kisi k) {
  if (k.gorunmuyor) return DurumTonu.uyari;
  return k.ile != null ? DurumTonu.birlikte : DurumTonu.ikincil;
}

/// "Elif Aydın ile · 19 sn" / "Boşta" / "Görünmüyor · 3 dk önce duyuldu".
String durumCumlesi(Kisi k, int tick, Kisi Function(String id) bul) {
  if (k.gorunmuyor) return 'Görünmüyor · 3 dk önce duyuldu';
  final ile = k.ile;
  if (ile != null) return '${gorunenAd(bul(ile))} ile · ${sureYazisi(gecenSn(k, tick))}';
  return 'Boşta';
}

/// Satırın sağındaki süre; hiç görüşmemişse "—".
String sureMetni(Kisi k, int tick) => (k.ile != null || k.sn > 0) ? sureYazisi(gecenSn(k, tick)) : '—';

String sonDuyulma(Kisi k) => k.gorunmuyor ? '3 dk önce' : 'az önce';

/// Zaman çizelgesindeki yeşil dolgunun oranı (0–1).
double cizelgeOrani(Kisi k, int tick) {
  if (k.ile == null) return 0;
  final oran = (20 + gecenSn(k, tick) / 3) / 100;
  return oran > 1 ? 1 : oran;
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test test/mantik && flutter analyze
```

Beklenen: `All tests passed!` (2 + 6 + 6 = 14 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 2: Mantık — Türkçe harf çevirisi, süre/saat biçimi, kişi görünümü

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: Mantık — pano filtresi, ağ yerleşimi, kart numarası

**Files:**
- Create: `lib/mantik/pano_filtre.dart`, `lib/mantik/ag.dart`, `lib/mantik/kart_no.dart`
- Test: `test/mantik/pano_filtre_test.dart`, `test/mantik/ag_test.dart`, `test/mantik/kart_no_test.dart`

**Interfaces:**
- Consumes: `Kisi`, `Rol`, `Bildirim`, `Onem`, `AcikKart` (Task 1); `trKucuk`, `gorunenAd` (Task 2).
- Produces:
  - `enum PanoFiltre { tumu, yatirimci, girisimci, birlikte, bosta, gorunmuyor, hicGorusmemis }` (alan: `String etiket`)
  - `List<Kisi> filtreleKisiler(List<Kisi> kisiler, {PanoFiltre filtre = PanoFiltre.tumu, String arama = ''})`
  - `String listeBasligi(PanoFiltre f)`
  - `const List<Onem?> onemSirasi` (`null` = Tümü), `String onemEtiketi(Onem? onem)`, `List<Bildirim> bildirimleriSuz(List<Bildirim> liste, Onem? onem)`, `int onemSayisi(List<Bildirim> liste, Onem? onem)`
  - `class AgDugumu { Kisi kisi; String ad; }`, `class AgKenari { double x1, y1, x2, y2; }`, `class AgYerlesimi { List<AgDugumu> sol, sag; List<AgKenari> kenarlar; double yukseklik; }`
  - `const double agSatirAraligi = 30`, `AgYerlesimi agYerlesimi(List<Kisi> kisiler, double genislik)`
  - `String numaraTemizle(String girdi)`, `bool numaraGecerli(String girdi)`, `String yalnizRakam(String girdi)`, `List<AcikKart> acikKartOner(List<AcikKart> kartlar, String numara)`, `String acikKartEtiketi(AcikKart k)`, `List<Kisi> masaAra(List<Kisi> kisiler, String arama)`

- [ ] **Step 1: Başarısız testleri yaz**

```dart title=test/mantik/pano_filtre_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/pano_filtre.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  const kisiler = SahteVeri.kisiler;
  int adet(PanoFiltre f) => filtreleKisiler(kisiler, filtre: f).length;
  List<String> ara(String q, [PanoFiltre f = PanoFiltre.tumu]) => [
    for (final k in filtreleKisiler(kisiler, filtre: f, arama: q)) k.id,
  ];

  test('filtre sayıları', () {
    expect(adet(PanoFiltre.tumu), 26);
    expect(adet(PanoFiltre.yatirimci), 10);
    expect(adet(PanoFiltre.girisimci), 12);
    expect(adet(PanoFiltre.birlikte), 20);
    expect(adet(PanoFiltre.bosta), 5);
    expect(adet(PanoFiltre.gorunmuyor), 1);
    expect(adet(PanoFiltre.hicGorusmemis), 5);
  });

  test('sıra korunur (liste zıplamaz)', () {
    expect(ara('').first, '24');
    expect(ara('', PanoFiltre.yatirimci).first, '61');
  });

  test('filtre etiketleri', () {
    expect(PanoFiltre.values.map((f) => f.etiket), [
      'Tümü',
      'Yatırımcı',
      'Girişimci',
      'Birlikte',
      'Boşta',
      'Görünmüyor',
      'Hiç görüşmemiş',
    ]);
  });

  test('arama: ad, kurum ve kart no', () {
    expect(ara('nova'), ['24']);
    expect(ara('cem'), ['24']);
    expect(ara('61'), ['61']);
    expect(ara('kart 14'), ['14']);
    expect(ara('kılıç'), ['5', '46']);
  });

  test('arama: Türkçe büyük-küçük harf ve baştaki/sondaki boşluk', () {
    expect(ara('NOVA'), ['24']);
    expect(ara('İREM'), ['31']);
    expect(ara('  cem  '), ['24']);
    expect(ara('IŞIK'), isEmpty);
  });

  test('arama filtreyle birlikte uygulanır; sonuç yoksa boş liste', () {
    expect(ara('nova', PanoFiltre.yatirimci), isEmpty);
    expect(ara('yok böyle biri'), isEmpty);
  });

  test('liste başlığı', () {
    expect(listeBasligi(PanoFiltre.tumu), 'Kişiler');
    expect(listeBasligi(PanoFiltre.yatirimci), 'Yatırımcılar');
    expect(listeBasligi(PanoFiltre.girisimci), 'Girişimciler');
    expect(listeBasligi(PanoFiltre.birlikte), 'Birlikte');
    expect(listeBasligi(PanoFiltre.hicGorusmemis), 'Hiç görüşmemiş');
  });

  test('bildirim süzme, sayıları ve etiketleri', () {
    const b = SahteVeri.bildirimler;
    expect([for (final o in onemSirasi) onemSayisi(b, o)], [4, 1, 2, 1]);
    expect([for (final o in onemSirasi) onemEtiketi(o)], ['Tümü', 'Ciddi', 'Uyarı', 'Olumlu']);
    expect(bildirimleriSuz(b, null), hasLength(4));
    expect(bildirimleriSuz(b, Onem.ciddi).single.baslik, 'Kart kayboldu');
    expect(bildirimleriSuz(const [], Onem.uyari), isEmpty);
  });
}
```

```dart title=test/mantik/ag_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/ag.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  final y = agYerlesimi(SahteVeri.kisiler, 362);

  test('sol: yatırımcılar + birlikte olan misafirler; sağ: girişimciler', () {
    expect(y.sol.map((d) => d.kisi.id), ['61', '46', '83', '65', '19', '52', '71', '44', '58', '40', '47', '4']);
    expect(y.sag.map((d) => d.kisi.id), ['24', '31', '33', '35', '37', '39', '41', '43', '45', '5', '49', '51']);
    expect(y.sol.first.ad, 'Ayşe Demir');
    expect(y.sag.first.ad, 'Nova Robotik');
  });

  test('yükseklik: en kalabalık sütun × 30 + 10', () {
    expect(y.yukseklik, 370);
  });

  test('kenarlar: birlikte olan 10 çift', () {
    expect(y.kenarlar, hasLength(10));
    // Nova Robotik (sağ 0. satır) ↔ Elif Aydın (sol 4. satır)
    final k = y.kenarlar.first;
    expect([k.x1, k.y1, k.x2, k.y2], [22, 136, 340, 16]);
  });

  test('kenarlar genişliğe uyar', () {
    expect(agYerlesimi(SahteVeri.kisiler, 390).kenarlar.first.x2, 368);
  });

  test('boş liste', () {
    final bos = agYerlesimi(const [], 362);
    expect(bos.sol, isEmpty);
    expect(bos.sag, isEmpty);
    expect(bos.kenarlar, isEmpty);
    expect(bos.yukseklik, 10);
  });
}
```

```dart title=test/mantik/kart_no_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kart_no.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  test('numaraTemizle: baştaki sıfırları atar', () {
    expect(numaraTemizle('007'), '7');
    expect(numaraTemizle('70'), '70');
    expect(numaraTemizle('000'), '');
    expect(numaraTemizle(''), '');
  });

  test('numaraGecerli: yalnız 1–99', () {
    for (final g in ['1', '7', '007', '14', '99', '099']) {
      expect(numaraGecerli(g), isTrue, reason: '"$g" geçerli olmalı');
    }
    for (final g in ['', '0', '00', '100', '1a', 'abc', '-3', ' 5', '12345678901234567890']) {
      expect(numaraGecerli(g), isFalse, reason: '"$g" geçersiz olmalı');
    }
  });

  test('yalnizRakam: rakam dışını atar', () {
    expect(yalnizRakam('1a2 b3'), '123');
    expect(yalnizRakam('abc'), '');
  });

  test('acikKartOner: numara ön ekine göre süzer', () {
    const kartlar = SahteVeri.acikKartlar;
    List<String> oner(String n) => [for (final k in acikKartOner(kartlar, n)) k.no];
    expect(oner(''), hasLength(9));
    expect(oner('8'), ['88', '89']);
    expect(oner('9'), ['90', '96', '97']);
    expect(oner('09'), ['90', '96', '97']);
    expect(oner('0'), hasLength(9));
    expect(oner('3'), isEmpty);
  });

  test('acikKartEtiketi', () {
    expect(acikKartEtiketi(SahteVeri.acikKartlar.first), 'boşta');
    expect(acikKartEtiketi(SahteVeri.acikKartlar.last), 'atanmış');
  });

  test('masaAra: yalnız adı olanlar; ad, kurum ve kart no', () {
    List<String> ara(String q) => [for (final k in masaAra(SahteVeri.kisiler, q)) k.id];
    expect(ara(''), hasLength(25));
    expect(ara('peak'), ['31']);
    expect(ara('PEAK'), ['31']);
    expect(ara('24'), ['24']);
    expect(ara('14'), isEmpty);
  });
}
```

- [ ] **Step 2: Testlerin düştüğünü gör**

```bash
flutter test test/mantik/pano_filtre_test.dart test/mantik/ag_test.dart test/mantik/kart_no_test.dart
```

Beklenen: derleme hatası — üç dosya için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/mantik/pano_filtre.dart
import '../veri/modeller.dart';
import 'kisi_gorunum.dart';
import 'metin.dart';

// Pano'daki kişi listesi ve bildirim akışının süzme mantığı.

/// Kişiler bölümündeki filtre çipleri, sırasıyla.
enum PanoFiltre {
  tumu('Tümü'),
  yatirimci('Yatırımcı'),
  girisimci('Girişimci'),
  birlikte('Birlikte'),
  bosta('Boşta'),
  gorunmuyor('Görünmüyor'),
  hicGorusmemis('Hiç görüşmemiş');

  const PanoFiltre(this.etiket);

  final String etiket;
}

bool _filtreUyar(Kisi k, PanoFiltre filtre) => switch (filtre) {
  PanoFiltre.tumu => true,
  PanoFiltre.yatirimci => k.rol == Rol.yatirimci,
  PanoFiltre.girisimci => k.rol == Rol.girisimci,
  PanoFiltre.birlikte => k.ile != null,
  PanoFiltre.bosta => k.ile == null && !k.gorunmuyor,
  PanoFiltre.gorunmuyor => k.gorunmuyor,
  PanoFiltre.hicGorusmemis => k.hic,
};

/// Filtre + arama (ad, kurum, kart no). Sıra değişmez: liste zıplamaz.
List<Kisi> filtreleKisiler(
  List<Kisi> kisiler, {
  PanoFiltre filtre = PanoFiltre.tumu,
  String arama = '',
}) {
  final q = trKucuk(arama.trim());
  return [
    for (final k in kisiler)
      if (_filtreUyar(k, filtre) &&
          (q.isEmpty || trKucuk('${k.kurum ?? ''} ${gorunenAd(k)} ${k.id}').contains(q)))
        k,
  ];
}

/// Listenin üstündeki kicker başlığı.
String listeBasligi(PanoFiltre f) => switch (f) {
  PanoFiltre.tumu => 'Kişiler',
  PanoFiltre.yatirimci => 'Yatırımcılar',
  PanoFiltre.girisimci => 'Girişimciler',
  _ => f.etiket,
};

/// Önem çiplerinin sırası; `null` = Tümü.
const List<Onem?> onemSirasi = [null, Onem.ciddi, Onem.uyari, Onem.olumlu];

String onemEtiketi(Onem? onem) => switch (onem) {
  null => 'Tümü',
  Onem.ciddi => 'Ciddi',
  Onem.uyari => 'Uyarı',
  Onem.olumlu => 'Olumlu',
};

List<Bildirim> bildirimleriSuz(List<Bildirim> liste, Onem? onem) {
  if (onem == null) return liste;
  return [
    for (final b in liste)
      if (b.onem == onem) b,
  ];
}

int onemSayisi(List<Bildirim> liste, Onem? onem) => bildirimleriSuz(liste, onem).length;
```

```dart title=lib/mantik/ag.dart
import '../veri/modeller.dart';
import 'kisi_gorunum.dart';

// Ağ bölümünün yerleşimi. Düğüm konumu FİZİKSEL konum DEĞİLDİR; yalnız rol
// gruplarını gösterir. Konum sıraya bağlıdır, zamanla değişmez (zıplamaz).

/// Bir düğüm satırının yüksekliği (px).
const double agSatirAraligi = 30;

/// Çizginin düğüme değdiği yatay uzaklık: 14 px şekil + 8 px boşluk.
const double _kenarPayi = 22;

class AgDugumu {
  const AgDugumu({required this.kisi, required this.ad});

  final Kisi kisi;
  final String ad;
}

class AgKenari {
  const AgKenari(this.x1, this.y1, this.x2, this.y2);

  final double x1;
  final double y1;
  final double x2;
  final double y2;
}

class AgYerlesimi {
  const AgYerlesimi({
    required this.sol,
    required this.sag,
    required this.kenarlar,
    required this.yukseklik,
  });

  /// Yatırımcılar ve şu an birlikte olan misafirler.
  final List<AgDugumu> sol;

  /// Girişimciler.
  final List<AgDugumu> sag;

  /// Şu an birlikte olan çiftler arasındaki çizgiler.
  final List<AgKenari> kenarlar;
  final double yukseklik;
}

double _y(int satir) => 16 + satir * agSatirAraligi;

AgYerlesimi agYerlesimi(List<Kisi> kisiler, double genislik) {
  final sol = [
    for (final k in kisiler)
      if (k.rol != Rol.girisimci && (k.ile != null || k.rol == Rol.yatirimci)) k,
  ];
  final sag = [
    for (final k in kisiler)
      if (k.rol == Rol.girisimci) k,
  ];
  final kenarlar = <AgKenari>[];
  for (var i = 0; i < sag.length; i++) {
    final j = sol.indexWhere((x) => x.id == sag[i].ile);
    if (j >= 0) kenarlar.add(AgKenari(_kenarPayi, _y(j), genislik - _kenarPayi, _y(i)));
  }
  final satir = sol.length > sag.length ? sol.length : sag.length;
  return AgYerlesimi(
    sol: [for (final k in sol) AgDugumu(kisi: k, ad: gorunenAd(k))],
    sag: [for (final k in sag) AgDugumu(kisi: k, ad: k.kurum ?? gorunenAd(k))],
    kenarlar: kenarlar,
    yukseklik: satir * agSatirAraligi + 10,
  );
}
```

```dart title=lib/mantik/kart_no.dart
import '../veri/modeller.dart';
import 'metin.dart';

// Karşılama masası kuralları: kart numarası ve kayıtlı kişi araması.

/// Kişi kartları 1–99'dur; 100 ve üstü dinleyici cihazdır.
const int kartEnBuyuk = 99;

final RegExp _bastakiSifirlar = RegExp(r'^0+');
final RegExp _yalnizRakam = RegExp(r'^[0-9]+$');
final RegExp _rakamDisi = RegExp(r'[^0-9]');

/// Baştaki sıfırları atar: "007" → "7".
String numaraTemizle(String girdi) => girdi.replaceFirst(_bastakiSifirlar, '');

/// Elle yazılan kart numarası geçerli mi: yalnız rakam ve 1–99.
bool numaraGecerli(String girdi) {
  final temiz = numaraTemizle(girdi);
  if (!_yalnizRakam.hasMatch(temiz)) return false;
  final n = int.tryParse(temiz);
  return n != null && n >= 1 && n <= kartEnBuyuk;
}

/// Rakam dışındaki her şeyi atar.
String yalnizRakam(String girdi) => girdi.replaceAll(_rakamDisi, '');

/// "Şu an açık kartlar" ızgarası: girilen numarayla başlayanlar (boş girdi → hepsi).
List<AcikKart> acikKartOner(List<AcikKart> kartlar, String numara) {
  if (numara.isEmpty) return kartlar;
  final onEk = numaraTemizle(numara);
  return [
    for (final k in kartlar)
      if (k.no.startsWith(onEk)) k,
  ];
}

String acikKartEtiketi(AcikKart k) => k.atanmis ? 'atanmış' : 'boşta';

/// Kayıtlı (adı olan) kişilerde ad, kurum ve kart no araması.
/// Kart Ver adım 1 ve Kart İadesi listesi bunu kullanır.
List<Kisi> masaAra(List<Kisi> kisiler, String arama) {
  final q = trKucuk(arama.trim());
  return [
    for (final k in kisiler)
      if (k.ad != null && (q.isEmpty || trKucuk('${k.kurum ?? ''} ${k.ad} ${k.id}').contains(q))) k,
  ];
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test test/mantik && flutter analyze
```

Beklenen: `All tests passed!` (önceki 14 + 8 + 5 + 6 = 33 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 3: Mantık — pano filtresi ve arama, ağ yerleşimi, kart numarası kuralları

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Mantık — kurulum ve rapor

**Files:**
- Create: `lib/mantik/kurulum.dart`, `lib/mantik/rapor.dart`
- Test: `test/mantik/kurulum_test.dart`, `test/mantik/rapor_test.dart`

**Interfaces:**
- Consumes: `Kisi`, `Rol`, `Cift`, `KisiRengi` (Task 1); `sureYazisi`, `gorunenAd`, `gecenSn` (Task 2).
- Produces:
  - `const int esikAlt = -95`, `const int esikUst = -35`, `const double grafikSolBosluk = 28`
  - `int esikSinirla(num deger)`, `int esikUstuCiftSayisi(List<Cift> ciftler, int esik)`, `double grafikY(num dbm, double yukseklik)`, `double sozdeRastgele(int i, int j)`
  - `class GrafikSerisi { String ad; KisiRengi renk; List<({double x, double y})> noktalar; }`
  - `List<GrafikSerisi> grafikSerileri(List<Cift> ciftler, List<KisiRengi> renkler, int tick, double genislik, double yukseklik)`
  - `class SaglikSatiri { String kart; String kisi; bool adsiz; int pil; bool sorunlu; String get durum; }`, `List<SaglikSatiri> kartSagligi(List<Kisi> kisiler)`, `int sorunluKartSayisi(List<Kisi> kisiler)`
  - `class Kpi { String ad, deger, not; }`, `List<Kpi> raporKpileri(List<Kisi> kisiler, int tick, {required int kayitli})`
  - `class RaporSatiri { Kisi kisi; String toplam; String detay; bool gorusmedi; }`, `List<RaporSatiri> raporSatirlari(List<Kisi> kisiler, int tick, Kisi Function(String id) bul)`

- [ ] **Step 1: Başarısız testleri yaz**

```dart title=test/mantik/kurulum_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/kurulum.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

void main() {
  const ciftler = SahteVeri.ciftler;
  const renkler = SahteVeri.seriRenkleri;

  test('esikSinirla: −95…−35 arası tam sayı', () {
    expect(esikSinirla(-100), -95);
    expect(esikSinirla(-20), -35);
    expect(esikSinirla(-72), -72);
    expect(esikSinirla(-71.6), -72);
  });

  test('esikUstuCiftSayisi: eşikten güçlü çiftler', () {
    expect(esikUstuCiftSayisi(ciftler, -72), 8);
    expect(esikUstuCiftSayisi(ciftler, -95), 10);
    expect(esikUstuCiftSayisi(ciftler, -51), 1);
    expect(esikUstuCiftSayisi(ciftler, -35), 0);
  });

  test('grafikY: −40 üstte, −90 altta', () {
    expect(grafikY(-40, 150), closeTo(0, 1e-9));
    expect(grafikY(-90, 150), closeTo(150, 1e-9));
    expect(grafikY(-72, 150), closeTo(96, 1e-9));
  });

  test('grafikY: eksen dışındaki değer kenara yapışır', () {
    expect(grafikY(-35, 150), 0);
    expect(grafikY(-95, 150), 150);
  });

  test('sozdeRastgele: 0–1 arası ve deterministik', () {
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 40; j++) {
        final r = sozdeRastgele(i, j);
        expect(r, inInclusiveRange(0, 1));
        expect(sozdeRastgele(i, j), r);
      }
    }
  });

  test('grafikSerileri: 6 seri × 31 nokta, eksen içinde', () {
    final seriler = grafikSerileri(ciftler, renkler, 0, 362, 150);
    expect(seriler, hasLength(6));
    expect(seriler.first.ad, '27 · 28');
    expect(seriler.first.renk, KisiRengi.pembe);
    expect(seriler.last.ad, '44 · 67');
    for (final seri in seriler) {
      expect(seri.noktalar, hasLength(31));
      expect(seri.noktalar.first.x, 28);
      expect(seri.noktalar.last.x, closeTo(362, 1e-9));
      for (final n in seri.noktalar) {
        expect(n.y, inInclusiveRange(0, 150));
      }
    }
  });

  test('grafik her saniye bir adım sola kayar', () {
    final t0 = grafikSerileri(ciftler, renkler, 0, 362, 150);
    final t1 = grafikSerileri(ciftler, renkler, 1, 362, 150);
    expect(t1.first.noktalar[0].y, closeTo(t0.first.noktalar[1].y, 1e-9));
    expect(t1.first.noktalar[29].y, closeTo(t0.first.noktalar[30].y, 1e-9));
  });

  test('grafikSerileri: altıdan az çift ve boş liste', () {
    expect(grafikSerileri(ciftler.sublist(0, 2), renkler, 0, 362, 150), hasLength(2));
    expect(grafikSerileri(const [], renkler, 0, 362, 150), isEmpty);
  });

  test('kartSagligi: pile göre artan, eşitlikte özgün sıra, ilk 8', () {
    final satirlar = kartSagligi(SahteVeri.kisiler);
    expect(satirlar.map((r) => r.kart), ['46', '5', '14', '37', '58', '45', '4', '47']);
    expect(satirlar.first.sorunlu, isTrue);
    expect(satirlar.first.durum, '⚠ pil düşük');
    expect(satirlar.first.kisi, 'Mehmet Kılıç');
    expect(satirlar.first.pil, 16);
    expect(satirlar[1].kisi, 'Şehir Sensör');
    expect(satirlar[1].sorunlu, isFalse);
    expect(satirlar[1].durum, '✓ iyi');
    expect(satirlar[2].kisi, 'Kart 14');
    expect(satirlar[2].adsiz, isTrue);
  });

  test('sorunluKartSayisi', () {
    expect(sorunluKartSayisi(SahteVeri.kisiler), 1);
    expect(sorunluKartSayisi(const []), 0);
  });
}
```

```dart title=test/mantik/rapor_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/mantik/rapor.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';
import 'package:yakinlik_mobil/veri/sahte_veri.dart';

Kisi bul(String id) => SahteVeri.kisiler.firstWhere((k) => k.id == id);

void main() {
  const kisiler = SahteVeri.kisiler;

  test('KPI: başlangıçta', () {
    final k = raporKpileri(kisiler, 0, kayitli: 25);
    expect(k.map((x) => x.ad), [
      'Görüşme',
      'Yatırımcı–girişimci toplam',
      'Yatırımcıya ulaşan girişimci',
      'Potansiyel anlaşma',
      'Katılımcı',
    ]);
    expect(k.map((x) => x.deger), ['10', '8 dk 42 sn', '10/12', '0', '25']);
    expect(k.map((x) => x.not), ['10 tanesi sürüyor', 'bugün', '', 'işaretlenmedi', 'kayıtlı']);
  });

  test('KPI: toplam süre, birlikte olan 10 girişimciyle akar', () {
    expect(raporKpileri(kisiler, 6, kayitli: 25)[1].deger, '9 dk 42 sn');
    expect(raporKpileri(kisiler, 400, kayitli: 25)[1].deger, '1 sa 15 dk');
  });

  test('satırlar: süreye göre azalan, eşitlikte özgün sıra', () {
    final s = raporSatirlari(kisiler, 0, bul);
    expect(s.map((r) => r.kisi.id), ['31', '39', '45', '41', '43', '35', '37', '24', '5', '33', '49', '51']);
  });

  test('satır: görüşen girişimci', () {
    final ilk = raporSatirlari(kisiler, 0, bul).first;
    expect(ilk.toplam, '1 dk 14 sn');
    expect(ilk.detay, 'Emre Kaya (1 dk 14 sn)');
    expect(ilk.gorusmedi, isFalse);
  });

  test('satır: hiç görüşmemiş girişimci', () {
    final son = raporSatirlari(kisiler, 0, bul).last;
    expect(son.toplam, '—');
    expect(son.detay, '⚠ Hiç yatırımcıyla görüşmedi');
    expect(son.gorusmedi, isTrue);
  });

  test('boş liste', () {
    expect(raporSatirlari(const [], 0, bul), isEmpty);
    expect(raporKpileri(const [], 0, kayitli: 0).map((x) => x.deger), ['0', '0 sn', '0/0', '0', '0']);
  });
}
```

- [ ] **Step 2: Testlerin düştüğünü gör**

```bash
flutter test test/mantik/kurulum_test.dart test/mantik/rapor_test.dart
```

Beklenen: derleme hatası — iki dosya için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/mantik/kurulum.dart
import 'dart:math' as math;

import '../veri/modeller.dart';
import 'kisi_gorunum.dart';

// Kurulum ekranı: eşik, canlı sinyal grafiği geometrisi, kart sağlığı.

/// Eşik kaydırıcısının sınırları (dBm).
const int esikAlt = -95;
const int esikUst = -35;

/// Grafik ekseni: üst kenar −40 dBm, alt kenar −90 dBm.
const double _grafikUstDbm = -40;
const double _grafikAltDbm = -90;

/// Grafiğin solunda eksen etiketlerine ayrılan boşluk (px).
const double grafikSolBosluk = 28;

const int _grafikNoktaSayisi = 31;
const int _grafikCiftSayisi = 6;
const int _dusukPil = 20;
const int _saglikSatirSayisi = 8;

int esikSinirla(num deger) => deger.round().clamp(esikAlt, esikUst).toInt();

/// Şu an eşiğin üstünde (eşikten güçlü) olan çift sayısı.
int esikUstuCiftSayisi(List<Cift> ciftler, int esik) => ciftler.where((c) => c.rssi > esik).length;

/// dBm → piksel (üst = güçlü). Eksen dışındaki değer kenara yapışır.
double grafikY(num dbm, double yukseklik) {
  final y = (dbm - _grafikUstDbm) * yukseklik / (_grafikAltDbm - _grafikUstDbm);
  if (y < 0) return 0;
  if (y > yukseklik) return yukseklik;
  return y;
}

/// Prototipteki deterministik sözde rastgele sayı (0–1).
double sozdeRastgele(int i, int j) {
  final x = math.sin(i * 374.1 + j * 91.7) * 43758.5453;
  return x - x.floorToDouble();
}

class GrafikSerisi {
  const GrafikSerisi({required this.ad, required this.renk, required this.noktalar});

  /// Lejant etiketi: "27 · 28".
  final String ad;
  final KisiRengi renk;
  final List<({double x, double y})> noktalar;
}

/// En güçlü ilk 6 çiftin son 90 saniyelik çizgileri. `tick` arttıkça bir adım
/// sola kayar. x: [grafikSolBosluk, genislik]; y: [0, yukseklik].
List<GrafikSerisi> grafikSerileri(
  List<Cift> ciftler,
  List<KisiRengi> renkler,
  int tick,
  double genislik,
  double yukseklik,
) {
  final adim = (genislik - grafikSolBosluk) / (_grafikNoktaSayisi - 1);
  final adet = math.min(ciftler.length, _grafikCiftSayisi);
  return [
    for (var i = 0; i < adet; i++)
      GrafikSerisi(
        ad: '${ciftler[i].a} · ${ciftler[i].b}',
        renk: renkler[i % renkler.length],
        noktalar: [
          for (var j = 0; j < _grafikNoktaSayisi; j++)
            (
              x: grafikSolBosluk + j * adim,
              y: grafikY(ciftler[i].rssi + (sozdeRastgele(i, j + tick) - 0.5) * 8, yukseklik),
            ),
        ],
      ),
  ];
}

class SaglikSatiri {
  const SaglikSatiri({
    required this.kart,
    required this.kisi,
    required this.adsiz,
    required this.pil,
    required this.sorunlu,
  });

  final String kart;

  /// Kurum ya da görünen ad.
  final String kisi;

  /// Kayıtsız kart: ikincil renkte yazılır.
  final bool adsiz;
  final int pil;
  final bool sorunlu;

  String get durum => sorunlu ? '⚠ pil düşük' : '✓ iyi';
}

/// En düşük pilli 8 kart. Dart'ın sort'u kararlı olmadığı için özgün sıra
/// ikinci anahtardır.
List<SaglikSatiri> kartSagligi(List<Kisi> kisiler) {
  final sirali = [for (var i = 0; i < kisiler.length; i++) (sira: i, kisi: kisiler[i])]
    ..sort((a, b) {
      final fark = a.kisi.pil.compareTo(b.kisi.pil);
      return fark != 0 ? fark : a.sira.compareTo(b.sira);
    });
  return [
    for (final e in sirali.take(_saglikSatirSayisi))
      SaglikSatiri(
        kart: e.kisi.id,
        kisi: e.kisi.kurum ?? gorunenAd(e.kisi),
        adsiz: e.kisi.ad == null,
        pil: e.kisi.pil,
        sorunlu: e.kisi.pil < _dusukPil,
      ),
  ];
}

int sorunluKartSayisi(List<Kisi> kisiler) => kisiler.where((k) => k.pil < _dusukPil).length;
```

```dart title=lib/mantik/rapor.dart
import '../veri/modeller.dart';
import 'bicim.dart';
import 'kisi_gorunum.dart';

// Rapor ekranı: KPI'lar ve girişimci satırları.

class Kpi {
  const Kpi(this.ad, this.deger, this.not);

  final String ad;
  final String deger;
  final String not;
}

List<Kisi> _girisimciler(List<Kisi> kisiler) => [
  for (final k in kisiler)
    if (k.rol == Rol.girisimci) k,
];

/// Beş KPI. `kayitli`: kayıtlı katılımcı sayısı.
List<Kpi> raporKpileri(List<Kisi> kisiler, int tick, {required int kayitli}) {
  final girisimciler = _girisimciler(kisiler);
  final ulasan = girisimciler.where((k) => k.ile != null).length;
  final toplamSn = girisimciler.fold<int>(0, (toplam, k) => toplam + gecenSn(k, tick));
  return [
    Kpi('Görüşme', '$ulasan', '$ulasan tanesi sürüyor'),
    Kpi('Yatırımcı–girişimci toplam', sureYazisi(toplamSn), 'bugün'),
    Kpi('Yatırımcıya ulaşan girişimci', '$ulasan/${girisimciler.length}', ''),
    const Kpi('Potansiyel anlaşma', '0', 'işaretlenmedi'),
    Kpi('Katılımcı', '$kayitli', 'kayıtlı'),
  ];
}

class RaporSatiri {
  const RaporSatiri({
    required this.kisi,
    required this.toplam,
    required this.detay,
    required this.gorusmedi,
  });

  final Kisi kisi;

  /// "1 dk 14 sn" ya da "—".
  final String toplam;
  final String detay;

  /// true → detay ciddi renkte yazılır.
  final bool gorusmedi;
}

/// Girişimciler, toplam süreye göre azalan. Dart'ın sort'u kararlı olmadığı
/// için özgün sıra ikinci anahtardır.
List<RaporSatiri> raporSatirlari(List<Kisi> kisiler, int tick, Kisi Function(String id) bul) {
  final sirali = [
    for (var i = 0; i < kisiler.length; i++)
      if (kisiler[i].rol == Rol.girisimci) (sira: i, kisi: kisiler[i]),
  ]..sort((a, b) {
      final fark = gecenSn(b.kisi, tick).compareTo(gecenSn(a.kisi, tick));
      return fark != 0 ? fark : a.sira.compareTo(b.sira);
    });
  return [
    for (final e in sirali) _satir(e.kisi, tick, bul),
  ];
}

RaporSatiri _satir(Kisi k, int tick, Kisi Function(String id) bul) {
  final ile = k.ile;
  if (ile == null) {
    return RaporSatiri(kisi: k, toplam: '—', detay: '⚠ Hiç yatırımcıyla görüşmedi', gorusmedi: true);
  }
  final sure = sureYazisi(gecenSn(k, tick));
  return RaporSatiri(kisi: k, toplam: sure, detay: '${gorunenAd(bul(ile))} ($sure)', gorusmedi: false);
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test test/mantik && flutter analyze
```

Beklenen: `All tests passed!` (önceki 33 + 10 + 6 = 49 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 4: Mantık — eşik, grafik geometrisi, kart sağlığı ve rapor hesapları

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: EtkinlikDeposu

**Files:**
- Create: `lib/veri/etkinlik_deposu.dart`
- Test: `test/veri/etkinlik_deposu_test.dart`

**Interfaces:**
- Consumes: `SahteVeri`, modeller (Task 1); `saatYazisi`, `kisaSaatYazisi` (Task 2); `esikSinirla` (Task 4).
- Produces: `class EtkinlikDeposu extends ChangeNotifier`
  - `EtkinlikDeposu({bool? aliciBagli, List<Bildirim>? bildirimler})` — `aliciBagli` verilmezse `--dart-define=ALICI_BAGLI` (varsayılan `true`)
  - Sabit veri: `String etkinlikAdi, tarihMekan, raporTarihi, cizelgeBaslangici`; `int duyulanKartSayisi, kayitliKatilimci`; `List<Kisi> kisiler`; `List<Bildirim> bildirimler`; `List<Cift> ciftler`; `List<KisiRengi> seriRenkleri`; `List<AcikKart> acikKartlar`
  - Durum: `bool aliciBagli`, `int tick`, `int saatSn`, `String saat`, `String saatKisa`, `int esik`
  - İşlevler: `Kisi bul(String id)`, `void baslat()`, `void ilerlet()`, `void sifirla()`, `void esikAyarla(int deger)`, `void esikArtir()`, `void esikAzalt()`, `void dispose()`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/veri/etkinlik_deposu_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

void main() {
  test('başlangıç durumu', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    expect(d.tick, 0);
    expect(d.saat, '15:10:09');
    expect(d.saatKisa, '15:10');
    expect(d.esik, -72);
    expect(d.aliciBagli, isTrue);
    expect(d.etkinlikAdi, 'Yatırımcı Buluşması');
    expect(d.tarihMekan, '28.09.2026 · Demo Salonu');
    expect(d.raporTarihi, '02.10.2026');
    expect(d.cizelgeBaslangici, '15:10');
    expect(d.duyulanKartSayisi, 32);
    expect(d.kayitliKatilimci, 25);
    expect(d.kisiler, hasLength(26));
    expect(d.bildirimler, hasLength(4));
    expect(d.ciftler, hasLength(10));
    expect(d.seriRenkleri, hasLength(6));
    expect(d.acikKartlar, hasLength(9));
  });

  test('alıcı durumu ve bildirimler dışarıdan verilebilir', () {
    final d = EtkinlikDeposu(aliciBagli: false, bildirimler: const []);
    addTearDown(d.dispose);
    expect(d.aliciBagli, isFalse);
    expect(d.bildirimler, isEmpty);
  });

  test('ilerlet: tick ve saat birer saniye artar, dinleyiciler haberdar olur', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    var bildirim = 0;
    d.addListener(() => bildirim++);
    d.ilerlet();
    d.ilerlet();
    expect(d.tick, 2);
    expect(d.saat, '15:10:11');
    expect(bildirim, 2);
  });

  test('sifirla: yalnız süre sayacı sıfırlanır, saat akmaya devam eder', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    d.ilerlet();
    d.ilerlet();
    d.sifirla();
    expect(d.tick, 0);
    expect(d.saat, '15:10:11');
    d.ilerlet();
    expect(d.tick, 1);
    expect(d.saat, '15:10:12');
  });

  test('eşik: sınırlarda durur, ±1 çalışır', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    d.esikAyarla(-200);
    expect(d.esik, -95);
    d.esikAzalt();
    expect(d.esik, -95);
    d.esikAyarla(0);
    expect(d.esik, -35);
    d.esikArtir();
    expect(d.esik, -35);
    d.esikAyarla(-70);
    d.esikArtir();
    expect(d.esik, -69);
    d.esikAzalt();
    d.esikAzalt();
    expect(d.esik, -71);
  });

  test('değişmeyen eşik bildirim göndermez', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    var bildirim = 0;
    d.addListener(() => bildirim++);
    d.esikAyarla(-72);
    expect(bildirim, 0);
    d.esikAyarla(-71);
    expect(bildirim, 1);
  });

  test('bul: kişiyi getirir; bilinmeyen kart hata verir', () {
    final d = EtkinlikDeposu();
    addTearDown(d.dispose);
    expect(d.bul('24').ad, 'Cem Erdem');
    expect(() => d.bul('999'), throwsStateError);
  });

  testWidgets('baslat: saniyede bir ilerler; dispose zamanlayıcıyı durdurur', (tester) async {
    final d = EtkinlikDeposu();
    d.baslat();
    d.baslat(); // ikinci çağrı yeni zamanlayıcı açmaz
    await tester.pump(const Duration(seconds: 3));
    expect(d.tick, 3);
    d.dispose();
    await tester.pump(const Duration(seconds: 3));
    // Zamanlayıcı durmasaydı test "A Timer is still pending" hatasıyla düşerdi.
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/veri/etkinlik_deposu_test.dart
```

Beklenen: derleme hatası — `Error when reading 'lib/veri/etkinlik_deposu.dart': No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/veri/etkinlik_deposu.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../mantik/bicim.dart';
import '../mantik/kurulum.dart';
import 'modeller.dart';
import 'sahte_veri.dart';

/// Ekranların veriye TEK erişim noktası. Bugün gömülü sahte veriyi verir ve
/// saati kendi yürütür; gerçek sunucuya geçiş ileride yalnız bu katmanı değiştirir.
class EtkinlikDeposu extends ChangeNotifier {
  /// `aliciBagli` verilmezse derleme değişkeni okunur:
  /// `flutter run --dart-define=ALICI_BAGLI=false` kopuk durumu gösterir.
  /// `bildirimler` yalnız testlerde (boş durum) verilir.
  EtkinlikDeposu({bool? aliciBagli, List<Bildirim>? bildirimler})
    : aliciBagli = aliciBagli ?? const bool.fromEnvironment('ALICI_BAGLI', defaultValue: true),
      bildirimler = bildirimler ?? SahteVeri.bildirimler;

  final bool aliciBagli;
  final List<Bildirim> bildirimler;

  String get etkinlikAdi => SahteVeri.etkinlikAdi;
  String get tarihMekan => SahteVeri.tarihMekan;
  String get raporTarihi => SahteVeri.raporTarihi;
  String get cizelgeBaslangici => SahteVeri.cizelgeBaslangici;
  int get duyulanKartSayisi => SahteVeri.duyulanKartSayisi;
  int get kayitliKatilimci => SahteVeri.kayitliKatilimci;
  List<Kisi> get kisiler => SahteVeri.kisiler;
  List<Cift> get ciftler => SahteVeri.ciftler;
  List<KisiRengi> get seriRenkleri => SahteVeri.seriRenkleri;
  List<AcikKart> get acikKartlar => SahteVeri.acikKartlar;

  int _tick = 0;
  int _saatSn = SahteVeri.baslangicSaatSn;
  int _esik = SahteVeri.baslangicEsik;
  Timer? _zamanlayici;

  /// Sıfırla'dan bu yana geçen saniye; "birlikte" süreleri bununla akar.
  int get tick => _tick;

  /// Günün saniyesi.
  int get saatSn => _saatSn;
  String get saat => saatYazisi(_saatSn);
  String get saatKisa => kisaSaatYazisi(_saatSn);

  /// "Birlikte" sayılmak için gereken en düşük sinyal gücü (dBm).
  int get esik => _esik;

  Kisi bul(String id) => kisiler.firstWhere((k) => k.id == id);

  /// Saati başlatır (saniyede bir `ilerlet`). Yeniden çağırmak etkisizdir.
  void baslat() {
    _zamanlayici ??= Timer.periodic(const Duration(seconds: 1), (_) => ilerlet());
  }

  /// Bir saniye ilerletir. Zamanlayıcı bunu çağırır; testler doğrudan çağırır.
  void ilerlet() {
    _tick++;
    _saatSn++;
    notifyListeners();
  }

  /// Süre sayacını sıfırlar. Saat akmaya devam eder.
  void sifirla() {
    _tick = 0;
    notifyListeners();
  }

  void esikAyarla(int deger) {
    final yeni = esikSinirla(deger);
    if (yeni == _esik) return;
    _esik = yeni;
    notifyListeners();
  }

  void esikArtir() => esikAyarla(_esik + 1);

  void esikAzalt() => esikAyarla(_esik - 1);

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (11 + 49 + 8 = 68 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 5: EtkinlikDeposu — saat, süre sayacı, eşik; sahte veriye tek erişim noktası

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---
### Task 6: Tema

**Files:**
- Create: `lib/tema/renkler.dart`, `lib/tema/olculer.dart`, `lib/tema/yazi.dart`, `lib/tema/tema.dart`
- Test: `test/tema/tema_test.dart`

**Interfaces:**
- Consumes: `KisiRengi`, `DurumTonu`, `Onem` (Task 1).
- Produces:
  - `abstract final class Renkler` → `zemin, yuzey, acikYuzey, ayrac, kenarlik, metin, metinKoyu2, metin2, metinSoluk, ipucu, vurgu, vurguZemin, vurguBasili, vurguKoyu, birlikte, birlikteZemin, uyari, ciddi, ciddiZemin, ciddiKoyu, perde, ikincilBasili, hayaletBasili, golge1, golge2` (hepsi `static const Color`); `static Color kisi(KisiRengi)`, `static Color ton(DurumTonu)`, `static Color onem(Onem)`
  - `abstract final class Olculer` → `sayfaKenari = 20`, `kose = 12`, `koseAltSayfa = 20`, `hap = 999`, `dokunmaEnAz = 44` (`double`); `koseYaricap`, `hapYaricap` (`BorderRadius`); `altSayfaGolgesi` (`List<BoxShadow>`)
  - `abstract final class Yazi` → `static TextStyle olcu(double punto, {FontWeight agirlik = FontWeight.w400, double satir = 1.4, Color renk = Renkler.metin, bool rakam = false, FontStyle? stil, double harfAraligi = 0})`, `static TextStyle baslik(double punto, double satir)`, `static final TextStyle govde`, `static final TextStyle kicker`
  - `ThemeData yakinlikTemasi()`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/tema/tema_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/tema/olculer.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/tema/tema.dart';
import 'package:yakinlik_mobil/tema/yazi.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

void main() {
  test("yüzey ve metin token'ları README ile aynı", () {
    expect(Renkler.zemin, const Color(0xFFF7F2E9));
    expect(Renkler.yuzey, const Color(0xFFFFFDF8));
    expect(Renkler.acikYuzey, const Color(0xFFEFE7D8));
    expect(Renkler.ayrac, const Color(0xFFE2D8C4));
    expect(Renkler.kenarlik, const Color(0xFFCFC2A9));
    expect(Renkler.metin, const Color(0xFF3B332C));
    expect(Renkler.metinKoyu2, const Color(0xFF4D453C));
    expect(Renkler.metin2, const Color(0xFF6B6156));
    expect(Renkler.metinSoluk, const Color(0xFF92897C));
  });

  test("vurgu ve durum token'ları README ile aynı", () {
    expect(Renkler.vurgu, const Color(0xFF9A6512));
    expect(Renkler.vurguZemin, const Color(0xFFF5E8CF));
    expect(Renkler.vurguBasili, const Color(0xFF7F5410));
    expect(Renkler.vurguKoyu, const Color(0xFF5C3D0A));
    expect(Renkler.birlikte, const Color(0xFF1B7A4E));
    expect(Renkler.birlikteZemin, const Color(0xFFE0F2E4));
    expect(Renkler.uyari, const Color(0xFFB4470E));
    expect(Renkler.ciddi, const Color(0xFFB02A25));
    expect(Renkler.ciddiZemin, const Color(0xFFF9E2E0));
    expect(Renkler.ciddiKoyu, const Color(0xFF8A1F1B));
  });

  test('kişi paleti', () {
    expect(Renkler.kisi(KisiRengi.mavi), const Color(0xFF1245AF));
    expect(Renkler.kisi(KisiRengi.turuncu), const Color(0xFF854412));
    expect(Renkler.kisi(KisiRengi.hardal), const Color(0xFF968403));
    expect(Renkler.kisi(KisiRengi.pembe), const Color(0xFF920F6D));
    expect(Renkler.kisi(KisiRengi.mor), const Color(0xFF895CD2));
    expect(Renkler.kisi(KisiRengi.mercan), const Color(0xFFCC646F));
    expect(Renkler.kisi(KisiRengi.petrol), const Color(0xFF248FB2));
    expect(Renkler.kisi(KisiRengi.gri), const Color(0xFF302F2E));
  });

  test('durum tonu ve önem renkleri', () {
    expect(Renkler.ton(DurumTonu.birlikte), Renkler.birlikte);
    expect(Renkler.ton(DurumTonu.uyari), Renkler.uyari);
    expect(Renkler.ton(DurumTonu.ikincil), Renkler.metin2);
    expect(Renkler.ton(DurumTonu.ciddi), Renkler.ciddi);
    expect(Renkler.onem(Onem.ciddi), Renkler.ciddi);
    expect(Renkler.onem(Onem.uyari), Renkler.uyari);
    expect(Renkler.onem(Onem.olumlu), Renkler.vurguBasili);
  });

  test('yeşil yalnız "birlikte" anlamında kullanılır', () {
    for (final t in DurumTonu.values.where((t) => t != DurumTonu.birlikte)) {
      expect(Renkler.ton(t), isNot(Renkler.birlikte), reason: '$t');
    }
    for (final r in KisiRengi.values) {
      expect(Renkler.kisi(r), isNot(Renkler.birlikte), reason: '$r');
    }
    for (final o in Onem.values) {
      expect(Renkler.onem(o), isNot(Renkler.birlikte), reason: '$o');
    }
  });

  test('yazı stilleri', () {
    expect(Yazi.govde.fontSize, 15);
    expect(Yazi.govde.height, 1.4);
    expect(Yazi.govde.color, Renkler.metin);
    final h1 = Yazi.baslik(22, 1.15);
    expect(h1.fontWeight, FontWeight.w600);
    expect(h1.height, 1.15);
    expect(h1.letterSpacing, closeTo(-0.33, 1e-9));
    expect(Yazi.kicker.fontSize, 11);
    expect(Yazi.kicker.letterSpacing, 1.1);
    expect(Yazi.kicker.color, Renkler.metin2);
    expect(Yazi.olcu(15, rakam: true).fontFeatures, const [FontFeature.tabularFigures()]);
    expect(Yazi.olcu(15).fontFeatures, isNull);
  });

  test('ölçüler', () {
    expect(Olculer.sayfaKenari, 20);
    expect(Olculer.kose, 12);
    expect(Olculer.koseAltSayfa, 20);
    expect(Olculer.dokunmaEnAz, 44);
    expect(Olculer.koseYaricap, BorderRadius.circular(12));
    expect(Olculer.altSayfaGolgesi, hasLength(2));
  });

  test('tema: README eşlemesi', () {
    final t = yakinlikTemasi();
    expect(t.brightness, Brightness.light);
    expect(t.scaffoldBackgroundColor, Renkler.zemin);
    expect(t.colorScheme.primary, Renkler.vurgu);
    expect(t.colorScheme.onPrimary, Renkler.yuzey);
    expect(t.colorScheme.surface, Renkler.yuzey);
    expect(t.colorScheme.onSurface, Renkler.metin);
    expect(t.colorScheme.error, Renkler.ciddi);
    expect(t.colorScheme.outline, Renkler.kenarlik);
    expect(t.dividerColor, Renkler.ayrac);
    expect(t.splashFactory, NoSplash.splashFactory);
    expect(t.textTheme.bodyMedium!.fontSize, 15);
    expect(t.bottomNavigationBarTheme.backgroundColor, Renkler.yuzey);
    expect(t.bottomNavigationBarTheme.selectedItemColor, Renkler.vurguBasili);
    expect(t.bottomNavigationBarTheme.unselectedItemColor, Renkler.metin2);
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/tema/tema_test.dart
```

Beklenen: derleme hatası — `Error when reading 'lib/tema/olculer.dart': No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/tema/renkler.dart
import 'package:flutter/painting.dart';

import '../veri/modeller.dart';

/// Tüm renk token'ları (docs/tasarim/README.md, tema = web).
/// Renk sabiti YALNIZ bu klasörde yazılır; ekranlar buradan okur.
abstract final class Renkler {
  // --- Yüzeyler ---
  static const zemin = Color(0xFFF7F2E9);
  static const yuzey = Color(0xFFFFFDF8);
  static const acikYuzey = Color(0xFFEFE7D8);
  static const ayrac = Color(0xFFE2D8C4);
  static const kenarlik = Color(0xFFCFC2A9);

  // --- Metin ---
  static const metin = Color(0xFF3B332C);
  static const metinKoyu2 = Color(0xFF4D453C);
  static const metin2 = Color(0xFF6B6156);
  static const metinSoluk = Color(0xFF92897C);

  /// Girdi ipucu yazısı: metin renginin %65'i.
  static const ipucu = Color(0xA63B332C);

  // --- Vurgu (altın) ---
  static const vurgu = Color(0xFF9A6512);
  static const vurguZemin = Color(0xFFF5E8CF);
  static const vurguBasili = Color(0xFF7F5410);
  static const vurguKoyu = Color(0xFF5C3D0A);

  // --- Durumlar. YEŞİL yalnız "şu an birlikte" demektir. ---
  static const birlikte = Color(0xFF1B7A4E);
  static const birlikteZemin = Color(0xFFE0F2E4);
  static const uyari = Color(0xFFB4470E);
  static const ciddi = Color(0xFFB02A25);
  static const ciddiZemin = Color(0xFFF9E2E0);
  static const ciddiKoyu = Color(0xFF8A1F1B);

  // --- Kaplamalar ve gölge ---
  /// Alt sayfanın arkasındaki perde: rgba(32,30,29,.35).
  static const perde = Color(0x59201E1D);

  /// İkincil düğme basılıyken: metin %14.
  static const ikincilBasili = Color(0x243B332C);

  /// Hayalet düğme basılıyken: vurgu %18.
  static const hayaletBasili = Color(0x2E9A6512);
  static const golge1 = Color(0x143B332C);
  static const golge2 = Color(0x1F3B332C);

  /// Kişi paleti: renk kişiyi takip eder, sıraya göre değişmez.
  static Color kisi(KisiRengi renk) => switch (renk) {
    KisiRengi.mavi => const Color(0xFF1245AF),
    KisiRengi.turuncu => const Color(0xFF854412),
    KisiRengi.hardal => const Color(0xFF968403),
    KisiRengi.pembe => const Color(0xFF920F6D),
    KisiRengi.mor => const Color(0xFF895CD2),
    KisiRengi.mercan => const Color(0xFFCC646F),
    KisiRengi.petrol => const Color(0xFF248FB2),
    KisiRengi.gri => const Color(0xFF302F2E),
  };

  /// Durum yazısının rengi.
  static Color ton(DurumTonu ton) => switch (ton) {
    DurumTonu.birlikte => birlikte,
    DurumTonu.uyari => uyari,
    DurumTonu.ikincil => metin2,
    DurumTonu.ciddi => ciddi,
  };

  /// Bildirim noktasının rengi.
  static Color onem(Onem onem) => switch (onem) {
    Onem.ciddi => ciddi,
    Onem.uyari => uyari,
    Onem.olumlu => vurguBasili,
  };
}
```

```dart title=lib/tema/olculer.dart
import 'package:flutter/painting.dart';

import 'renkler.dart';

/// Boşluk, köşe ve gölge sabitleri (README "Boşluk ve köşe").
abstract final class Olculer {
  /// Sayfanın yatay kenar boşluğu.
  static const double sayfaKenari = 20;

  /// Kart ve liste köşesi.
  static const double kose = 12;

  /// Alt sayfanın üst köşeleri.
  static const double koseAltSayfa = 20;

  /// Düğme, çip, girdi ve etiket köşesi (hap).
  static const double hap = 999;

  /// En küçük dokunma hedefi.
  static const double dokunmaEnAz = 44;

  static const BorderRadius koseYaricap = BorderRadius.all(Radius.circular(kose));
  static const BorderRadius hapYaricap = BorderRadius.all(Radius.circular(hap));

  static const List<BoxShadow> altSayfaGolgesi = [
    BoxShadow(color: Renkler.golge1, offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Renkler.golge2, offset: Offset(0, 4), blurRadius: 16),
  ];
}
```

```dart title=lib/tema/yazi.dart
import 'package:flutter/painting.dart';

import 'renkler.dart';

/// Metin stilleri. Yazı tipi sistem fontudur (iOS SF, Android Roboto).
abstract final class Yazi {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Genel metin stili. `satir` CSS line-height çarpanıdır; `rakam` sayıların
  /// titrememesi için eşit genişlikli rakam açar.
  static TextStyle olcu(
    double punto, {
    FontWeight agirlik = FontWeight.w400,
    double satir = 1.4,
    Color renk = Renkler.metin,
    bool rakam = false,
    FontStyle? stil,
    double harfAraligi = 0,
  }) {
    return TextStyle(
      fontSize: punto,
      fontWeight: agirlik,
      height: satir,
      color: renk,
      fontStyle: stil,
      letterSpacing: harfAraligi,
      fontFeatures: rakam ? _tabular : null,
      leadingDistribution: TextLeadingDistribution.even,
      decoration: TextDecoration.none,
    );
  }

  /// Başlık (h1/h2): ağırlık 600, harf aralığı −0.015em.
  static TextStyle baslik(double punto, double satir) =>
      olcu(punto, agirlik: FontWeight.w600, satir: satir, harfAraligi: -0.015 * punto);

  /// Gövde: 15 px / 1.4.
  static final TextStyle govde = olcu(15);

  /// Kicker: 11 px, harf aralığı .1em, ikincil renk (metin büyük harfe çevrilir).
  static final TextStyle kicker = olcu(11, renk: Renkler.metin2, harfAraligi: 1.1);
}
```

```dart title=lib/tema/tema.dart
import 'package:flutter/material.dart';

import 'renkler.dart';
import 'yazi.dart';

/// Uygulamanın tek teması (README "Flutter eşlemesi").
ThemeData yakinlikTemasi() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Renkler.zemin,
    colorScheme: const ColorScheme.light(
      primary: Renkler.vurgu,
      onPrimary: Renkler.yuzey,
      surface: Renkler.yuzey,
      onSurface: Renkler.metin,
      error: Renkler.ciddi,
      outline: Renkler.kenarlik,
    ),
    dividerColor: Renkler.ayrac,
    // Sakin hareket: Material dalga efekti yok; basılı durumu bileşenler verir.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    textTheme: TextTheme(bodyLarge: Yazi.govde, bodyMedium: Yazi.govde),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Renkler.vurgu,
      selectionColor: Renkler.vurguZemin,
      selectionHandleColor: Renkler.vurgu,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Renkler.yuzey,
      elevation: 0,
      selectedItemColor: Renkler.vurguBasili,
      unselectedItemColor: Renkler.metin2,
      selectedLabelStyle: TextStyle(fontSize: 11, height: 1.4),
      unselectedLabelStyle: TextStyle(fontSize: 11, height: 1.4),
      showUnselectedLabels: true,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Renkler.vurgu,
      inactiveTrackColor: Renkler.ayrac,
      thumbColor: Renkler.vurgu,
      overlayColor: Renkler.hayaletBasili,
      trackHeight: 4,
      tickMarkShape: SliderTickMarkShape.noTickMark,
    ),
  );
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (68 + 8 = 76 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 6: Tema — renk token'ları, ölçüler, yazı stilleri, ThemeData

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: Ortak bileşenler

**Files:**
- Create: `lib/bilesenler/dokunma_hedefi.dart`, `hap_dugme.dart`, `etiket.dart`, `cip.dart`, `bolmeli_anahtar.dart`, `arama_alani.dart`, `kicker.dart`, `rol_sekli.dart`, `basili_opaklik.dart`, `etiketli_deger.dart`, `kesik_cizgi.dart` (hepsi `lib/bilesenler/` altında)
- Test: `test/yardimci.dart`, `test/bilesenler/bilesenler_test.dart`

**Interfaces:**
- Consumes: `Renkler`, `Olculer`, `Yazi`, `yakinlikTemasi` (Task 6); `Rol`, `KisiRengi` (Task 1); `rolAdi`, `trBuyuk` (Task 2).
- Produces:
  - `DokunmaHedefi({required VoidCallback? onTap, required Widget child, ValueChanged<bool>? onBasili, bool genis = false})`
  - `enum HapTuru { birincil, ikincil, hayalet }`, `void islevsiz()`, `HapDugme({required String etiket, required VoidCallback onTap, HapTuru tur = HapTuru.ikincil, double yukseklik = 44, double punto = 14, double? yatayBosluk, double? genislik, bool genis = false, Color? zemin, Widget? icerik, String? anlam})`
  - `enum EtiketTuru { vurgu, notr }`, `Etiket(String metin, {EtiketTuru tur = EtiketTuru.vurgu, VoidCallback? onTap})`
  - `Cip({required String etiket, required bool secili, required VoidCallback onTap, String? sayi, Color seciliRenk = Renkler.vurgu, double yatayBosluk = 14})`
  - `BolmeSecenegi<T>({required T deger, required String etiket, String? ek})`, `BolmeliAnahtar<T>({required List<BolmeSecenegi<T>> secenekler, required T secili, required ValueChanged<T> onSecildi, double yukseklik = 44, double punto = 14, FontWeight agirlik = FontWeight.w400, double ekPunto = 12, bool araCizgi = false})`
  - `AramaAlani({required String ipucu, TextEditingController? denetleyici, ValueChanged<String>? onDegisti, double yukseklik = 44, double punto = 15, FontWeight agirlik = FontWeight.w400, double harfAraligi = 0, bool rakam = false})`
  - `Kicker(String metin, {String? sayi})`
  - `RolSekli({required Rol rol, required KisiRengi renk, double boyut = 12})`
  - `BasiliOpaklik({required VoidCallback? onTap, required Widget child, double opaklik = 0.7})`
  - `EtiketliDeger({required String etiket, required String deger, TextStyle? stil})`
  - `void kesikCizgi(Canvas canvas, Offset bas, Offset son, Paint boya, {required double dolu, required double bos})`
  - Test yardımcıları: `Widget temali(Widget child)`, `void telefonBoyutu(WidgetTester tester, {double genislik = 402, double yukseklik = 874})`

- [ ] **Step 1: Test yardımcısını ve başarısız testi yaz**

```dart title=test/yardimci.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/tema/tema.dart';

/// Bir widget'ı uygulama temasıyla ve Scaffold içinde sarar.
Widget temali(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: yakinlikTemasi(),
    home: Scaffold(body: child),
  );
}

/// Test yüzeyini telefon boyutuna getirir (mantıksal piksel). Varsayılan,
/// prototip çerçevesiyle aynıdır: 402 × 874.
void telefonBoyutu(WidgetTester tester, {double genislik = 402, double yukseklik = 874}) {
  tester.view.physicalSize = Size(genislik, yukseklik);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
```

```dart title=test/bilesenler/bilesenler_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/arama_alani.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/bilesenler/bolmeli_anahtar.dart';
import 'package:yakinlik_mobil/bilesenler/cip.dart';
import 'package:yakinlik_mobil/bilesenler/dokunma_hedefi.dart';
import 'package:yakinlik_mobil/bilesenler/etiket.dart';
import 'package:yakinlik_mobil/bilesenler/etiketli_deger.dart';
import 'package:yakinlik_mobil/bilesenler/hap_dugme.dart';
import 'package:yakinlik_mobil/bilesenler/kesik_cizgi.dart';
import 'package:yakinlik_mobil/bilesenler/kicker.dart';
import 'package:yakinlik_mobil/bilesenler/rol_sekli.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

import '../yardimci.dart';

class _DenemeCizici extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    kesikCizgi(canvas, Offset.zero, const Offset(20, 0), Paint(), dolu: 4, bos: 4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  group('DokunmaHedefi', () {
    testWidgets('küçük görseli büyütmeden 44 × 44 dokunma alanı verir', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(Center(child: DokunmaHedefi(onTap: () => sayac++, child: const SizedBox(width: 20, height: 20)))),
      );
      expect(tester.getSize(find.byType(DokunmaHedefi)), const Size(44, 44));
      // Görselin dışına, ama 44 px'lik alanın içine dokun.
      await tester.tapAt(tester.getCenter(find.byType(DokunmaHedefi)) + const Offset(18, 18));
      expect(sayac, 1);
    });
  });

  group('HapDugme', () {
    Finder dolguKutusu() =>
        find.descendant(of: find.byType(HapDugme), matching: find.byType(DecoratedBox)).first;

    testWidgets('dokununca çağırır; görsel 36 px olsa da dokunma alanı 44 px', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(Center(child: HapDugme(etiket: 'Geri al', yukseklik: 36, onTap: () => sayac++))),
      );
      await tester.tap(find.text('Geri al'));
      expect(sayac, 1);
      expect(tester.getSize(find.byType(HapDugme)).height, 44);
      expect(tester.getSize(dolguKutusu()).height, 36);
    });

    testWidgets('genis: bulunduğu genişliği doldurur', (tester) async {
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 300,
              child: HapDugme(etiket: 'Onayla', tur: HapTuru.birincil, yukseklik: 48, genis: true, onTap: islevsiz),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(HapDugme)), const Size(300, 48));
      expect(tester.getSize(dolguKutusu()), const Size(300, 48));
    });

    testWidgets('sabit genişlik: 48 × 48', (tester) async {
      await tester.pumpWidget(
        temali(const Center(child: HapDugme(etiket: '+1', genislik: 48, yukseklik: 48, punto: 18, onTap: islevsiz))),
      );
      expect(tester.getSize(find.byType(HapDugme)), const Size(48, 48));
    });

    testWidgets('birincil düğme basılıyken koyulaşır', (tester) async {
      await tester.pumpWidget(
        temali(const Center(child: HapDugme(etiket: 'Onayla', tur: HapTuru.birincil, onTap: islevsiz))),
      );
      Color? dolgu() => (tester.widget<DecoratedBox>(dolguKutusu()).decoration as BoxDecoration).color;
      expect(dolgu(), Renkler.vurgu);
      final hareket = await tester.startGesture(tester.getCenter(find.text('Onayla')));
      await tester.pump(const Duration(milliseconds: 150));
      expect(dolgu(), Renkler.vurguBasili);
      await hareket.up();
      await tester.pump();
      expect(dolgu(), Renkler.vurgu);
    });

    testWidgets('ikincil düğme kenarlıklıdır; zemin verilebilir', (tester) async {
      await tester.pumpWidget(
        temali(const Center(child: HapDugme(etiket: '↶ Geri al', zemin: Renkler.zemin, onTap: islevsiz))),
      );
      final susleme = tester.widget<DecoratedBox>(dolguKutusu()).decoration as BoxDecoration;
      expect(susleme.color, Renkler.zemin);
      expect(susleme.border, Border.all(color: Renkler.kenarlik));
    });
  });

  group('Etiket', () {
    testWidgets('dokunulabilir etiket: dokunma alanı 44 px', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(Center(child: Etiket('Eşik −72 dBm', tur: EtiketTuru.notr, onTap: () => sayac++))),
      );
      await tester.tap(find.text('Eşik −72 dBm'));
      expect(sayac, 1);
      expect(tester.getSize(find.byType(Etiket)).height, 44);
    });

    testWidgets('dokunulamaz etiket 28 px', (tester) async {
      await tester.pumpWidget(temali(const Center(child: Etiket('● Alıcı bağlı'))));
      expect(tester.getSize(find.byType(Etiket)).height, 28);
    });
  });

  group('Cip', () {
    BoxDecoration susleme(WidgetTester tester, String metin) =>
        tester
                .widget<DecoratedBox>(
                  find.ancestor(of: find.text(metin), matching: find.byType(DecoratedBox)).first,
                )
                .decoration
            as BoxDecoration;

    testWidgets('seçili çip dolgu rengini alır; dokununca çağırır', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Cip(etiket: 'Tümü', secili: true, onTap: islevsiz),
                Cip(etiket: 'Yatırımcı', secili: false, onTap: () => sayac++),
              ],
            ),
          ),
        ),
      );
      expect(susleme(tester, 'Tümü').color, Renkler.vurgu);
      expect(susleme(tester, 'Yatırımcı').color, isNull);
      await tester.tap(find.text('Yatırımcı'));
      expect(sayac, 1);
      expect(tester.getSize(find.byType(Cip).first).height, 44);
    });

    testWidgets('sayı etiketin yanında; seçili renk değiştirilebilir', (tester) async {
      await tester.pumpWidget(
        temali(
          const Center(
            child: Cip(etiket: 'Ciddi', sayi: '1', secili: true, seciliRenk: Renkler.metin, onTap: islevsiz),
          ),
        ),
      );
      expect(find.text('Ciddi 1'), findsOneWidget);
      expect(susleme(tester, 'Ciddi 1').color, Renkler.metin);
    });
  });

  group('BolmeliAnahtar', () {
    testWidgets('seçince değeri bildirir; ek yazı etiketin yanında', (tester) async {
      String? secilen;
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 362,
              child: BolmeliAnahtar<String>(
                yukseklik: 40,
                secenekler: const [
                  BolmeSecenegi(deger: 'kisiler', etiket: 'Kişiler', ek: '26'),
                  BolmeSecenegi(deger: 'ag', etiket: 'Ağ'),
                  BolmeSecenegi(deger: 'bildirimler', etiket: 'Bildirimler', ek: '4'),
                ],
                secili: 'kisiler',
                onSecildi: (d) => secilen = d,
              ),
            ),
          ),
        ),
      );
      expect(find.text('26'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(tester.getSize(find.byType(BolmeliAnahtar<String>)), const Size(362, 40));
      await tester.tap(find.text('Ağ'));
      expect(secilen, 'ag');
    });
  });

  group('AramaAlani', () {
    testWidgets('yazınca bildirir; en az 44 px', (tester) async {
      String? son;
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 362,
              child: AramaAlani(ipucu: 'Ara: ad, kurum, kart no', onDegisti: (s) => son = s),
            ),
          ),
        ),
      );
      expect(find.text('Ara: ad, kurum, kart no'), findsOneWidget);
      expect(tester.getSize(find.byType(AramaAlani)).height, greaterThanOrEqualTo(44));
      await tester.enterText(find.byType(TextField), 'nova');
      expect(son, 'nova');
    });

    testWidgets('rakam modu harf kabul etmez', (tester) async {
      final denetleyici = TextEditingController();
      addTearDown(denetleyici.dispose);
      await tester.pumpWidget(
        temali(
          Center(
            child: SizedBox(
              width: 200,
              child: AramaAlani(ipucu: 'Örn. 14', denetleyici: denetleyici, rakam: true, yukseklik: 52, punto: 24),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '1a2b');
      expect(denetleyici.text, '12');
      expect(tester.getSize(find.byType(AramaAlani)).height, greaterThanOrEqualTo(52));
    });
  });

  group('Kicker', () {
    testWidgets('Türkçe büyük harf ve sayı', (tester) async {
      await tester.pumpWidget(temali(const Center(child: Kicker('Girişimciler', sayi: '12'))));
      expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });
  });

  group('RolSekli', () {
    testWidgets('anlam etiketi rol adıdır; boyut korunur', (tester) async {
      final anlam = tester.ensureSemantics();
      await tester.pumpWidget(
        temali(
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RolSekli(rol: Rol.yatirimci, renk: KisiRengi.mavi),
                RolSekli(rol: Rol.girisimci, renk: KisiRengi.hardal),
                RolSekli(rol: Rol.misafir, renk: KisiRengi.pembe, boyut: 14),
              ],
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Yatırımcı'), findsOneWidget);
      expect(find.bySemanticsLabel('Girişimci'), findsOneWidget);
      expect(find.bySemanticsLabel('Misafir'), findsOneWidget);
      expect(tester.getSize(find.byType(RolSekli).first), const Size(12, 12));
      expect(tester.getSize(find.byType(RolSekli).last), const Size(14, 14));
      anlam.dispose();
    });
  });

  group('BasiliOpaklik', () {
    testWidgets('dokununca çağırır; basılıyken soluklaşır', (tester) async {
      var sayac = 0;
      await tester.pumpWidget(
        temali(
          Center(
            child: BasiliOpaklik(
              onTap: () => sayac++,
              child: const SizedBox(width: 200, height: 60, child: Text('satır')),
            ),
          ),
        ),
      );
      double opaklik() => tester
          .widget<Opacity>(find.descendant(of: find.byType(BasiliOpaklik), matching: find.byType(Opacity)))
          .opacity;
      await tester.tap(find.text('satır'));
      expect(sayac, 1);
      expect(opaklik(), 1);
      final hareket = await tester.startGesture(tester.getCenter(find.byType(BasiliOpaklik)));
      await tester.pump(const Duration(milliseconds: 150));
      expect(opaklik(), 0.7);
      await hareket.up();
      await tester.pump();
      expect(opaklik(), 1);
    });
  });

  group('EtiketliDeger', () {
    testWidgets('etiket ve değer', (tester) async {
      await tester.pumpWidget(temali(const Center(child: EtiketliDeger(etiket: 'Pil', deger: '%94'))));
      expect(find.text('Pil'), findsOneWidget);
      expect(find.text('%94'), findsOneWidget);
    });
  });

  group('kesikCizgi', () {
    testWidgets('dolu ve boş aralıklarla parça parça çizer', (tester) async {
      await tester.pumpWidget(
        temali(Center(child: CustomPaint(key: const Key('cizim'), size: const Size(20, 10), painter: _DenemeCizici()))),
      );
      expect(
        find.byKey(const Key('cizim')),
        paints
          ..line(p1: Offset.zero, p2: const Offset(4, 0))
          ..line(p1: const Offset(8, 0), p2: const Offset(12, 0))
          ..line(p1: const Offset(16, 0), p2: const Offset(20, 0)),
      );
    });
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/bilesenler/bilesenler_test.dart
```

Beklenen: derleme hatası — `lib/bilesenler/…` dosyaları için `No such file or directory`.

- [ ] **Step 3: Bileşenleri yaz**

```dart title=lib/bilesenler/dokunma_hedefi.dart
import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';

/// Görseli büyütmeden dokunma alanını en az 44 px yapar (README: "tüm dokunma
/// hedefleri ≥ 44 px"). Çocuk ortalanır; çevresindeki boşluk da dokunmayı alır.
class DokunmaHedefi extends StatelessWidget {
  const DokunmaHedefi({
    super.key,
    required this.onTap,
    required this.child,
    this.onBasili,
    this.genis = false,
  });

  final VoidCallback? onTap;

  /// Basılı durum değişince çağrılır (düğmenin rengini koyulaştırmak için).
  final ValueChanged<bool>? onBasili;

  /// true ise bulunduğu genişliği doldurur (çocuk da doldurmalıdır).
  final bool genis;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onTapDown: (_) => onBasili?.call(true),
      onTapUp: (_) => onBasili?.call(false),
      onTapCancel: () => onBasili?.call(false),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: Olculer.dokunmaEnAz, minHeight: Olculer.dokunmaEnAz),
        child: Center(widthFactor: genis ? null : 1, heightFactor: 1, child: child),
      ),
    );
  }
}
```

```dart title=lib/bilesenler/hap_dugme.dart
import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import 'dokunma_hedefi.dart';

enum HapTuru { birincil, ikincil, hayalet }

/// Prototipte işlevi olmayan düğmeler için (şartname §2): basılı görünümü
/// vardır, eylemi yoktur.
void islevsiz() {}

/// Hap biçimli düğme. Görsel yükseklik `yukseklik` kadardır; dokunma alanı en
/// az 44 px'tir.
class HapDugme extends StatefulWidget {
  const HapDugme({
    super.key,
    required this.etiket,
    required this.onTap,
    this.tur = HapTuru.ikincil,
    this.yukseklik = 44,
    this.punto = 14,
    this.yatayBosluk,
    this.genislik,
    this.genis = false,
    this.zemin,
    this.icerik,
    this.anlam,
  });

  final String etiket;
  final VoidCallback onTap;
  final HapTuru tur;

  /// Görsel yükseklik (en az).
  final double yukseklik;
  final double punto;

  /// Yatay iç boşluk; verilmezse 18 (hayalet düğmede 5).
  final double? yatayBosluk;

  /// Sabit genişlik (ör. 48 × 48 düğmeler).
  final double? genislik;

  /// true ise bulunduğu genişliği doldurur.
  final bool genis;

  /// İkincil düğmenin dolgusu (ör. bant içindeki "Geri al").
  final Color? zemin;

  /// Etiket yerine özel içerik (ör. iki uca yaslı kalibrasyon düğmesi).
  final Widget? icerik;

  /// Ekran okuyucu etiketi (ör. "✕" için "Kapat").
  final String? anlam;

  @override
  State<HapDugme> createState() => _HapDugmeState();
}

class _HapDugmeState extends State<HapDugme> {
  bool _basili = false;

  void _basiliAyarla(bool deger) {
    if (mounted && _basili != deger) setState(() => _basili = deger);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final Color? dolgu;
    final Color yazi;
    final Color? kaplama;
    switch (w.tur) {
      case HapTuru.birincil:
        dolgu = _basili ? Renkler.vurguBasili : Renkler.vurgu;
        yazi = Renkler.zemin;
        kaplama = null;
      case HapTuru.ikincil:
        dolgu = w.zemin;
        yazi = Renkler.metin;
        kaplama = _basili ? Renkler.ikincilBasili : null;
      case HapTuru.hayalet:
        dolgu = null;
        yazi = Renkler.vurgu;
        kaplama = _basili ? Renkler.hayaletBasili : null;
    }
    final sabit = w.genislik != null;
    final yatay = sabit ? 0.0 : (w.yatayBosluk ?? (w.tur == HapTuru.hayalet ? 5.0 : 18.0));

    final gorsel = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: w.yukseklik,
        minWidth: w.genislik ?? 0,
        maxWidth: w.genislik ?? double.infinity,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dolgu,
          borderRadius: Olculer.hapYaricap,
          border: w.tur == HapTuru.ikincil ? Border.all(color: Renkler.kenarlik) : null,
        ),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(color: kaplama, borderRadius: Olculer.hapYaricap),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: yatay),
            child: Center(
              widthFactor: w.genis ? null : 1,
              heightFactor: 1,
              child:
                  w.icerik ??
                  Text(
                    w.etiket,
                    textAlign: TextAlign.center,
                    style: Yazi.olcu(w.punto, agirlik: FontWeight.w600, satir: 1.2, renk: yazi),
                  ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: w.anlam,
      excludeSemantics: w.anlam != null,
      child: DokunmaHedefi(onTap: w.onTap, onBasili: _basiliAyarla, genis: w.genis, child: gorsel),
    );
  }
}
```

```dart title=lib/bilesenler/etiket.dart
import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import 'dokunma_hedefi.dart';

enum EtiketTuru { vurgu, notr }

/// Küçük hap etiket: 11 px, görsel yükseklik 28 px. `onTap` verilirse dokunma
/// alanı 44 px olur.
class Etiket extends StatelessWidget {
  const Etiket(this.metin, {super.key, this.tur = EtiketTuru.vurgu, this.onTap});

  final String metin;
  final EtiketTuru tur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (zemin, yazi) = switch (tur) {
      EtiketTuru.vurgu => (Renkler.vurguZemin, Renkler.vurguKoyu),
      EtiketTuru.notr => (Renkler.acikYuzey, Renkler.metinKoyu2),
    };
    final gorsel = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(color: zemin, borderRadius: Olculer.hapYaricap),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(metin, style: Yazi.olcu(11, renk: yazi, harfAraligi: 0.22)),
          ),
        ),
      ),
    );
    if (onTap == null) return gorsel;
    return Semantics(
      button: true,
      child: DokunmaHedefi(onTap: onTap, child: gorsel),
    );
  }
}
```

```dart title=lib/bilesenler/cip.dart
import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import 'dokunma_hedefi.dart';

/// Filtre çipi: görsel 36 px, hap, 13 px; dokunma alanı 44 px.
class Cip extends StatelessWidget {
  const Cip({
    super.key,
    required this.etiket,
    required this.secili,
    required this.onTap,
    this.sayi,
    this.seciliRenk = Renkler.vurgu,
    this.yatayBosluk = 14,
  });

  final String etiket;
  final bool secili;
  final VoidCallback onTap;

  /// Etiketin yanında soluk sayı (önem çipleri).
  final String? sayi;

  /// Seçili dolgu: filtre çiplerinde vurgu, önem çiplerinde metin rengi.
  final Color seciliRenk;
  final double yatayBosluk;

  @override
  Widget build(BuildContext context) {
    final yazi = secili ? Renkler.zemin : Renkler.metin;
    final sayi = this.sayi;
    return Semantics(
      button: true,
      selected: secili,
      child: DokunmaHedefi(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: secili ? seciliRenk : null,
              border: Border.all(color: secili ? seciliRenk : Renkler.ayrac),
              borderRadius: Olculer.hapYaricap,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: yatayBosluk),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text.rich(
                  TextSpan(
                    text: etiket,
                    children: [
                      if (sayi != null)
                        TextSpan(
                          text: ' $sayi',
                          style: TextStyle(color: yazi.withValues(alpha: 0.7)),
                        ),
                    ],
                  ),
                  style: Yazi.olcu(13, renk: yazi),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

```dart title=lib/bilesenler/bolmeli_anahtar.dart
import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';

class BolmeSecenegi<T> {
  const BolmeSecenegi({required this.deger, required this.etiket, this.ek});

  final T deger;
  final String etiket;

  /// Etiketin yanında soluk küçük yazı: sayı ("26") ya da "önerilen".
  final String? ek;
}

/// Bölmeli anahtar: 1 px çerçeve, köşe 12; seçili parça vurgu dolguludur.
class BolmeliAnahtar<T> extends StatelessWidget {
  const BolmeliAnahtar({
    super.key,
    required this.secenekler,
    required this.secili,
    required this.onSecildi,
    this.yukseklik = 44,
    this.punto = 14,
    this.agirlik = FontWeight.w400,
    this.ekPunto = 12,
    this.araCizgi = false,
  });

  final List<BolmeSecenegi<T>> secenekler;
  final T secili;
  final ValueChanged<T> onSecildi;
  final double yukseklik;
  final double punto;
  final FontWeight agirlik;
  final double ekPunto;

  /// Parçalar arasında 1 px ayraç çizer.
  final bool araCizgi;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: yukseklik,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: Renkler.ayrac),
        borderRadius: Olculer.koseYaricap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < secenekler.length; i++) Expanded(child: _parca(secenekler[i], ilk: i == 0)),
        ],
      ),
    );
  }

  Widget _parca(BolmeSecenegi<T> secenek, {required bool ilk}) {
    final seciliMi = secenek.deger == secili;
    final renk = seciliMi ? Renkler.zemin : Renkler.metin;
    return Semantics(
      button: true,
      selected: seciliMi,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSecildi(secenek.deger),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: seciliMi ? Renkler.vurgu : null,
            border: araCizgi && !ilk ? const Border(left: BorderSide(color: Renkler.ayrac)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            // Dar ekranda ya da büyük yazıda etiket sığmazsa küçülür, taşmaz.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(secenek.etiket, style: Yazi.olcu(punto, agirlik: agirlik, renk: renk)),
                  if (secenek.ek case final ek? when ek.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(ek, style: Yazi.olcu(ekPunto, renk: renk.withValues(alpha: 0.75))),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

```dart title=lib/bilesenler/arama_alani.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';

/// Hap biçimli metin girdisi: yüzey zemin, 1 px kenarlık, sol iç boşluk 16.
class AramaAlani extends StatelessWidget {
  const AramaAlani({
    super.key,
    required this.ipucu,
    this.denetleyici,
    this.onDegisti,
    this.yukseklik = 44,
    this.punto = 15,
    this.agirlik = FontWeight.w400,
    this.harfAraligi = 0,
    this.rakam = false,
  });

  final String ipucu;
  final TextEditingController? denetleyici;
  final ValueChanged<String>? onDegisti;

  /// En az yükseklik.
  final double yukseklik;
  final double punto;
  final FontWeight agirlik;
  final double harfAraligi;

  /// true: rakam klavyesi açar ve rakam dışını kabul etmez.
  final bool rakam;

  static const double _satir = 1.4;

  OutlineInputBorder _kenar(Color renk) =>
      OutlineInputBorder(borderRadius: Olculer.hapYaricap, borderSide: BorderSide(color: renk));

  @override
  Widget build(BuildContext context) {
    final dikey = math.max(0.0, (yukseklik - punto * _satir) / 2);
    return TextField(
      controller: denetleyici,
      onChanged: onDegisti,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      keyboardType: rakam ? TextInputType.number : TextInputType.text,
      textInputAction: rakam ? TextInputAction.done : TextInputAction.search,
      inputFormatters: rakam ? [FilteringTextInputFormatter.digitsOnly] : null,
      autocorrect: false,
      enableSuggestions: false,
      cursorColor: Renkler.vurgu,
      style: Yazi.olcu(punto, agirlik: agirlik, satir: _satir, harfAraligi: harfAraligi, rakam: rakam),
      decoration: InputDecoration(
        hintText: ipucu,
        hintStyle: Yazi.olcu(
          punto,
          agirlik: agirlik,
          satir: _satir,
          harfAraligi: harfAraligi,
          renk: Renkler.ipucu,
        ),
        isDense: true,
        filled: true,
        fillColor: Renkler.yuzey,
        contentPadding: EdgeInsets.fromLTRB(16, dikey, 10, dikey),
        border: _kenar(Renkler.kenarlik),
        enabledBorder: _kenar(Renkler.kenarlik),
        focusedBorder: _kenar(Renkler.vurgu),
      ),
    );
  }
}
```

```dart title=lib/bilesenler/kicker.dart
import 'package:flutter/widgets.dart';

import '../mantik/metin.dart';
import '../tema/yazi.dart';

/// Bölüm üst başlığı: 11 px, büyük harf, harf aralığı .1em, ikincil renk.
/// `sayi` verilirse yanında metin renginde yazılır ("GİRİŞİMCİLER 12").
class Kicker extends StatelessWidget {
  const Kicker(this.metin, {super.key, this.sayi});

  final String metin;
  final String? sayi;

  @override
  Widget build(BuildContext context) {
    final baslik = Text(trBuyuk(metin), style: Yazi.kicker);
    final sayi = this.sayi;
    return Semantics(
      header: true,
      child: sayi == null
          ? baslik
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(child: baslik),
                const SizedBox(width: 8),
                Text(sayi, style: Yazi.olcu(11, harfAraligi: 1.1, rakam: true)),
              ],
            ),
    );
  }
}
```

```dart title=lib/bilesenler/rol_sekli.dart
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../mantik/kisi_gorunum.dart';
import '../tema/renkler.dart';
import '../veri/modeller.dart';

/// Rol şekli: ○ yatırımcı · □ girişimci (1 px köşe) · ◇ misafir (45° dönük,
/// %85 ölçek). Kişi renginde. Kimlik yalnız renkle verilmez: şekil rolü söyler.
class RolSekli extends StatelessWidget {
  const RolSekli({super.key, required this.rol, required this.renk, this.boyut = 12});

  final Rol rol;
  final KisiRengi renk;
  final double boyut;

  @override
  Widget build(BuildContext context) {
    final daire = rol == Rol.yatirimci;
    final Widget kutu = SizedBox.square(
      dimension: boyut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Renkler.kisi(renk),
          shape: daire ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: daire ? null : const BorderRadius.all(Radius.circular(1)),
        ),
      ),
    );
    return Semantics(
      label: rolAdi(rol),
      child: rol == Rol.misafir
          ? Transform.rotate(
              angle: math.pi / 4,
              child: Transform.scale(scale: 0.85, child: kutu),
            )
          : kutu,
    );
  }
}
```

```dart title=lib/bilesenler/basili_opaklik.dart
import 'package:flutter/widgets.dart';

/// Satır düğmesi: basılıyken opaklık .7 (README "Basılı durum").
class BasiliOpaklik extends StatefulWidget {
  const BasiliOpaklik({super.key, required this.onTap, required this.child, this.opaklik = 0.7});

  final VoidCallback? onTap;
  final Widget child;
  final double opaklik;

  @override
  State<BasiliOpaklik> createState() => _BasiliOpaklikState();
}

class _BasiliOpaklikState extends State<BasiliOpaklik> {
  bool _basili = false;

  void _ayarla(bool deger) {
    if (mounted && _basili != deger) setState(() => _basili = deger);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _ayarla(true),
        onTapUp: (_) => _ayarla(false),
        onTapCancel: () => _ayarla(false),
        child: Opacity(opacity: _basili ? widget.opaklik : 1, child: widget.child),
      ),
    );
  }
}
```

```dart title=lib/bilesenler/etiketli_deger.dart
import 'package:flutter/widgets.dart';

import '../tema/renkler.dart';
import '../tema/yazi.dart';

/// Küçük etiket ve altında değeri (tanım listesi öğesi): "Pil" / "%94".
class EtiketliDeger extends StatelessWidget {
  const EtiketliDeger({super.key, required this.etiket, required this.deger, this.stil});

  final String etiket;
  final String deger;

  /// Değerin stili; verilmezse 15 px / 600.
  final TextStyle? stil;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiket, style: Yazi.olcu(12, renk: Renkler.metin2)),
        const SizedBox(height: 2),
        Text(deger, style: stil ?? Yazi.olcu(15, agirlik: FontWeight.w600)),
      ],
    );
  }
}
```

```dart title=lib/bilesenler/kesik_cizgi.dart
import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Kesikli düz çizgi (Flutter'da hazırı yok). `dolu` px çizer, `bos` px atlar.
void kesikCizgi(
  Canvas canvas,
  Offset bas,
  Offset son,
  Paint boya, {
  required double dolu,
  required double bos,
}) {
  final fark = son - bas;
  final uzunluk = fark.distance;
  if (uzunluk == 0 || dolu <= 0) return;
  final birim = fark / uzunluk;
  var konum = 0.0;
  while (konum < uzunluk) {
    final bitis = math.min(konum + dolu, uzunluk);
    canvas.drawLine(bas + birim * konum, bas + birim * bitis, boya);
    konum += dolu + bos;
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (76 + 18 = 94 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 7: Ortak bileşenler — hap düğme, etiket, çip, bölmeli anahtar, arama alanı, rol şekli

Görsel ölçüler README'deki gibi; 44 px'ten küçük düğmelerde dokunma alanı
görünmez biçimde 44 px'e genişler (DokunmaHedefi).

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---
### Task 8: Pano — durum, üst alan ve Kişiler bölümü

**Files:**
- Create: `lib/ekranlar/pano/pano_durumu.dart`, `lib/ekranlar/pano/pano_ust.dart`, `lib/ekranlar/pano/kisiler_bolumu.dart`
- Test: `test/ekranlar/pano_kisiler_test.dart`

**Interfaces:**
- Consumes: `EtkinlikDeposu` (Task 5); `PanoFiltre`, `filtreleKisiler`, `listeBasligi` (Task 3); `baslik`, `altAd`, `durumCumlesi`, `durumTonu`, `sureMetni`, `dbmYazisi` (Task 2); bileşenler (Task 7); tema (Task 6).
- Produces:
  - `enum PanoBolumu { kisiler, ag, bildirimler }`
  - `class PanoDurumu extends ChangeNotifier` → `TextEditingController aramaDenetleyici`; `PanoBolumu bolum` (başlangıç `kisiler`), `PanoFiltre filtre` (başlangıç `girisimci`), `String arama`, `Onem? onem` (`null` = Tümü); `void bolumSec(PanoBolumu)`, `void filtreSec(PanoFiltre)`, `void onemSec(Onem?)`
  - `PanoUst({required EtkinlikDeposu depo, required PanoDurumu durum, required VoidCallback onKurulumaGit})`
  - `SifirlaDiyalogu()` — `Navigator.pop(true/false)` ile kapanır
  - `KisilerBolumu({required EtkinlikDeposu depo, required PanoDurumu durum, required ValueChanged<String> onKisi})`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/ekranlar/pano_kisiler_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/ekranlar/pano/kisiler_bolumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_durumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_ust.dart';
import 'package:yakinlik_mobil/mantik/pano_filtre.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

/// Üst alan + Kişiler bölümünü, Pano ekranındaki gibi tek kaydırma içinde kurar.
class _Kurulum {
  _Kurulum(WidgetTester tester, {bool aliciBagli = true})
    : depo = EtkinlikDeposu(aliciBagli: aliciBagli),
      durum = PanoDurumu() {
    telefonBoyutu(tester);
    addTearDown(depo.dispose);
    addTearDown(durum.dispose);
  }

  final EtkinlikDeposu depo;
  final PanoDurumu durum;
  final List<String> acilanlar = [];
  int kurulumaGidis = 0;

  Widget get widget => temali(
    ListenableBuilder(
      listenable: Listenable.merge([depo, durum]),
      builder: (context, _) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PanoUst(depo: depo, durum: durum, onKurulumaGit: () => kurulumaGidis++),
            KisilerBolumu(depo: depo, durum: durum, onKisi: acilanlar.add),
          ],
        ),
      ),
    ),
  );
}

Color? _satirZemini(WidgetTester tester, String baslik) {
  final kutu = tester.widget<Container>(
    find.ancestor(of: find.text(baslik), matching: find.byType(Container)).first,
  );
  return (kutu.decoration! as BoxDecoration).color;
}

void main() {
  test('PanoDurumu: başlangıç ve seçimler', () {
    final durum = PanoDurumu();
    addTearDown(durum.dispose);
    expect(durum.bolum, PanoBolumu.kisiler);
    expect(durum.filtre, PanoFiltre.girisimci);
    expect(durum.arama, '');
    expect(durum.onem, isNull);
    var bildirim = 0;
    durum.addListener(() => bildirim++);
    durum.bolumSec(PanoBolumu.ag);
    durum.bolumSec(PanoBolumu.ag); // aynı değer bildirim göndermez
    durum.filtreSec(PanoFiltre.tumu);
    durum.aramaDenetleyici.text = 'nova';
    expect(durum.bolum, PanoBolumu.ag);
    expect(durum.filtre, PanoFiltre.tumu);
    expect(durum.arama, 'nova');
    expect(bildirim, 3);
  });

  testWidgets('üst alan: etkinlik adı, tarih, saat, etiketler, bölüm anahtarı', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('Yatırımcı Buluşması'), findsOneWidget);
    expect(find.text('28.09.2026 · Demo Salonu'), findsOneWidget);
    expect(find.text('15:10:09'), findsOneWidget);
    expect(find.text('● Alıcı bağlı'), findsOneWidget);
    expect(find.text('Eşik −72 dBm'), findsOneWidget);
    expect(find.text('Sıfırla'), findsOneWidget);
    expect(find.text('Kişiler'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('Ağ'), findsOneWidget);
    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('alıcı kopukken etiket "Alıcı yok" olur', (tester) async {
    final k = _Kurulum(tester, aliciBagli: false);
    await tester.pumpWidget(k.widget);
    expect(find.text('● Alıcı yok'), findsOneWidget);
    expect(find.text('● Alıcı bağlı'), findsNothing);
  });

  testWidgets('saat ve birlikte süreleri saniyede bir akar', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('Elif Aydın ile · 19 sn'), findsOneWidget);
    k.depo.ilerlet();
    await tester.pump();
    expect(find.text('15:10:10'), findsOneWidget);
    expect(find.text('Elif Aydın ile · 20 sn'), findsOneWidget);
  });

  testWidgets('varsayılan filtre Girişimci: başlık, sayı ve 12 satır', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(12));
    expect(find.text('Nova Robotik · Cem Erdem'), findsOneWidget);
    expect(find.text('Veri Köprüsü · Can Yıldız'), findsOneWidget);
    expect(find.text('Boşta'), findsNWidgets(3)); // filtre çipi + iki satır
    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('birlikte olan satırın zemini yeşil, diğerleri yüzey rengi', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(_satirZemini(tester, 'Nova Robotik · Cem Erdem'), Renkler.birlikteZemin);
    expect(_satirZemini(tester, 'Veri Köprüsü · Can Yıldız'), Renkler.yuzey);
  });

  testWidgets('filtre çipi listeyi süzer', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Yatırımcı'));
    await tester.pump();
    expect(find.text('YATIRIMCILAR'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(10));
    expect(find.text('Ayşe Demir · ★★★★'), findsOneWidget);
    expect(find.text('Görünmüyor · 3 dk önce duyuldu'), findsOneWidget);
  });

  testWidgets('yatay kaydırmayla ulaşılan çip: Hiç görüşmemiş', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.ensureVisible(find.text('Hiç görüşmemiş'));
    await tester.pump();
    await tester.tap(find.text('Hiç görüşmemiş'));
    await tester.pump();
    expect(find.text('HİÇ GÖRÜŞMEMİŞ'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(5));
    expect(find.text('Kart 14'), findsOneWidget);
  });

  testWidgets('arama: Türkçe büyük-küçük harf duyarsız', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'NOVA');
    await tester.pump();
    expect(find.byType(BasiliOpaklik), findsOneWidget);
    expect(find.text('Nova Robotik · Cem Erdem'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('sonuç yoksa liste boş ve sayı 0', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'yok böyle biri');
    await tester.pump();
    expect(find.byType(BasiliOpaklik), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('satıra dokununca kişi bildirilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Nova Robotik · Cem Erdem'));
    expect(k.acilanlar, ['24']);
  });

  testWidgets("eşik etiketi Kurulum'a götürür", (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Eşik −72 dBm'));
    expect(k.kurulumaGidis, 1);
  });

  testWidgets('Sıfırla: vazgeçince değişmez, onaylayınca süre sayacı sıfırlanır', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    k.depo.ilerlet();
    k.depo.ilerlet();
    await tester.pump();

    await tester.tap(find.text('Sıfırla'));
    await tester.pumpAndSettle();
    expect(find.text('Tüm süreler, geçmiş ve bildirimler sıfırlanacak. Emin misiniz?'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(find.byType(SifirlaDiyalogu), findsNothing);
    expect(k.depo.tick, 2);

    await tester.tap(find.text('Sıfırla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sıfırla').last); // diyalogdaki onay düğmesi
    await tester.pumpAndSettle();
    expect(find.byType(SifirlaDiyalogu), findsNothing);
    expect(k.depo.tick, 0);
    expect(k.depo.saat, '15:10:11');
    expect(find.text('Elif Aydın ile · 19 sn'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/ekranlar/pano_kisiler_test.dart
```

Beklenen: derleme hatası — `lib/ekranlar/pano/…` dosyaları için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/pano/pano_durumu.dart
import 'package:flutter/widgets.dart';

import '../../mantik/pano_filtre.dart';
import '../../veri/modeller.dart';

enum PanoBolumu { kisiler, ag, bildirimler }

/// Pano ekranının durumu: seçili bölüm, kişi filtresi, arama, bildirim önemi.
/// Sekme değişse de korunur (Kabuk bu nesneyi tutar).
class PanoDurumu extends ChangeNotifier {
  PanoDurumu() {
    aramaDenetleyici.addListener(notifyListeners);
  }

  /// Arama metni burada tutulur: bölüm değişip geri gelince kaybolmaz.
  final TextEditingController aramaDenetleyici = TextEditingController();

  PanoBolumu _bolum = PanoBolumu.kisiler;
  PanoFiltre _filtre = PanoFiltre.girisimci;
  Onem? _onem;

  PanoBolumu get bolum => _bolum;
  PanoFiltre get filtre => _filtre;
  String get arama => aramaDenetleyici.text;

  /// Seçili bildirim önemi; `null` = Tümü.
  Onem? get onem => _onem;

  void bolumSec(PanoBolumu bolum) {
    if (_bolum == bolum) return;
    _bolum = bolum;
    notifyListeners();
  }

  void filtreSec(PanoFiltre filtre) {
    if (_filtre == filtre) return;
    _filtre = filtre;
    notifyListeners();
  }

  void onemSec(Onem? onem) {
    if (_onem == onem) return;
    _onem = onem;
    notifyListeners();
  }

  @override
  void dispose() {
    aramaDenetleyici.dispose();
    super.dispose();
  }
}
```

```dart title=lib/ekranlar/pano/pano_ust.dart
import 'package:flutter/material.dart';

import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/etiket.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../mantik/bicim.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import 'pano_durumu.dart';

/// Pano'nun üst alanı: etkinlik adı, canlı saat, durum etiketleri, bölüm anahtarı.
class PanoUst extends StatelessWidget {
  const PanoUst({super.key, required this.depo, required this.durum, required this.onKurulumaGit});

  final EtkinlikDeposu depo;
  final PanoDurumu durum;
  final VoidCallback onKurulumaGit;

  Future<void> _sifirla(BuildContext context) async {
    final onay = await showDialog<bool>(
      context: context,
      barrierColor: Renkler.perde,
      builder: (_) => const SifirlaDiyalogu(),
    );
    if (onay == true) depo.sifirla();
  }

  @override
  Widget build(BuildContext context) {
    final alici = depo.aliciBagli ? 'Alıcı bağlı' : 'Alıcı yok';
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(depo.etkinlikAdi, style: Yazi.baslik(22, 1.15)),
                    ),
                    const SizedBox(height: 4),
                    Text(depo.tarihMekan, style: Yazi.olcu(13, renk: Renkler.metin2)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  depo.saat,
                  style: Yazi.olcu(24, agirlik: FontWeight.w600, satir: 1, rakam: true),
                ),
              ),
            ],
          ),
          // Etiketlerin görseli 28 px, dokunma alanı 44 px: üstteki 12 px ve
          // alttaki 14 px boşluğun 8'er pikseli dokunma alanının içindedir.
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                height: Olculer.dokunmaEnAz,
                child: Center(widthFactor: 1, child: Etiket('● $alici')),
              ),
              Etiket('Eşik ${dbmYazisi(depo.esik)} dBm', tur: EtiketTuru.notr, onTap: onKurulumaGit),
              HapDugme(
                etiket: 'Sıfırla',
                tur: HapTuru.hayalet,
                yukseklik: 28,
                punto: 13,
                yatayBosluk: 6,
                onTap: () => _sifirla(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BolmeliAnahtar<PanoBolumu>(
            yukseklik: 40,
            secenekler: [
              BolmeSecenegi(deger: PanoBolumu.kisiler, etiket: 'Kişiler', ek: '${depo.kisiler.length}'),
              const BolmeSecenegi(deger: PanoBolumu.ag, etiket: 'Ağ'),
              BolmeSecenegi(
                deger: PanoBolumu.bildirimler,
                etiket: 'Bildirimler',
                ek: '${depo.bildirimler.length}',
              ),
            ],
            secili: durum.bolum,
            onSecildi: durum.bolumSec,
          ),
        ],
      ),
    );
  }
}

/// Sıfırla onayı. `true` (Sıfırla) ya da `false` (Vazgeç) ile kapanır.
class SifirlaDiyalogu extends StatelessWidget {
  const SifirlaDiyalogu({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Renkler.yuzey,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(Olculer.sayfaKenari),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Olculer.koseAltSayfa)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tüm süreler, geçmiş ve bildirimler sıfırlanacak. Emin misiniz?',
              style: Yazi.olcu(15),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                HapDugme(etiket: 'Vazgeç', onTap: () => Navigator.of(context).pop(false)),
                const SizedBox(width: 10),
                HapDugme(
                  etiket: 'Sıfırla',
                  tur: HapTuru.birincil,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/pano/kisiler_bolumu.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/basili_opaklik.dart';
import '../../bilesenler/cip.dart';
import '../../bilesenler/kicker.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../mantik/pano_filtre.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'pano_durumu.dart';

/// Pano → Kişiler: arama, filtre çipleri, başlık ve kişi satırları.
class KisilerBolumu extends StatelessWidget {
  const KisilerBolumu({super.key, required this.depo, required this.durum, required this.onKisi});

  final EtkinlikDeposu depo;
  final PanoDurumu durum;

  /// Satıra dokununca kişinin kart numarasıyla çağrılır.
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    final liste = filtreleKisiler(depo.kisiler, filtre: durum.filtre, arama: durum.arama);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 14, Olculer.sayfaKenari, 0),
          child: AramaAlani(ipucu: 'Ara: ad, kurum, kart no', denetleyici: durum.aramaDenetleyici),
        ),
        // Çip görseli 36 px, dokunma alanı 44 px: üstteki 12 px ve alttaki 20 px
        // boşluğun 4'er pikseli dokunma alanının içindedir.
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Olculer.sayfaKenari),
          child: Row(
            children: [
              for (final f in PanoFiltre.values) ...[
                if (f != PanoFiltre.values.first) const SizedBox(width: 8),
                Cip(etiket: f.etiket, secili: f == durum.filtre, onTap: () => durum.filtreSec(f)),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
          child: Kicker(listeBasligi(durum.filtre), sayi: '${liste.length}'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < liste.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _KisiSatiri(kisi: liste[i], depo: depo, onTap: () => onKisi(liste[i].id)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _KisiSatiri extends StatelessWidget {
  const _KisiSatiri({required this.kisi, required this.depo, required this.onTap});

  final Kisi kisi;
  final EtkinlikDeposu depo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alt = altAd(kisi);
    return BasiliOpaklik(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Yeşil zemin yalnız "şu an birlikte" demektir.
          color: kisi.ile != null ? Renkler.birlikteZemin : Renkler.yuzey,
          borderRadius: Olculer.koseYaricap,
        ),
        child: Row(
          children: [
            RolSekli(rol: kisi.rol, renk: kisi.renk),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: baslik(kisi),
                      children: [
                        if (alt.isNotEmpty)
                          TextSpan(
                            text: ' $alt',
                            style: const TextStyle(fontWeight: FontWeight.w400, color: Renkler.metin2),
                          ),
                      ],
                    ),
                    style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    durumCumlesi(kisi, depo.tick, depo.bul),
                    style: Yazi.olcu(13, renk: Renkler.ton(durumTonu(kisi))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(sureMetni(kisi, depo.tick), style: Yazi.olcu(15, renk: Renkler.metinKoyu2, rakam: true)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (94 + 13 = 107 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 8: Pano — durum, üst alan (saat, etiketler, sıfırla), Kişiler bölümü

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: Pano — Ağ, Bildirimler ve Pano ekranı

**Files:**
- Create: `lib/ekranlar/pano/ag_bolumu.dart`, `lib/ekranlar/pano/bildirimler_bolumu.dart`, `lib/ekranlar/pano/pano_ekrani.dart`
- Test: `test/ekranlar/pano_ekrani_test.dart`

**Interfaces:**
- Consumes: `PanoDurumu`, `PanoBolumu`, `PanoUst`, `KisilerBolumu` (Task 8); `agYerlesimi`, `AgDugumu`, `AgKenari`, `agSatirAraligi`, `bildirimleriSuz`, `onemSayisi`, `onemEtiketi`, `onemSirasi` (Task 3); `rolAdi` (Task 2); `kesikCizgi`, `Cip`, `Kicker` (Task 7).
- Produces:
  - `AgBolumu({required EtkinlikDeposu depo, required ValueChanged<String> onKisi})`
  - `BildirimlerBolumu({required EtkinlikDeposu depo, required PanoDurumu durum, required ValueChanged<String> onKisi})`
  - `PanoEkrani({required EtkinlikDeposu depo, required PanoDurumu durum, required ValueChanged<String> onKisi, required VoidCallback onKurulumaGit})`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/ekranlar/pano_ekrani_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/ekranlar/pano/ag_bolumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_durumu.dart';
import 'package:yakinlik_mobil/ekranlar/pano/pano_ekrani.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';
import 'package:yakinlik_mobil/veri/modeller.dart';

import '../yardimci.dart';

class _Kurulum {
  _Kurulum(WidgetTester tester, {List<Bildirim>? bildirimler})
    : depo = EtkinlikDeposu(bildirimler: bildirimler),
      durum = PanoDurumu() {
    telefonBoyutu(tester);
    addTearDown(depo.dispose);
    addTearDown(durum.dispose);
  }

  final EtkinlikDeposu depo;
  final PanoDurumu durum;
  final List<String> acilanlar = [];

  Widget get widget =>
      temali(PanoEkrani(depo: depo, durum: durum, onKisi: acilanlar.add, onKurulumaGit: () {}));
}

void main() {
  testWidgets('açılışta Kişiler bölümü görünür', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(12));
  });

  testWidgets('Ağ: başlıklar, düğümler ve not', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Ağ'));
    await tester.pump();
    expect(find.text('YATIRIMCI ○'), findsOneWidget);
    expect(find.text('GİRİŞİMCİ □'), findsOneWidget);
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text('Kerem Tekin'), findsOneWidget); // birlikte olan misafir solda
    expect(find.text('Volkan Aydın'), findsNothing); // boştaki misafir ağda yok
    expect(find.text('Nova Robotik'), findsOneWidget);
    expect(find.text('Oyun Evreni'), findsOneWidget);
    expect(
      find.text(
        'Düğümlerin konumu fiziksel konum değildir; yalnız rol gruplarını gösterir. '
        'Bir ada dokununca ayrıntı açılır.',
      ),
      findsOneWidget,
    );
    expect(find.text('GİRİŞİMCİLER'), findsNothing);
  });

  testWidgets('Ağ: birlikte olan çiftler arasında çizgi çizilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Ağ'));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(AgBolumu), matching: find.byType(CustomPaint)),
      paints..line(),
    );
  });

  testWidgets('Ağ: ada dokununca kişi bildirilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Ağ'));
    await tester.pump();
    await tester.tap(find.text('Ayşe Demir'));
    await tester.tap(find.text('Nova Robotik'));
    expect(k.acilanlar, ['61', '24']);
  });

  testWidgets('Bildirimler: dört satır ve sayılı önem çipleri', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    expect(find.text('Tümü 4'), findsOneWidget);
    expect(find.text('Ciddi 1'), findsOneWidget);
    expect(find.text('Uyarı 2'), findsOneWidget);
    expect(find.text('Olumlu 1'), findsOneWidget);
    expect(find.text('Pil düşük'), findsOneWidget);
    expect(find.text('Yeni görüşme'), findsOneWidget);
    expect(find.text('Yalnız kaldı'), findsOneWidget);
    expect(find.text('Kart kayboldu'), findsOneWidget);
    expect(find.text('Kart 46 · Mehmet Kılıç · %16 — kartı masada değiştirin'), findsOneWidget);
    expect(find.text('15:02'), findsOneWidget);
  });

  testWidgets('Bildirimler: önem çipi süzer; satıra dokununca ilk kişi bildirilir', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    await tester.tap(find.text('Ciddi 1'));
    await tester.pump();
    expect(find.text('Kart kayboldu'), findsOneWidget);
    expect(find.text('Pil düşük'), findsNothing);
    await tester.tap(find.text('Kart kayboldu'));
    expect(k.acilanlar, ['40']);

    await tester.tap(find.text('Olumlu 1'));
    await tester.pump();
    await tester.tap(find.text('Yeni görüşme'));
    expect(k.acilanlar, ['40', '24']);
  });

  testWidgets('Bildirimler: boşsa "Bu önemde bildirim yok."', (tester) async {
    final k = _Kurulum(tester, bildirimler: const []);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    expect(find.text('Tümü 0'), findsOneWidget);
    expect(find.text('Bu önemde bildirim yok.'), findsOneWidget);
  });

  testWidgets('arama metni ve filtre, bölüm değişip geri gelince korunur', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'nova');
    await tester.pump();
    expect(find.byType(BasiliOpaklik), findsOneWidget);

    await tester.tap(find.text('Ağ'));
    await tester.pump();
    await tester.tap(find.text('Kişiler'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'nova');
    expect(find.byType(BasiliOpaklik), findsOneWidget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/ekranlar/pano_ekrani_test.dart
```

Beklenen: derleme hatası — `ag_bolumu.dart`, `pano_ekrani.dart` için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/pano/ag_bolumu.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/kesik_cizgi.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/ag.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// Pano → Ağ: solda yatırımcı/misafir, sağda girişimci; şu an birlikte olan
/// çiftler arasında yeşil kesik çizgi. Düğüm konumu fiziksel konum değildir.
class AgBolumu extends StatelessWidget {
  const AgBolumu({super.key, required this.depo, required this.onKisi});

  final EtkinlikDeposu depo;
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Kicker('Yatırımcı ○')),
              SizedBox(width: 8),
              Flexible(child: Kicker('Girişimci □')),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, kisit) {
              final genislik = kisit.maxWidth;
              final yerlesim = agYerlesimi(depo.kisiler, genislik);
              // Uzun adlar karşı sütuna taşmasın.
              final sutun = BoxConstraints(maxWidth: genislik / 2 - 8);
              return SizedBox(
                height: yerlesim.yukseklik,
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _KenarCizici(yerlesim.kenarlar))),
                    Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: sutun,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final d in yerlesim.sol)
                              _Dugum(dugum: d, solda: true, onTap: () => onKisi(d.kisi.id)),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: ConstrainedBox(
                        constraints: sutun,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final d in yerlesim.sag)
                              _Dugum(dugum: d, solda: false, onTap: () => onKisi(d.kisi.id)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Düğümlerin konumu fiziksel konum değildir; yalnız rol gruplarını gösterir. '
            'Bir ada dokununca ayrıntı açılır.',
            style: Yazi.olcu(13, renk: Renkler.metin2, stil: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Bir düğüm satırı: solda daire + ad, sağda ad + kare (1 px köşe).
class _Dugum extends StatelessWidget {
  const _Dugum({required this.dugum, required this.solda, required this.onTap});

  final AgDugumu dugum;
  final bool solda;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sekil = Semantics(
      label: rolAdi(dugum.kisi.rol),
      child: SizedBox.square(
        dimension: 14,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Renkler.kisi(dugum.kisi.renk),
            shape: solda ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: solda ? null : const BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ),
    );
    final ad = Flexible(
      child: Text(dugum.ad, maxLines: 1, overflow: TextOverflow.ellipsis, style: Yazi.olcu(13)),
    );
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: agSatirAraligi,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: solda
                ? [sekil, const SizedBox(width: 8), ad]
                : [ad, const SizedBox(width: 8), sekil],
          ),
        ),
      ),
    );
  }
}

class _KenarCizici extends CustomPainter {
  _KenarCizici(this.kenarlar);

  final List<AgKenari> kenarlar;

  @override
  void paint(Canvas canvas, Size size) {
    final boya = Paint()
      ..color = Renkler.birlikte
      ..strokeWidth = 1.2;
    for (final k in kenarlar) {
      kesikCizgi(canvas, Offset(k.x1, k.y1), Offset(k.x2, k.y2), boya, dolu: 4, bos: 4);
    }
  }

  @override
  bool shouldRepaint(_KenarCizici oldDelegate) => oldDelegate.kenarlar != kenarlar;
}
```

```dart title=lib/ekranlar/pano/bildirimler_bolumu.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/cip.dart';
import '../../mantik/pano_filtre.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'pano_durumu.dart';

/// Pano → Bildirimler: önem çipleri ve bildirim satırları.
class BildirimlerBolumu extends StatelessWidget {
  const BildirimlerBolumu({super.key, required this.depo, required this.durum, required this.onKisi});

  final EtkinlikDeposu depo;
  final PanoDurumu durum;

  /// Satıra dokununca bildirimin ilk kişisinin kart numarasıyla çağrılır.
  final ValueChanged<String> onKisi;

  @override
  Widget build(BuildContext context) {
    final liste = bildirimleriSuz(depo.bildirimler, durum.onem);
    return Padding(
      // Çip görseli 36 px, dokunma alanı 44 px: üstteki 16 px ve alttaki 14 px
      // boşluğun 4'er pikseli dokunma alanının içindedir.
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 12, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final o in onemSirasi)
                Cip(
                  etiket: onemEtiketi(o),
                  sayi: '${onemSayisi(depo.bildirimler, o)}',
                  secili: o == durum.onem,
                  seciliRenk: Renkler.metin,
                  yatayBosluk: 12,
                  onTap: () => durum.onemSec(o),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < liste.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _BildirimSatiri(
              bildirim: liste[i],
              onTap: liste[i].kisiler.isEmpty ? null : () => onKisi(liste[i].kisiler.first),
            ),
          ],
          if (liste.isEmpty)
            Text(
              'Bu önemde bildirim yok.',
              style: Yazi.olcu(15, renk: Renkler.metin2, stil: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

class _BildirimSatiri extends StatelessWidget {
  const _BildirimSatiri({required this.bildirim, required this.onTap});

  final Bildirim bildirim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Olculer.dokunmaEnAz),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: SizedBox.square(
                    dimension: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Renkler.onem(bildirim.onem), shape: BoxShape.circle),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(bildirim.baslik, style: Yazi.olcu(15, agirlik: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text(bildirim.saat, style: Yazi.olcu(13, renk: Renkler.metin2, rakam: true)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(bildirim.detay, style: Yazi.olcu(14, renk: Renkler.metinKoyu2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/pano/pano_ekrani.dart
import 'package:flutter/widgets.dart';

import '../../veri/etkinlik_deposu.dart';
import 'ag_bolumu.dart';
import 'bildirimler_bolumu.dart';
import 'kisiler_bolumu.dart';
import 'pano_durumu.dart';
import 'pano_ust.dart';

/// Pano sekmesi: üst alan + seçili bölüm (Kişiler · Ağ · Bildirimler).
class PanoEkrani extends StatelessWidget {
  const PanoEkrani({
    super.key,
    required this.depo,
    required this.durum,
    required this.onKisi,
    required this.onKurulumaGit,
  });

  final EtkinlikDeposu depo;
  final PanoDurumu durum;

  /// Bir kişiye dokununca kart numarasıyla çağrılır (Kişi Detayı açılır).
  final ValueChanged<String> onKisi;
  final VoidCallback onKurulumaGit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([depo, durum]),
      builder: (context, _) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanoUst(depo: depo, durum: durum, onKurulumaGit: onKurulumaGit),
              switch (durum.bolum) {
                PanoBolumu.kisiler => KisilerBolumu(depo: depo, durum: durum, onKisi: onKisi),
                PanoBolumu.ag => AgBolumu(depo: depo, onKisi: onKisi),
                PanoBolumu.bildirimler => BildirimlerBolumu(depo: depo, durum: durum, onKisi: onKisi),
              },
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (107 + 8 = 115 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 9: Pano — Ağ ve Bildirimler bölümleri, Pano ekranı

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 10: Kişi Detayı (alt sayfa)

**Files:**
- Create: `lib/ekranlar/kisi_detayi/kisi_detay_sayfasi.dart`
- Test: `test/ekranlar/kisi_detayi_test.dart`

**Interfaces:**
- Consumes: `EtkinlikDeposu` (Task 5); `tamAd`, `rolSatiri`, `gorunenAd`, `durumCumlesi`, `durumTonu`, `sonDuyulma`, `gecenSn`, `cizelgeOrani`, `sureYazisi` (Task 2); `RolSekli`, `HapDugme`, `EtiketliDeger`, `Kicker` (Task 7).
- Produces:
  - `enum DetayEylemi { kartDegistir, kartIade }`
  - `Future<DetayEylemi?> kisiDetayiGoster(BuildContext context, {required EtkinlikDeposu depo, required String kisiId})` — alt sayfayı açar; kısayola basılırsa eylemle, aksi halde `null` ile tamamlanır
  - `KisiDetaySayfasi({required EtkinlikDeposu depo, required String kisiId})`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/ekranlar/kisi_detayi_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/hap_dugme.dart';
import 'package:yakinlik_mobil/ekranlar/kisi_detayi/kisi_detay_sayfasi.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

class _Sonuc {
  bool kapandi = false;
  DetayEylemi? eylem;
}

/// Bir düğmeyle alt sayfayı açar; kapanınca sonucu kaydeder.
Future<_Sonuc> _ac(WidgetTester tester, EtkinlikDeposu depo, String kisiId) async {
  telefonBoyutu(tester);
  addTearDown(depo.dispose);
  final sonuc = _Sonuc();
  await tester.pumpWidget(
    temali(
      Builder(
        builder: (context) => Center(
          child: HapDugme(
            etiket: 'aç',
            onTap: () async {
              sonuc.eylem = await kisiDetayiGoster(context, depo: depo, kisiId: kisiId);
              sonuc.kapandi = true;
            },
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('aç'));
  await tester.pumpAndSettle();
  return sonuc;
}

double _cizelgeOrani(WidgetTester tester) =>
    tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor!;

void main() {
  testWidgets('girişimci: başlık, rol, alanlar, eş ve çizelge', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '24');
    expect(find.text('Nova Robotik · Cem Erdem'), findsOneWidget);
    expect(find.text('Girişimci'), findsOneWidget);
    expect(find.text('Kart no'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Durum'), findsOneWidget);
    expect(find.text('Elif Aydın ile · 19 sn'), findsOneWidget);
    expect(find.text('Son duyulma'), findsOneWidget);
    expect(find.text('az önce'), findsOneWidget);
    expect(find.text('Bugünkü toplam'), findsOneWidget);
    expect(find.text('19 sn'), findsNWidgets(2)); // toplam + eş satırı
    expect(find.text('Pil'), findsOneWidget);
    expect(find.text('%92'), findsOneWidget);
    expect(find.text('Kartı değiştir'), findsOneWidget);
    expect(find.text('Kartı iade al'), findsOneWidget);
    expect(find.text('BUGÜN KİMİNLE'), findsOneWidget);
    expect(find.text('Elif Aydın'), findsOneWidget);
    expect(find.text('GÖRÜŞME ZAMAN ÇİZELGESİ'), findsOneWidget);
    expect(find.text('15:10'), findsOneWidget);
    expect(find.text('şimdi · 15:10'), findsOneWidget);
    expect(_cizelgeOrani(tester), closeTo(0.2633, 0.001));
  });

  testWidgets('içerik saniyede bir güncellenir', (tester) async {
    final depo = EtkinlikDeposu();
    await _ac(tester, depo, '24');
    depo.ilerlet();
    await tester.pump();
    expect(find.text('Elif Aydın ile · 20 sn'), findsOneWidget);
    expect(find.text('20 sn'), findsNWidgets(2));
  });

  testWidgets('durum rengi: birlikte yeşil', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '24');
    expect(tester.widget<Text>(find.text('Elif Aydın ile · 19 sn')).style!.color, Renkler.birlikte);
  });

  testWidgets('Kartı değiştir: kartDegistir sonucuyla kapanır', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tap(find.text('Kartı değiştir'));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(sonuc.kapandi, isTrue);
    expect(sonuc.eylem, DetayEylemi.kartDegistir);
  });

  testWidgets('Kartı iade al: kartIade sonucuyla kapanır', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tap(find.text('Kartı iade al'));
    await tester.pumpAndSettle();
    expect(sonuc.eylem, DetayEylemi.kartIade);
  });

  testWidgets('✕ kapatır; sonuç boş', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tap(find.text('✕'));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(sonuc.kapandi, isTrue);
    expect(sonuc.eylem, isNull);
  });

  testWidgets('perdeye dokununca kapanır', (tester) async {
    final sonuc = await _ac(tester, EtkinlikDeposu(), '24');
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(sonuc.eylem, isNull);
  });

  testWidgets('yatırımcı: yıldızlı rol satırı', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '61');
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text('Yatırımcı · ★★★★'), findsOneWidget);
    expect(find.text('Sağlık Cebi · Ece Arslan'), findsNothing);
    expect(find.text('Ece Arslan'), findsOneWidget); // eş satırı
  });

  testWidgets('hiç görüşmemiş kişi: boş durum, çizelge boş', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '49');
    expect(find.text('Boşta'), findsOneWidget);
    expect(find.text('Henüz kimseyle görüşmedi.'), findsOneWidget);
    expect(find.text('0 sn'), findsOneWidget);
    expect(_cizelgeOrani(tester), 0);
  });

  testWidgets('görünmüyor: uyarı renginde durum ve "3 dk önce"', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '40');
    final durum = tester.widget<Text>(find.text('Görünmüyor · 3 dk önce duyuldu'));
    expect(durum.style!.color, Renkler.uyari);
    expect(find.text('3 dk önce'), findsOneWidget);
  });

  testWidgets('adsız kart: başlık "Kart 14"', (tester) async {
    await _ac(tester, EtkinlikDeposu(), '14');
    expect(find.text('Kart 14'), findsOneWidget);
    expect(find.text('Misafir'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("yükseklik en çok ekranın %78'i", (tester) async {
    await _ac(tester, EtkinlikDeposu(), '24');
    expect(tester.getSize(find.byType(KisiDetaySayfasi)).height, lessThanOrEqualTo(874 * 0.78 + 0.01));
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/ekranlar/kisi_detayi_test.dart
```

Beklenen: derleme hatası — `kisi_detay_sayfasi.dart` için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/kisi_detayi/kisi_detay_sayfasi.dart
import 'package:flutter/material.dart';

import '../../bilesenler/etiketli_deger.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

/// Kişi Detayı'ndaki kısayollar.
enum DetayEylemi { kartDegistir, kartIade }

/// Kişi Detayı'nı alt sayfa olarak açar. Kısayola basılırsa eylemle, aksi halde
/// (✕, perde, aşağı çekme) `null` ile tamamlanır.
Future<DetayEylemi?> kisiDetayiGoster(
  BuildContext context, {
  required EtkinlikDeposu depo,
  required String kisiId,
}) {
  return showModalBottomSheet<DetayEylemi>(
    context: context,
    isScrollControlled: true,
    // Köşe, zemin ve gölgeyi sayfa kendisi çizer.
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Renkler.perde,
    builder: (_) => KisiDetaySayfasi(depo: depo, kisiId: kisiId),
  );
}

class KisiDetaySayfasi extends StatelessWidget {
  const KisiDetaySayfasi({super.key, required this.depo, required this.kisiId});

  final EtkinlikDeposu depo;
  final String kisiId;

  /// Sayfa ekranın en çok bu kadarını kaplar.
  static const double _enCokOran = 0.78;

  @override
  Widget build(BuildContext context) {
    final enCok = MediaQuery.sizeOf(context).height * _enCokOran;
    final altGuvenli = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: depo,
      builder: (context, _) {
        final k = depo.bul(kisiId);
        final ile = k.ile;
        final es = ile == null ? null : depo.bul(ile);
        final toplam = sureYazisi(gecenSn(k, depo.tick));
        return Container(
          constraints: BoxConstraints(maxHeight: enCok),
          decoration: const BoxDecoration(
            color: Renkler.zemin,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Olculer.koseAltSayfa)),
            boxShadow: Olculer.altSayfaGolgesi,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tutamaç kaydırma alanının dışındadır: aşağı çekince sayfa kapanır.
              const Padding(
                padding: EdgeInsets.only(top: 14, bottom: 18),
                child: Center(child: _Tutamac()),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(Olculer.sayfaKenari, 0, Olculer.sayfaKenari, 10 + altGuvenli),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _baslik(context, k),
                      const SizedBox(height: 18),
                      _alanlar(k, toplam),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: HapDugme(
                              etiket: 'Kartı değiştir',
                              tur: HapTuru.birincil,
                              yukseklik: 48,
                              genis: true,
                              onTap: () => Navigator.of(context).pop(DetayEylemi.kartDegistir),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: HapDugme(
                              etiket: 'Kartı iade al',
                              yukseklik: 48,
                              genis: true,
                              onTap: () => Navigator.of(context).pop(DetayEylemi.kartIade),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Kicker('Bugün kiminle'),
                      if (es == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Henüz kimseyle görüşmedi.',
                            style: Yazi.olcu(15, renk: Renkler.metin2, stil: FontStyle.italic),
                          ),
                        )
                      else
                        _EsSatiri(es: es, sure: toplam),
                      const SizedBox(height: 18),
                      const Kicker('Görüşme zaman çizelgesi'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(depo.cizelgeBaslangici, style: Yazi.olcu(12, renk: Renkler.metin2)),
                          Text('şimdi · ${depo.saatKisa}', style: Yazi.olcu(12, renk: Renkler.metin2)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _Cizelge(oran: cizelgeOrani(k, depo.tick)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _baslik(BuildContext context, Kisi k) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: RolSekli(rol: k.rol, renk: k.renk, boyut: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(tamAd(k), style: Yazi.baslik(22, 1.15)),
              ),
              const SizedBox(height: 2),
              Text(rolSatiri(k), style: Yazi.olcu(14, renk: Renkler.metin2)),
            ],
          ),
        ),
        // Görsel 40 px, dokunma alanı 44 px: 12 px boşluğun 2'si dokunma alanında.
        const SizedBox(width: 10),
        HapDugme(
          etiket: '✕',
          anlam: 'Kapat',
          genislik: 40,
          yukseklik: 40,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _alanlar(Kisi k, String toplam) {
    Widget satir(Widget sol, Widget sag) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: sol),
        const SizedBox(width: 12),
        Expanded(child: sag),
      ],
    );
    return Column(
      children: [
        satir(
          EtiketliDeger(
            etiket: 'Kart no',
            deger: k.id,
            stil: Yazi.olcu(20, agirlik: FontWeight.w600, satir: 1.2, rakam: true),
          ),
          EtiketliDeger(
            etiket: 'Durum',
            deger: durumCumlesi(k, depo.tick, depo.bul),
            stil: Yazi.olcu(15, agirlik: FontWeight.w600, renk: Renkler.ton(durumTonu(k))),
          ),
        ),
        const SizedBox(height: 14),
        satir(
          EtiketliDeger(etiket: 'Son duyulma', deger: sonDuyulma(k)),
          EtiketliDeger(
            etiket: 'Bugünkü toplam',
            deger: toplam,
            stil: Yazi.olcu(15, agirlik: FontWeight.w600, rakam: true),
          ),
        ),
        const SizedBox(height: 14),
        satir(EtiketliDeger(etiket: 'Pil', deger: '%${k.pil}'), const SizedBox.shrink()),
      ],
    );
  }
}

class _Tutamac extends StatelessWidget {
  const _Tutamac();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 36,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Renkler.kenarlik, borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
    );
  }
}

/// "Bugün kiminle" satırı: şekil, ad, süre.
class _EsSatiri extends StatelessWidget {
  const _EsSatiri({required this.es, required this.sure});

  final Kisi es;
  final String sure;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Renkler.ayrac)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            RolSekli(rol: es.rol, renk: es.renk, boyut: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Text(gorunenAd(es), style: Yazi.olcu(15, agirlik: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Text(sure, style: Yazi.olcu(15, rakam: true)),
          ],
        ),
      ),
    );
  }
}

/// Zaman çizelgesi: 8 px ray; yeşil dolgu birlikte geçen süreyi gösterir.
class _Cizelge extends StatelessWidget {
  const _Cizelge({required this.oran});

  final double oran;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(2)),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: Renkler.acikYuzey,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: oran,
              heightFactor: 1,
              child: const ColoredBox(color: Renkler.birlikte),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (115 + 12 = 127 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 10: Kişi Detayı — alt sayfa, canlı alanlar, kısayollar, zaman çizelgesi

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---
### Task 11: Kart Ver — durum

**Files:**
- Create: `lib/ekranlar/kart_ver/kart_ver_durumu.dart`
- Test: `test/ekranlar/kart_ver_durumu_test.dart`

**Interfaces:**
- Consumes: `EtkinlikDeposu.bul` (Task 5); `numaraGecerli`, `numaraTemizle`, `yalnizRakam` (Task 3); `gorunenAd` (Task 2).
- Produces:
  - `enum KartVerModu { ver, iade }`, `enum KartSecimModu { yaklastir, numara }`, `typedef SonAtama = ({String ad, String kart})`
  - `class KartVerDurumu extends ChangeNotifier`
    - `KartVerDurumu(EtkinlikDeposu depo, {Duration demoGecikmesi = 1400 ms, String demoKarti = '88'})`
    - `TextEditingController aramaDenetleyici`, `TextEditingController numaraDenetleyici`
    - Okunanlar: `KartVerModu mod`, `int adim`, `Kisi? kisi`, `String? seciliKart`, `KartSecimModu kartModu`, `String? bulundu`, `SonAtama? sonAtama`, `String? bilgi`, `Kisi? iadeKisisi`, `String arama`, `String numara`, `bool numaraSecilebilir`
    - İşlevler: `kisiSec(String id)`, `kartModuSec(KartSecimModu)`, `demoYaklastir()`, `bulunanSec()`, `numaraSec()`, `acikKartSec(String no)`, `kisiAdiminaDon()`, `kartAdiminaDon()`, `onayla()`, `geriAl()`, `modVer()`, `modIade()`, `iadeSec(String id)`, `iadeVazgec()`, `iadeOnayla()`, `kartDegistirBaslat(String id)`, `iadeBaslat(String id)`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/ekranlar/kart_ver_durumu_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_durumu.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

void main() {
  late EtkinlikDeposu depo;
  late KartVerDurumu d;

  setUp(() {
    depo = EtkinlikDeposu();
    d = KartVerDurumu(depo);
  });

  tearDown(() {
    d.dispose();
    depo.dispose();
  });

  test('başlangıç durumu', () {
    expect(d.mod, KartVerModu.ver);
    expect(d.adim, 1);
    expect(d.kisi, isNull);
    expect(d.seciliKart, isNull);
    expect(d.kartModu, KartSecimModu.yaklastir);
    expect(d.bulundu, isNull);
    expect(d.sonAtama, isNull);
    expect(d.bilgi, isNull);
    expect(d.iadeKisisi, isNull);
    expect(d.arama, '');
    expect(d.numara, '');
    expect(d.numaraSecilebilir, isFalse);
  });

  test('kisiSec: adım 2; numara temizlenir', () {
    d.numaraDenetleyici.text = '14';
    d.kisiSec('24');
    expect(d.adim, 2);
    expect(d.kisi!.id, '24');
    expect(d.numara, '');
    expect(d.bulundu, isNull);
  });

  test('kartModuSec', () {
    d.kartModuSec(KartSecimModu.numara);
    expect(d.kartModu, KartSecimModu.numara);
  });

  testWidgets('demoYaklastir: 1,4 sn sonra Kart 88 bulunur; seçince adım 3', (tester) async {
    d.kisiSec('24');
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 1399));
    expect(d.bulundu, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(d.bulundu, '88');
    d.bulunanSec();
    expect(d.adim, 3);
    expect(d.seciliKart, '88');
  });

  testWidgets('demo: art arda basılırsa son basıştan 1,4 sn sonra, tek kez bulunur', (tester) async {
    d.kisiSec('24');
    var bildirim = 0;
    d.addListener(() => bildirim++);
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 1000));
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(d.bulundu, isNull);
    await tester.pump(const Duration(milliseconds: 400));
    expect(d.bulundu, '88');
    expect(bildirim, 1);
  });

  testWidgets('demo beklerken geri dönülürse eski kart sonradan belirmez (S16)', (tester) async {
    d.kisiSec('24');
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 500));
    d.kisiAdiminaDon();
    await tester.pump(const Duration(seconds: 2));
    expect(d.bulundu, isNull);
    d.kisiSec('31');
    await tester.pump(const Duration(seconds: 2));
    expect(d.bulundu, isNull);
    expect(d.adim, 2);
  });

  testWidgets('demo beklerken başka kişiye geçilirse iptal olur (S16)', (tester) async {
    d.kisiSec('24');
    d.demoYaklastir();
    await tester.pump(const Duration(milliseconds: 500));
    d.kartDegistirBaslat('31');
    await tester.pump(const Duration(seconds: 2));
    expect(d.bulundu, isNull);
    expect(d.kisi!.id, '31');
  });

  test('bulunanSec: kart bulunmadıysa etkisiz', () {
    d.kisiSec('24');
    d.bulunanSec();
    expect(d.adim, 2);
    expect(d.seciliKart, isNull);
  });

  test('numara: yalnız rakam; 1–99 geçerli; baştaki sıfır atılır', () {
    d.kisiSec('24');
    d.numaraDenetleyici.text = '0';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraSec(); // geçersizken etkisiz
    expect(d.adim, 2);
    d.numaraDenetleyici.text = '100';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraDenetleyici.text = '12345678901234567890';
    expect(d.numaraSecilebilir, isFalse);
    d.numaraDenetleyici.text = '1a4';
    expect(d.numara, '14');
    expect(d.numaraSecilebilir, isTrue);
    d.numaraDenetleyici.text = '007';
    expect(d.numaraSecilebilir, isTrue);
    d.numaraSec();
    expect(d.adim, 3);
    expect(d.seciliKart, '7');
  });

  test('acikKartSec: adım 3', () {
    d.kisiSec('24');
    d.acikKartSec('89');
    expect(d.adim, 3);
    expect(d.seciliKart, '89');
  });

  test('adımlar arası geri dönüş', () {
    d.kisiSec('24');
    d.acikKartSec('89');
    d.kartAdiminaDon();
    expect(d.adim, 2);
    expect(d.kisi!.id, '24');
    d.kisiAdiminaDon();
    expect(d.adim, 1);
  });

  test('onayla: son atama bandı, adım 1, alanlar temiz', () {
    d.aramaDenetleyici.text = 'nova';
    d.kisiSec('24');
    d.numaraDenetleyici.text = '88';
    d.numaraSec();
    d.onayla();
    expect(d.sonAtama, (ad: 'Cem Erdem', kart: '88'));
    expect(d.adim, 1);
    expect(d.kisi, isNull);
    expect(d.seciliKart, isNull);
    expect(d.bulundu, isNull);
    expect(d.numara, '');
    expect(d.arama, '');
    expect(d.bilgi, isNull);
  });

  test('onayla: kişi ya da kart seçili değilse etkisiz', () {
    d.onayla();
    expect(d.sonAtama, isNull);
    d.kisiSec('24');
    d.onayla();
    expect(d.sonAtama, isNull);
    expect(d.adim, 2);
  });

  test('geriAl: bilgi metni yazılır, bant kalkar; bant yokken etkisiz', () {
    d.kisiSec('24');
    d.acikKartSec('88');
    d.onayla();
    d.geriAl();
    expect(d.sonAtama, isNull);
    expect(d.bilgi, '↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.');
    d.geriAl();
    expect(d.bilgi, '↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.');
  });

  test('yeni onay önceki bilgi metnini siler', () {
    d.kisiSec('24');
    d.acikKartSec('88');
    d.onayla();
    d.geriAl();
    d.kisiSec('31');
    d.acikKartSec('89');
    d.onayla();
    expect(d.bilgi, isNull);
    expect(d.sonAtama, (ad: 'İrem Korkmaz', kart: '89'));
  });

  test('iade: seç, vazgeç, onayla', () {
    d.modIade();
    expect(d.mod, KartVerModu.iade);
    d.iadeSec('24');
    expect(d.iadeKisisi!.id, '24');
    d.iadeVazgec();
    expect(d.iadeKisisi, isNull);
    d.iadeOnayla(); // seçim yokken etkisiz
    expect(d.bilgi, isNull);
    d.iadeSec('24');
    d.iadeOnayla();
    expect(d.iadeKisisi, isNull);
    expect(d.bilgi, '✓ Kart 24 iade alındı. Cem Erdem panodan düştü; süreleri raporda kalır.');
  });

  test('modVer iade seçimini temizler; mod değişimi sihirbazı bozmaz', () {
    d.kisiSec('24');
    d.modIade();
    d.iadeSec('31');
    d.modVer();
    expect(d.mod, KartVerModu.ver);
    expect(d.iadeKisisi, isNull);
    expect(d.adim, 2);
    expect(d.kisi!.id, '24');
  });

  test('kartDegistirBaslat: Kart ver modu, adım 2, kişi seçili', () {
    d.modIade();
    d.numaraDenetleyici.text = '5';
    d.kartDegistirBaslat('61');
    expect(d.mod, KartVerModu.ver);
    expect(d.adim, 2);
    expect(d.kisi!.id, '61');
    expect(d.numara, '');
    expect(d.bulundu, isNull);
  });

  test('iadeBaslat: Kart iadesi modu, kişi seçili', () {
    d.iadeBaslat('61');
    expect(d.mod, KartVerModu.iade);
    expect(d.iadeKisisi!.id, '61');
  });

  test('adsız kart: ad yerine "Kart 14" yazılır (S14)', () {
    d.kartDegistirBaslat('14');
    d.acikKartSec('88');
    d.onayla();
    expect(d.sonAtama!.ad, 'Kart 14');
    d.iadeBaslat('14');
    d.iadeOnayla();
    expect(d.bilgi, '✓ Kart 14 iade alındı. Kart 14 panodan düştü; süreleri raporda kalır.');
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/ekranlar/kart_ver_durumu_test.dart
```

Beklenen: derleme hatası — `kart_ver_durumu.dart` için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/kart_ver/kart_ver_durumu.dart
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../mantik/kart_no.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';

enum KartVerModu { ver, iade }

enum KartSecimModu { yaklastir, numara }

/// Son yapılan atama (bantta gösterilir).
typedef SonAtama = ({String ad, String kart});

/// Kart Ver / Kart İadesi ekranının durumu. İşlemler sahte veriyi değiştirmez;
/// yalnız bant ve bilgi metni üretir (şartname §2). Sekme değişse de korunur.
class KartVerDurumu extends ChangeNotifier {
  KartVerDurumu(
    this._depo, {
    this.demoGecikmesi = const Duration(milliseconds: 1400),
    this.demoKarti = '88',
  }) {
    aramaDenetleyici.addListener(notifyListeners);
    numaraDenetleyici.addListener(notifyListeners);
  }

  final EtkinlikDeposu _depo;

  /// "Demo: kartı yaklaştır"dan sonra kartın bulunma süresi.
  final Duration demoGecikmesi;

  /// Demo yaklaştırmada bulunan kart.
  final String demoKarti;

  /// Adım 1 ve Kart İadesi aramasının ortak metni.
  final TextEditingController aramaDenetleyici = TextEditingController();

  /// "Numarayı yaz" alanının metni.
  final TextEditingController numaraDenetleyici = TextEditingController();

  KartVerModu _mod = KartVerModu.ver;
  int _adim = 1;
  String? _seciliKisi;
  String? _seciliKart;
  KartSecimModu _kartModu = KartSecimModu.yaklastir;
  String? _bulundu;
  SonAtama? _sonAtama;
  String? _bilgi;
  String? _iadeSecili;
  Timer? _demo;

  KartVerModu get mod => _mod;

  /// Sihirbaz adımı: 1 Kişi, 2 Kart, 3 Onay.
  int get adim => _adim;

  /// Kart verilecek kişi.
  Kisi? get kisi => _kisiBul(_seciliKisi);
  String? get seciliKart => _seciliKart;
  KartSecimModu get kartModu => _kartModu;

  /// "Yaklaştır ve tanı" ile bulunan kart.
  String? get bulundu => _bulundu;
  SonAtama? get sonAtama => _sonAtama;

  /// Geri alma ya da iade sonrası gösterilen bilgi metni.
  String? get bilgi => _bilgi;

  /// İadesi onaylanmayı bekleyen kişi.
  Kisi? get iadeKisisi => _kisiBul(_iadeSecili);
  String get arama => aramaDenetleyici.text;

  /// Yazılan numara; rakam dışı her şey atılmıştır.
  String get numara => yalnizRakam(numaraDenetleyici.text);
  bool get numaraSecilebilir => numaraGecerli(numara);

  Kisi? _kisiBul(String? id) => id == null ? null : _depo.bul(id);

  /// Bekleyen demo yaklaştırmayı iptal eder: adım ya da kişi değişince eski
  /// "Kart 88 bulundu" sonradan belirmesin.
  void _demoIptal() {
    _demo?.cancel();
    _demo = null;
  }

  void kisiSec(String id) {
    _demoIptal();
    _seciliKisi = id;
    _adim = 2;
    _bulundu = null;
    numaraDenetleyici.clear();
    notifyListeners();
  }

  void kartModuSec(KartSecimModu mod) {
    if (_kartModu == mod) return;
    _kartModu = mod;
    notifyListeners();
  }

  /// Donanım olmadan yaklaştırmayı taklit eder.
  void demoYaklastir() {
    _demoIptal();
    _demo = Timer(demoGecikmesi, () {
      _demo = null;
      _bulundu = demoKarti;
      notifyListeners();
    });
  }

  void bulunanSec() {
    final kart = _bulundu;
    if (kart == null) return;
    _seciliKart = kart;
    _adim = 3;
    notifyListeners();
  }

  void numaraSec() {
    if (!numaraSecilebilir) return;
    _seciliKart = numaraTemizle(numara);
    _adim = 3;
    notifyListeners();
  }

  void acikKartSec(String no) {
    _seciliKart = no;
    _adim = 3;
    notifyListeners();
  }

  void kisiAdiminaDon() {
    _demoIptal();
    _adim = 1;
    _bulundu = null;
    notifyListeners();
  }

  void kartAdiminaDon() {
    _demoIptal();
    _adim = 2;
    _bulundu = null;
    notifyListeners();
  }

  void onayla() {
    final k = kisi;
    final kart = _seciliKart;
    if (k == null || kart == null) return;
    _demoIptal();
    _sonAtama = (ad: gorunenAd(k), kart: kart);
    _bilgi = null;
    _adim = 1;
    _seciliKisi = null;
    _seciliKart = null;
    _bulundu = null;
    numaraDenetleyici.clear();
    aramaDenetleyici.clear();
    notifyListeners();
  }

  void geriAl() {
    final atama = _sonAtama;
    if (atama == null) return;
    _bilgi = '↶ Geri alındı: ${atama.ad} → Kart ${atama.kart} ataması kaldırıldı, kart boşta.';
    _sonAtama = null;
    notifyListeners();
  }

  void modVer() {
    _mod = KartVerModu.ver;
    _iadeSecili = null;
    notifyListeners();
  }

  void modIade() {
    _mod = KartVerModu.iade;
    notifyListeners();
  }

  void iadeSec(String id) {
    _iadeSecili = id;
    notifyListeners();
  }

  void iadeVazgec() {
    _iadeSecili = null;
    notifyListeners();
  }

  void iadeOnayla() {
    final k = iadeKisisi;
    if (k == null) return;
    _iadeSecili = null;
    _bilgi = '✓ Kart ${k.id} iade alındı. ${gorunenAd(k)} panodan düştü; süreleri raporda kalır.';
    notifyListeners();
  }

  /// Kişi Detayı → "Kartı değiştir": Kart ver modu, adım 2, kişi seçili.
  void kartDegistirBaslat(String id) {
    _demoIptal();
    _mod = KartVerModu.ver;
    _seciliKisi = id;
    _adim = 2;
    _bulundu = null;
    numaraDenetleyici.clear();
    notifyListeners();
  }

  /// Kişi Detayı → "Kartı iade al": Kart iadesi modu, kişi seçili.
  void iadeBaslat(String id) {
    _mod = KartVerModu.iade;
    _iadeSecili = id;
    notifyListeners();
  }

  @override
  void dispose() {
    _demoIptal();
    aramaDenetleyici.dispose();
    numaraDenetleyici.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (127 + 20 = 147 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 11: Kart Ver durumu — sihirbaz adımları, demo yaklaştırma, iade, geri al

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 12: Kart Ver — ekran (sihirbaz ve iade)

**Files:**
- Create: `lib/ekranlar/kart_ver/kart_ver_ekrani.dart`, `adim_gostergesi.dart`, `kisi_adimi.dart`, `kart_adimi.dart`, `nabiz.dart`, `kontrol_adimi.dart`, `iade_paneli.dart` (hepsi `lib/ekranlar/kart_ver/` altında)
- Test: `test/ekranlar/kart_ver_ekrani_test.dart`

**Interfaces:**
- Consumes: `KartVerDurumu`, `KartVerModu`, `KartSecimModu`, `SonAtama` (Task 11); `masaAra`, `acikKartOner`, `acikKartEtiketi` (Task 3); `tamAd`, `kartMetni` (Task 2); bileşenler (Task 7).
- Produces:
  - `KartVerEkrani({required EtkinlikDeposu depo, required KartVerDurumu durum})`
  - `AdimGostergesi({required int adim})`, `KisiAdimi({required depo, required durum})`, `KartAdimi({required depo, required durum})`, `KontrolAdimi({required durum})`, `IadePaneli({required depo, required durum})`, `Nabiz({double boyut = 56})`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/ekranlar/kart_ver_ekrani_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/adim_gostergesi.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_durumu.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/kart_ver_ekrani.dart';
import 'package:yakinlik_mobil/ekranlar/kart_ver/nabiz.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

// Not: Nabız sonsuz bir animasyondur; bu dosyada pumpAndSettle KULLANILMAZ.

class _Kurulum {
  _Kurulum(WidgetTester tester) : depo = EtkinlikDeposu() {
    durum = KartVerDurumu(depo);
    telefonBoyutu(tester);
    addTearDown(depo.dispose);
    addTearDown(durum.dispose);
  }

  final EtkinlikDeposu depo;
  late final KartVerDurumu durum;

  Widget get widget => temali(KartVerEkrani(depo: depo, durum: durum));
}

const _cem = 'Nova Robotik · Cem Erdem';

Future<_Kurulum> _kisiSecili(WidgetTester tester) async {
  final k = _Kurulum(tester);
  await tester.pumpWidget(k.widget);
  await tester.tap(find.text(_cem));
  await tester.pump();
  return k;
}

void main() {
  testWidgets('açılış: başlık, mod anahtarı, adım göstergesi, kişi listesi', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    expect(find.text('Kart Ver'), findsOneWidget);
    expect(find.text('Karşılama masası — gelen kişiye kart verin'), findsOneWidget);
    expect(find.text('Kart ver'), findsOneWidget);
    expect(find.text('Kart iadesi'), findsOneWidget);
    expect(find.byType(AdimGostergesi), findsOneWidget);
    expect(find.text('Kişi'), findsOneWidget);
    expect(find.text('Kart'), findsOneWidget);
    expect(find.text('Onay'), findsOneWidget);
    expect(find.text('Tümü (25)'), findsOneWidget);
    expect(find.text('Kart bekliyor (0)'), findsOneWidget);
    expect(find.text('Düzenle'), findsNWidgets(25));
    expect(find.text(_cem), findsOneWidget);
    expect(find.text('Kart 24'), findsOneWidget);
    expect(find.text('Kart 61 · ★★★★'), findsOneWidget);
  });

  testWidgets('arama kişi listesini süzer', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.enterText(find.byType(TextField), 'PEAK');
    await tester.pump();
    expect(find.text('Düzenle'), findsOneWidget);
    expect(find.text('Peak Enerji · İrem Korkmaz'), findsOneWidget);
  });

  testWidgets('kişi seçince adım 2: bekleme görünümü', (tester) async {
    await _kisiSecili(tester);
    expect(find.text('Kişi: $_cem'), findsOneWidget);
    expect(find.text('Yaklaştır ve tanı'), findsOneWidget);
    expect(find.text('önerilen'), findsOneWidget);
    expect(find.text('Numarayı yaz'), findsOneWidget);
    expect(find.byType(Nabiz), findsOneWidget);
    expect(find.text('Kartı alıcıya yaklaştırın…'), findsOneWidget);
    expect(find.text('Demo: boş bir kartı yaklaştır'), findsOneWidget);
    expect(find.text('← Kişi'), findsOneWidget);
    expect(find.text('Bu kartı seç'), findsNothing);
  });

  testWidgets('demo yaklaştırma: 1,4 sn sonra kart bulunur; seçince Kontrol adımı', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Demo: boş bir kartı yaklaştır'));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Kart 88 bulundu ✓'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Kart 88 bulundu ✓'), findsOneWidget);
    expect(find.text('Açık · az önce duyuldu · boşta'), findsOneWidget);
    expect(find.byType(Nabiz), findsNothing);

    await tester.tap(find.text('Bu kartı seç'));
    await tester.pump();
    expect(find.text('Kontrol'), findsOneWidget);
    expect(find.text('Durum'), findsOneWidget);
    expect(find.text('Açık'), findsOneWidget);
    expect(find.text('Son duyulma'), findsOneWidget);
    expect(find.text('az önce'), findsOneWidget);
    expect(find.text('%94'), findsOneWidget);
    expect(find.text('$_cem → Kart 88'), findsOneWidget);
    expect(find.text('← Kart'), findsOneWidget);
    expect(find.text('Onayla'), findsOneWidget);
  });

  testWidgets('onayla: son atama bandı ve adım 1; geri al: bilgi bandı', (tester) async {
    final k = await _kisiSecili(tester);
    k.durum.acikKartSec('88');
    await tester.pump();
    await tester.tap(find.text('Onayla'));
    await tester.pump();
    expect(find.text('✓ Cem Erdem → Kart 88 verildi.'), findsOneWidget);
    expect(find.text('↶ Geri al'), findsOneWidget);
    expect(find.text('Düzenle'), findsNWidgets(25));

    await tester.ensureVisible(find.text('↶ Geri al'));
    await tester.tap(find.text('↶ Geri al'));
    await tester.pump();
    expect(find.text('✓ Cem Erdem → Kart 88 verildi.'), findsNothing);
    expect(find.text('↶ Geri alındı: Cem Erdem → Kart 88 ataması kaldırıldı, kart boşta.'), findsOneWidget);
  });

  testWidgets('numara yolu: geçersiz numarada düğme yok; geçerli numarayla seçilir', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    expect(find.text('Kart numarası (kartın üstündeki etiket)'), findsOneWidget);
    expect(find.text('ŞU AN AÇIK KARTLAR'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('boşta'), findsNWidgets(5));
    expect(find.text('atanmış'), findsNWidgets(4));
    expect(find.text('Bu kartı seç'), findsNothing);

    for (final gecersiz in ['0', '00', '100', '12345678901234567890']) {
      await tester.enterText(find.byType(TextField), gecersiz);
      await tester.pump();
      expect(find.text('Bu kartı seç'), findsNothing, reason: '"$gecersiz" geçersiz');
      expect(tester.takeException(), isNull, reason: '"$gecersiz" çökertmemeli');
    }

    await tester.enterText(find.byType(TextField), '007');
    await tester.pump();
    await tester.ensureVisible(find.text('Bu kartı seç'));
    await tester.tap(find.text('Bu kartı seç'));
    await tester.pump();
    expect(find.text('$_cem → Kart 7'), findsOneWidget);
  });

  testWidgets('numara alanı harf kabul etmez; ızgara ön eke göre süzülür', (tester) async {
    final k = await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '8a');
    await tester.pump();
    expect(k.durum.numaraDenetleyici.text, '8');
    expect(find.text('Kart 88'), findsOneWidget);
    expect(find.text('Kart 89'), findsOneWidget);
    expect(find.text('Kart 90'), findsNothing);
  });

  testWidgets('açık karta dokununca Kontrol adımına geçer', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    await tester.tap(find.text('Kart 89'));
    await tester.pump();
    expect(find.text('$_cem → Kart 89'), findsOneWidget);
  });

  testWidgets('← Kart ve ← Kişi geri döner', (tester) async {
    final k = await _kisiSecili(tester);
    k.durum.acikKartSec('89');
    await tester.pump();
    await tester.tap(find.text('← Kart'));
    await tester.pump();
    expect(find.text('Kişi: $_cem'), findsOneWidget);
    await tester.tap(find.text('← Kişi'));
    await tester.pump();
    expect(find.text('Düzenle'), findsNWidgets(25));
  });

  testWidgets('demo beklerken geri dönülürse eski kart sonradan belirmez (S16)', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Demo: boş bir kartı yaklaştır'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('← Kişi'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Peak Enerji · İrem Korkmaz'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Kişi: Peak Enerji · İrem Korkmaz'), findsOneWidget);
    expect(find.text('Kartı alıcıya yaklaştırın…'), findsOneWidget);
    expect(find.text('Kart 88 bulundu ✓'), findsNothing);
  });

  testWidgets('yaklaştır modunda alttaki "Bu kartı seç" görünmez (S13)', (tester) async {
    await _kisiSecili(tester);
    await tester.tap(find.text('Numarayı yaz'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '14');
    await tester.pump();
    expect(find.text('Bu kartı seç'), findsOneWidget);
    await tester.tap(find.text('Yaklaştır ve tanı'));
    await tester.pump();
    expect(find.text('Bu kartı seç'), findsNothing);
  });

  testWidgets('Kart iadesi: liste, onay kutusu, vazgeç ve iade al', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Kart iadesi'));
    await tester.pump();
    expect(find.text('Kart İadesi'), findsOneWidget);
    expect(find.text('Ayrılan kişiden kartı geri alın'), findsOneWidget);
    expect(find.text('Kart no, ad veya kurum'), findsOneWidget);
    expect(find.byType(AdimGostergesi), findsNothing);
    expect(find.text('Düzenle'), findsNothing);
    expect(find.text('Kart 24'), findsOneWidget);

    await tester.tap(find.text(_cem));
    await tester.pump();
    expect(find.text('Kart 24 iade alınsın mı?'), findsOneWidget);
    expect(find.text('$_cem panodan düşer; bugünkü süreleri raporda kalır.'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pump();
    expect(find.text('Kart 24 iade alınsın mı?'), findsNothing);

    await tester.tap(find.text(_cem));
    await tester.pump();
    await tester.tap(find.text('İade al'));
    await tester.pump();
    expect(find.text('Kart 24 iade alınsın mı?'), findsNothing);
    expect(find.text('✓ Kart 24 iade alındı. Cem Erdem panodan düştü; süreleri raporda kalır.'), findsOneWidget);
  });

  testWidgets('iade araması kart numarasıyla da bulur', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    await tester.tap(find.text('Kart iadesi'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '61');
    await tester.pump();
    expect(find.text('Ayşe Demir'), findsOneWidget);
    expect(find.text(_cem), findsNothing);
  });

  testWidgets('son atama bandı iki modda da görünür', (tester) async {
    final k = await _kisiSecili(tester);
    k.durum.acikKartSec('88');
    k.durum.onayla();
    await tester.pump();
    await tester.tap(find.text('Kart iadesi'));
    await tester.pump();
    expect(find.text('✓ Cem Erdem → Kart 88 verildi.'), findsOneWidget);
  });

  testWidgets('Kişi Detayı kısayolları ekranı doğru yerden açar', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    k.durum.kartDegistirBaslat('61');
    await tester.pump();
    expect(find.text('Kişi: Ayşe Demir'), findsOneWidget);
    k.durum.iadeBaslat('61');
    await tester.pump();
    expect(find.text('Kart 61 iade alınsın mı?'), findsOneWidget);
  });

  testWidgets('adsız kart: kişi adı yerine "Kart 14" (S14)', (tester) async {
    final k = _Kurulum(tester);
    await tester.pumpWidget(k.widget);
    k.durum.kartDegistirBaslat('14');
    await tester.pump();
    expect(find.text('Kişi: Kart 14'), findsOneWidget);
    k.durum.acikKartSec('88');
    await tester.pump();
    expect(find.text('Kart 14 → Kart 88'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"hareketi azalt" açıkken nabız sabit durur', (tester) async {
    await tester.pumpWidget(
      temali(const MediaQuery(data: MediaQueryData(disableAnimations: true), child: Center(child: Nabiz()))),
    );
    await tester.pumpAndSettle(); // sonsuz animasyon olsaydı zaman aşımına düşerdi
    expect(find.byType(Nabiz), findsOneWidget);
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/ekranlar/kart_ver_ekrani_test.dart
```

Beklenen: derleme hatası — `adim_gostergesi.dart`, `kart_ver_ekrani.dart`, `nabiz.dart` için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/kart_ver/nabiz.dart
import 'package:flutter/widgets.dart';

import '../../tema/renkler.dart';

/// "Kartı alıcıya yaklaştırın" nabzı: 2 px vurgu halka `scale .8 → 1.8`,
/// `opacity .7 → 0`; 1,6 sn, ease-out, sonsuz. Ortada dolu daire.
class Nabiz extends StatefulWidget {
  const Nabiz({super.key, this.boyut = 56});

  final double boyut;

  @override
  State<Nabiz> createState() => _NabizState();
}

class _NabizState extends State<Nabiz> with SingleTickerProviderStateMixin {
  late final AnimationController _denetleyici = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final CurvedAnimation _egri = CurvedAnimation(parent: _denetleyici, curve: Curves.easeOut);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sistemde "hareketi azalt" açıksa halka sabit durur.
    if (MediaQuery.disableAnimationsOf(context)) {
      _denetleyici.stop();
      _denetleyici.value = 0.25;
    } else if (!_denetleyici.isAnimating) {
      _denetleyici.repeat();
    }
  }

  @override
  void dispose() {
    _egri.dispose();
    _denetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.boyut,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _egri,
                builder: (context, child) => Opacity(
                  opacity: 0.7 * (1 - _egri.value),
                  child: Transform.scale(scale: 0.8 + _egri.value, child: child),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Renkler.vurgu, width: 2),
                  ),
                ),
              ),
            ),
            SizedBox.square(
              dimension: widget.boyut - 32,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Renkler.vurgu, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/kart_ver/adim_gostergesi.dart
import 'package:flutter/widgets.dart';

import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';

/// Sihirbazın adım göstergesi: 3 hap (Kişi · Kart · Onay). Etkin = vurgu dolgu,
/// biten = metin renginde numara rozeti, bekleyen = gri rozet.
class AdimGostergesi extends StatelessWidget {
  const AdimGostergesi({super.key, required this.adim});

  /// Etkin adım: 1–3.
  final int adim;

  static const List<String> _adlar = ['Kişi', 'Kart', 'Onay'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Row(
        children: [
          for (var no = 1; no <= _adlar.length; no++) ...[
            if (no > 1) const SizedBox(width: 8),
            Expanded(
              child: _Hap(no: no, ad: _adlar[no - 1], etkin: adim == no, bitti: adim > no),
            ),
          ],
        ],
      ),
    );
  }
}

class _Hap extends StatelessWidget {
  const _Hap({required this.no, required this.ad, required this.etkin, required this.bitti});

  final int no;
  final String ad;
  final bool etkin;
  final bool bitti;

  @override
  Widget build(BuildContext context) {
    final Color yazi;
    final Color rozetZemin;
    final Color rozetYazi;
    if (etkin) {
      yazi = Renkler.zemin;
      rozetZemin = Renkler.zemin;
      rozetYazi = Renkler.vurguBasili;
    } else if (bitti) {
      yazi = Renkler.metin;
      rozetZemin = Renkler.metin;
      rozetYazi = Renkler.zemin;
    } else {
      yazi = Renkler.metin2;
      rozetZemin = Renkler.ayrac;
      rozetYazi = Renkler.metin;
    }
    return Semantics(
      selected: etkin,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: etkin ? Renkler.vurgu : null, borderRadius: Olculer.hapYaricap),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(color: rozetZemin, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$no',
                    textScaler: TextScaler.noScaling,
                    style: Yazi.olcu(12, agirlik: FontWeight.w600, satir: 1, renk: rozetYazi),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(ad, maxLines: 1, overflow: TextOverflow.ellipsis, style: Yazi.olcu(14, renk: yazi)),
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/kart_ver/kisi_adimi.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kart_no.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kart_ver_durumu.dart';

/// Adım 1 — Kişi: kayıtlı kişilerde arama ve kişi kartları.
class KisiAdimi extends StatelessWidget {
  const KisiAdimi({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final liste = masaAra(depo.kisiler, durum.arama);
    final ikincil = Yazi.olcu(14, renk: Renkler.metin2);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AramaAlani(
            ipucu: 'Kayıtlı kişilerde ara: ad veya kurum',
            denetleyici: durum.aramaDenetleyici,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Tümü',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Renkler.metin),
                    ),
                    TextSpan(text: ' (${depo.kayitliKatilimci})'),
                  ],
                ),
                style: ikincil,
              ),
              Text('Kart bekliyor (0)', style: ikincil),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < liste.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _KisiKarti(kisi: liste[i], onTap: () => durum.kisiSec(liste[i].id)),
          ],
        ],
      ),
    );
  }
}

class _KisiKarti extends StatelessWidget {
  const _KisiKarti({required this.kisi, required this.onTap});

  final Kisi kisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: Olculer.dokunmaEnAz),
                    child: Row(
                      children: [
                        RolSekli(rol: kisi.rol, renk: kisi.renk),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tamAd(kisi), style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2)),
                              const SizedBox(height: 2),
                              Text(kartMetni(kisi), style: Yazi.olcu(13, renk: Renkler.metin2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Kişi düzenleme ekranı tasarlanmadı (şartname §2).
            const HapDugme(etiket: 'Düzenle', tur: HapTuru.hayalet, yukseklik: 36, onTap: islevsiz),
          ],
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/kart_ver/kart_adimi.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/kart_no.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kart_ver_durumu.dart';
import 'nabiz.dart';

/// Adım 2 — Kart: "Yaklaştır ve tanı" ya da "Numarayı yaz".
class KartAdimi extends StatelessWidget {
  const KartAdimi({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final kisi = durum.kisi;
    final numaraModu = durum.kartModu == KartSecimModu.numara;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: 'Kişi: ',
              children: [
                TextSpan(
                  text: kisi == null ? '' : tamAd(kisi),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.metin),
                ),
              ],
            ),
            style: Yazi.olcu(14, renk: Renkler.metin2),
          ),
          const SizedBox(height: 14),
          BolmeliAnahtar<KartSecimModu>(
            ekPunto: 11,
            araCizgi: true,
            secenekler: const [
              BolmeSecenegi(deger: KartSecimModu.yaklastir, etiket: 'Yaklaştır ve tanı', ek: 'önerilen'),
              BolmeSecenegi(deger: KartSecimModu.numara, etiket: 'Numarayı yaz'),
            ],
            secili: durum.kartModu,
            onSecildi: durum.kartModuSec,
          ),
          const SizedBox(height: 14),
          if (numaraModu)
            _NumaraGirisi(depo: depo, durum: durum)
          else if (durum.bulundu case final kart?)
            _Bulundu(kart: kart, onSec: durum.bulunanSec)
          else
            _Bekleme(onDemo: durum.demoYaklastir),
          // 14 px bölüm aralığı + 6 px üst boşluk.
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HapDugme(etiket: '← Kişi', onTap: durum.kisiAdiminaDon),
              // Yalnız "Numarayı yaz" modunda ve numara geçerliyken (S13).
              if (numaraModu && durum.numaraSecilebilir)
                HapDugme(etiket: 'Bu kartı seç', tur: HapTuru.birincil, onTap: durum.numaraSec),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kart bekleniyor: nabız + demo düğmesi.
class _Bekleme extends StatelessWidget {
  const _Bekleme({required this.onDemo});

  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Demo düğmesinin görseli 40 px, dokunma alanı 44 px: üstündeki 18 px ve
      // altındaki 16 px boşluğun 2'şer pikseli dokunma alanının içindedir.
      padding: const EdgeInsets.only(top: 28, bottom: 14),
      child: Column(
        children: [
          const Nabiz(),
          const SizedBox(height: 18),
          Text('Kartı alıcıya yaklaştırın…', textAlign: TextAlign.center, style: Yazi.olcu(16)),
          const SizedBox(height: 16),
          HapDugme(etiket: 'Demo: boş bir kartı yaklaştır', yukseklik: 40, onTap: onDemo),
        ],
      ),
    );
  }
}

/// Kart bulundu: numara + seç düğmesi.
class _Bulundu extends StatelessWidget {
  const _Bulundu({required this.kart, required this.onSec});

  final String kart;
  final VoidCallback onSec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        children: [
          Text(
            'Kart $kart bulundu ✓',
            textAlign: TextAlign.center,
            style: Yazi.olcu(28, agirlik: FontWeight.w600, satir: 1),
          ),
          const SizedBox(height: 14),
          Text(
            'Açık · az önce duyuldu · boşta',
            textAlign: TextAlign.center,
            style: Yazi.olcu(14, renk: Renkler.metin2),
          ),
          const SizedBox(height: 14),
          HapDugme(
            etiket: 'Bu kartı seç',
            tur: HapTuru.birincil,
            yukseklik: 48,
            punto: 16,
            yatayBosluk: 28,
            onTap: onSec,
          ),
        ],
      ),
    );
  }
}

/// Numara girdisi + "şu an açık kartlar" ızgarası.
class _NumaraGirisi extends StatelessWidget {
  const _NumaraGirisi({required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Kart numarası (kartın üstündeki etiket)', style: Yazi.olcu(13, renk: Renkler.metin2)),
        const SizedBox(height: 6),
        AramaAlani(
          ipucu: 'Örn. 14',
          denetleyici: durum.numaraDenetleyici,
          yukseklik: 52,
          punto: 24,
          agirlik: FontWeight.w600,
          harfAraligi: 1.2,
          rakam: true,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(child: Kicker('Şu an açık kartlar')),
            const SizedBox(width: 8),
            Kicker('${depo.acikKartlar.length}'),
          ],
        ),
        const SizedBox(height: 14),
        _KartIzgarasi(kartlar: acikKartOner(depo.acikKartlar, durum.numara), onSec: durum.acikKartSec),
      ],
    );
  }
}

/// 3 sütunlu kart ızgarası.
class _KartIzgarasi extends StatelessWidget {
  const _KartIzgarasi({required this.kartlar, required this.onSec});

  final List<AcikKart> kartlar;
  final ValueChanged<String> onSec;

  static const int _sutun = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var bas = 0; bas < kartlar.length; bas += _sutun) ...[
          if (bas > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var i = bas; i < bas + _sutun; i++) ...[
                if (i > bas) const SizedBox(width: 8),
                Expanded(
                  child: i < kartlar.length
                      ? _Hucre(kart: kartlar[i], onTap: () => onSec(kartlar[i].no))
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Hucre extends StatelessWidget {
  const _Hucre({required this.kart, required this.onTap});

  final AcikKart kart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kart ${kart.no}', style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2)),
                  const SizedBox(height: 2),
                  Text(acikKartEtiketi(kart), style: Yazi.olcu(12, renk: Renkler.metin2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/kart_ver/kontrol_adimi.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/etiketli_deger.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import 'kart_ver_durumu.dart';

/// Adım 3 — Kontrol: kart durumu, "kişi → kart" özeti ve onay.
class KontrolAdimi extends StatelessWidget {
  const KontrolAdimi({super.key, required this.durum});

  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final kisi = durum.kisi;
    final kart = durum.seciliKart;
    if (kisi == null || kart == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Kontrol', style: Yazi.baslik(18, 1.2)),
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: EtiketliDeger(etiket: 'Durum', deger: 'Açık')),
              SizedBox(width: 12),
              Expanded(child: EtiketliDeger(etiket: 'Son duyulma', deger: 'az önce')),
              SizedBox(width: 12),
              Expanded(child: EtiketliDeger(etiket: 'Pil', deger: '%94')),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  RolSekli(rol: kisi.rol, renk: kisi.renk, boyut: 14),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${tamAd(kisi)} → Kart $kart',
                      style: Yazi.olcu(20, agirlik: FontWeight.w600, satir: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              HapDugme(etiket: '← Kart', yukseklik: 48, onTap: durum.kartAdiminaDon),
              const SizedBox(width: 10),
              Expanded(
                child: HapDugme(
                  etiket: 'Onayla',
                  tur: HapTuru.birincil,
                  yukseklik: 48,
                  punto: 16,
                  genis: true,
                  onTap: durum.onayla,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

```dart title=lib/ekranlar/kart_ver/iade_paneli.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/arama_alani.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/rol_sekli.dart';
import '../../mantik/kart_no.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import '../../veri/modeller.dart';
import 'kart_ver_durumu.dart';

/// Kart İadesi: arama, onay kutusu ve kartı olan kişilerin listesi.
class IadePaneli extends StatelessWidget {
  const IadePaneli({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    final liste = masaAra(depo.kisiler, durum.arama);
    final secili = durum.iadeKisisi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 16, Olculer.sayfaKenari, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AramaAlani(ipucu: 'Kart no, ad veya kurum', denetleyici: durum.aramaDenetleyici),
          if (secili != null) ...[
            const SizedBox(height: 12),
            _OnayKutusu(kisi: secili, onVazgec: durum.iadeVazgec, onOnay: durum.iadeOnayla),
          ],
          const SizedBox(height: 12),
          for (final k in liste) _IadeSatiri(kisi: k, onTap: () => durum.iadeSec(k.id)),
        ],
      ),
    );
  }
}

class _OnayKutusu extends StatelessWidget {
  const _OnayKutusu({required this.kisi, required this.onVazgec, required this.onOnay});

  final Kisi kisi;
  final VoidCallback onVazgec;
  final VoidCallback onOnay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kart ${kisi.id} iade alınsın mı?',
              style: Yazi.olcu(18, agirlik: FontWeight.w600, satir: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              '${tamAd(kisi)} panodan düşer; bugünkü süreleri raporda kalır.',
              style: Yazi.olcu(14, renk: Renkler.metin2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                HapDugme(etiket: 'Vazgeç', onTap: onVazgec),
                const SizedBox(width: 10),
                Expanded(
                  child: HapDugme(etiket: 'İade al', tur: HapTuru.birincil, genis: true, onTap: onOnay),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IadeSatiri extends StatelessWidget {
  const _IadeSatiri({required this.kisi, required this.onTap});

  final Kisi kisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Renkler.ayrac)),
          ),
          child: Row(
            children: [
              RolSekli(rol: kisi.rol, renk: kisi.renk, boyut: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Text(tamAd(kisi), style: Yazi.olcu(16, agirlik: FontWeight.w600, satir: 1.2)),
              ),
              const SizedBox(width: 12),
              Text('Kart ${kisi.id}', style: Yazi.olcu(14, renk: Renkler.metin2, rakam: true)),
            ],
          ),
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/kart_ver/kart_ver_ekrani.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/bolmeli_anahtar.dart';
import '../../bilesenler/hap_dugme.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import 'adim_gostergesi.dart';
import 'iade_paneli.dart';
import 'kart_adimi.dart';
import 'kart_ver_durumu.dart';
import 'kisi_adimi.dart';
import 'kontrol_adimi.dart';

/// Kart Ver sekmesi: "Kart ver" sihirbazı ve "Kart iadesi" modu.
class KartVerEkrani extends StatelessWidget {
  const KartVerEkrani({super.key, required this.depo, required this.durum});

  final EtkinlikDeposu depo;
  final KartVerDurumu durum;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: durum,
      builder: (context, _) {
        final ver = durum.mod == KartVerModu.ver;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(ver ? 'Kart Ver' : 'Kart İadesi', style: Yazi.baslik(26, 1.1)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ver ? 'Karşılama masası — gelen kişiye kart verin' : 'Ayrılan kişiden kartı geri alın',
                      style: Yazi.olcu(14, renk: Renkler.metin2),
                    ),
                    const SizedBox(height: 14),
                    BolmeliAnahtar<KartVerModu>(
                      punto: 15,
                      agirlik: FontWeight.w600,
                      araCizgi: true,
                      secenekler: const [
                        BolmeSecenegi(deger: KartVerModu.ver, etiket: 'Kart ver'),
                        BolmeSecenegi(deger: KartVerModu.iade, etiket: 'Kart iadesi'),
                      ],
                      secili: durum.mod,
                      onSecildi: (mod) => mod == KartVerModu.ver ? durum.modVer() : durum.modIade(),
                    ),
                    if (durum.sonAtama case final atama?) ...[
                      const SizedBox(height: 14),
                      _SonAtamaBandi(atama: atama, onGeriAl: durum.geriAl),
                    ],
                    if (durum.bilgi case final bilgi?) ...[
                      const SizedBox(height: 14),
                      _BilgiBandi(bilgi),
                    ],
                  ],
                ),
              ),
              if (!ver)
                IadePaneli(depo: depo, durum: durum)
              else ...[
                AdimGostergesi(adim: durum.adim),
                switch (durum.adim) {
                  1 => KisiAdimi(depo: depo, durum: durum),
                  2 => KartAdimi(depo: depo, durum: durum),
                  _ => KontrolAdimi(durum: durum),
                },
              ],
            ],
          ),
        );
      },
    );
  }
}

/// "✓ Ad → Kart 88 verildi." + Geri al.
class _SonAtamaBandi extends StatelessWidget {
  const _SonAtamaBandi({required this.atama, required this.onGeriAl});

  final SonAtama atama;
  final VoidCallback onGeriAl;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.vurguZemin, borderRadius: Olculer.koseYaricap),
      child: Padding(
        // Geri al görseli 36 px, dokunma alanı 44 px: 10 px dikey boşluğun
        // 4 pikseli dokunma alanının içindedir.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '✓ ${atama.ad} → Kart ${atama.kart} verildi.',
                style: Yazi.olcu(14, renk: Renkler.vurguKoyu),
              ),
            ),
            const SizedBox(width: 10),
            HapDugme(etiket: '↶ Geri al', yukseklik: 36, zemin: Renkler.zemin, onTap: onGeriAl),
          ],
        ),
      ),
    );
  }
}

/// Geri alma ya da iade sonrası bilgi metni.
class _BilgiBandi extends StatelessWidget {
  const _BilgiBandi(this.metin);

  final String metin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(metin, style: Yazi.olcu(14)),
      ),
    );
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (147 + 17 = 164 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 12: Kart Ver ekranı — 3 adımlı sihirbaz, nabız, numara ızgarası, kart iadesi

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---
### Task 13: Kurulum ekranı

**Files:**
- Create: `lib/ekranlar/kurulum/esik_bolumu.dart`, `sinyal_grafigi.dart`, `kart_sagligi_bolumu.dart`, `kurulum_ekrani.dart` (hepsi `lib/ekranlar/kurulum/` altında)
- Test: `test/ekranlar/kurulum_test.dart`

**Interfaces:**
- Consumes: `EtkinlikDeposu` (Task 5); `esikAlt`, `esikUst`, `esikUstuCiftSayisi`, `grafikY`, `grafikSolBosluk`, `grafikSerileri`, `GrafikSerisi`, `kartSagligi`, `SaglikSatiri`, `sorunluKartSayisi` (Task 4); `dbmYazisi` (Task 2); `HapDugme`, `islevsiz`, `Kicker`, `kesikCizgi` (Task 7).
- Produces: `KurulumEkrani({required EtkinlikDeposu depo})`, `EsikBolumu({required depo})`, `SinyalBolumu({required depo})`, `KartSagligiBolumu({required depo})`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/ekranlar/kurulum_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/kurulum/kurulum_ekrani.dart';
import 'package:yakinlik_mobil/ekranlar/kurulum/sinyal_grafigi.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

Future<EtkinlikDeposu> _kur(WidgetTester tester) async {
  telefonBoyutu(tester);
  final depo = EtkinlikDeposu();
  addTearDown(depo.dispose);
  await tester.pumpWidget(temali(KurulumEkrani(depo: depo)));
  return depo;
}

Finder _grafik() => find.descendant(of: find.byType(SinyalBolumu), matching: find.byType(CustomPaint));

void main() {
  testWidgets('başlık ve eşik bölümü', (tester) async {
    await _kur(tester);
    expect(find.text('Kurulum'), findsOneWidget);
    expect(
      find.text('Teknik ekran — eşik ayarı, sinyaller ve kart sağlığı. Etkinlik öncesi kullanılır.'),
      findsOneWidget,
    );
    expect(find.text('EŞİK'), findsOneWidget);
    expect(find.text('−72'), findsOneWidget);
    expect(find.text('dBm'), findsOneWidget);
    expect(find.text('Şu an 8 çift eşiğin üstünde.'), findsOneWidget);
    expect(find.text('−1'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('−95 · gevşek'), findsOneWidget);
    expect(find.text('sıkı · −35'), findsOneWidget);
  });

  testWidgets('canlı sinyal, kalibrasyon ve kart sağlığı bölümleri', (tester) async {
    await _kur(tester);
    expect(find.text('CANLI SİNYAL (SON 90 SN)'), findsOneWidget);
    expect(find.text('En güçlü 6 çift'), findsOneWidget);
    expect(find.text('90 sn önce'), findsOneWidget);
    expect(find.text('kesik çizgi: eşik −72 dBm'), findsOneWidget);
    expect(find.text('şimdi'), findsOneWidget);
    expect(find.text('27 · 28'), findsOneWidget);
    expect(find.text('44 · 67'), findsOneWidget);
    expect(find.text('33 · 46'), findsNothing); // ilk altı çiftin dışındakiler çizilmez
    expect(find.text('KALİBRASYON'), findsOneWidget);
    expect(find.text('— çift seçin —'), findsOneWidget);
    expect(find.text('⌄'), findsOneWidget);
    expect(find.text('KART SAĞLIĞI'), findsOneWidget);
    expect(find.text('32 kart duyuluyor · ⚠ 1 sorunlu'), findsOneWidget);
    expect(find.text('Mehmet Kılıç'), findsOneWidget);
    expect(find.text('⚠ pil düşük'), findsOneWidget);
    expect(find.text('%16'), findsOneWidget);
    expect(find.text('✓ iyi'), findsNWidgets(7));
    expect(find.text('%72'), findsNWidgets(2));
    expect(find.text('Kart 14'), findsOneWidget);
  });

  testWidgets('grafik: eşik üstü bölge, altı çizgi ve kesik eşik çizgisi', (tester) async {
    await _kur(tester);
    expect(
      _grafik(),
      paints
        ..rect()
        ..path()
        ..path()
        ..path()
        ..path()
        ..path()
        ..path()
        ..line(),
    );
  });

  testWidgets('−1 ve +1 eşiği değiştirir; yazılar güncellenir', (tester) async {
    final depo = await _kur(tester);
    await tester.tap(find.text('+1'));
    await tester.pump();
    expect(depo.esik, -71);
    expect(find.text('−71'), findsOneWidget);
    expect(find.text('kesik çizgi: eşik −71 dBm'), findsOneWidget);
    await tester.tap(find.text('−1'));
    await tester.tap(find.text('−1'));
    await tester.pump();
    expect(depo.esik, -73);
    expect(find.text('−73'), findsOneWidget);
  });

  testWidgets('eşiğin üstündeki çift sayısı eşikle değişir', (tester) async {
    final depo = await _kur(tester);
    depo.esikAyarla(-60);
    await tester.pump();
    expect(find.text('Şu an 4 çift eşiğin üstünde.'), findsOneWidget);
    depo.esikAyarla(-95);
    await tester.pump();
    expect(find.text('Şu an 10 çift eşiğin üstünde.'), findsOneWidget);
  });

  testWidgets('eşik sınırlarda durur; grafik taşmaz (S15)', (tester) async {
    final depo = await _kur(tester);
    depo.esikAyarla(-95);
    await tester.pump();
    await tester.tap(find.text('−1'));
    await tester.pump();
    expect(depo.esik, -95);
    expect(tester.takeException(), isNull);

    depo.esikAyarla(-35);
    await tester.pump();
    await tester.tap(find.text('+1'));
    await tester.pump();
    expect(depo.esik, -35);
    expect(find.text('Şu an 0 çift eşiğin üstünde.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kaydırıcı eşiği değiştirir ve sınırlar içinde kalır', (tester) async {
    final depo = await _kur(tester);
    await tester.drag(find.byType(Slider), const Offset(-600, 0));
    await tester.pump();
    expect(depo.esik, -95);
    await tester.drag(find.byType(Slider), const Offset(600, 0));
    await tester.pump();
    expect(depo.esik, -35);
  });

  testWidgets('kart sağlığı: sorunlu satır vurgulanır', (tester) async {
    await _kur(tester);
    final kutu = tester.widget<DecoratedBox>(
      find.ancestor(of: find.text('Mehmet Kılıç'), matching: find.byType(DecoratedBox)).first,
    );
    expect((kutu.decoration as BoxDecoration).color, Renkler.ciddiZemin);
    expect(tester.widget<Text>(find.text('⚠ pil düşük')).style!.color, Renkler.ciddi);
    expect(tester.widget<Text>(find.text('%16')).style!.color, Renkler.ciddi);
    // Adsız kart ikincil renkte yazılır.
    expect(tester.widget<Text>(find.text('Kart 14')).style!.color, Renkler.metin2);
  });

  testWidgets('"— çift seçin —" işlevsizdir: dokununca hiçbir şey değişmez', (tester) async {
    final depo = await _kur(tester);
    await tester.ensureVisible(find.text('— çift seçin —'));
    await tester.tap(find.text('— çift seçin —'));
    await tester.pump();
    expect(depo.esik, -72);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saniye ilerleyince grafik yeniden çizilir, yazılar bozulmaz', (tester) async {
    final depo = await _kur(tester);
    depo.ilerlet();
    await tester.pump();
    expect(_grafik(), paints..path());
    expect(find.text('27 · 28'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/ekranlar/kurulum_test.dart
```

Beklenen: derleme hatası — `kurulum_ekrani.dart`, `sinyal_grafigi.dart` için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/kurulum/esik_bolumu.dart
import 'package:flutter/material.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kurulum.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// EŞİK: büyük değer, "eşiğin üstündeki çift" sayısı, −1 / kaydırıcı / +1.
class EsikBolumu extends StatelessWidget {
  const EsikBolumu({super.key, required this.depo});

  final EtkinlikDeposu depo;

  @override
  Widget build(BuildContext context) {
    final ustu = esikUstuCiftSayisi(depo.ciftler, depo.esik);
    final ucYazisi = Yazi.olcu(12, renk: Renkler.metin2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Eşik'),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              dbmYazisi(depo.esik),
              style: Yazi.olcu(56, agirlik: FontWeight.w600, satir: 1, rakam: true, harfAraligi: -1.12),
            ),
            const SizedBox(width: 8),
            Text('dBm', style: Yazi.olcu(18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Şu an ',
                  children: [
                    TextSpan(
                      text: '$ustu',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.metin),
                    ),
                    const TextSpan(text: ' çift eşiğin üstünde.'),
                  ],
                ),
                textAlign: TextAlign.right,
                style: Yazi.olcu(14, renk: Renkler.metin2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            HapDugme(
              etiket: '−1',
              anlam: 'Eşiği bir azalt',
              genislik: 48,
              yukseklik: 48,
              punto: 18,
              onTap: depo.esikAzalt,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                value: depo.esik.toDouble(),
                min: esikAlt.toDouble(),
                max: esikUst.toDouble(),
                divisions: esikUst - esikAlt,
                padding: EdgeInsets.zero,
                semanticFormatterCallback: (deger) => '${dbmYazisi(deger.round())} dBm',
                onChanged: (deger) => depo.esikAyarla(deger.round()),
              ),
            ),
            const SizedBox(width: 12),
            HapDugme(
              etiket: '+1',
              anlam: 'Eşiği bir artır',
              genislik: 48,
              yukseklik: 48,
              punto: 18,
              onTap: depo.esikArtir,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('−95 · gevşek', style: ucYazisi),
            Text('sıkı · −35', style: ucYazisi),
          ],
        ),
      ],
    );
  }
}
```

```dart title=lib/ekranlar/kurulum/sinyal_grafigi.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/kesik_cizgi.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/bicim.dart';
import '../../mantik/kurulum.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// CANLI SİNYAL: en güçlü 6 çiftin son 90 saniyesi, eşik çizgisi ve lejant.
class SinyalBolumu extends StatelessWidget {
  const SinyalBolumu({super.key, required this.depo});

  final EtkinlikDeposu depo;

  static const double _grafikYuksekligi = 150;

  @override
  Widget build(BuildContext context) {
    final esik = dbmYazisi(depo.esik);
    final altYazi = Yazi.olcu(12, renk: Renkler.metin2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Expanded(child: Kicker('Canlı sinyal (son 90 sn)')),
            const SizedBox(width: 8),
            Text('En güçlü 6 çift', style: Yazi.olcu(13, renk: Renkler.metin2)),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, kisit) {
            final seriler = grafikSerileri(
              depo.ciftler,
              depo.seriRenkleri,
              depo.tick,
              kisit.maxWidth,
              _grafikYuksekligi,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'Canlı sinyal grafiği: en güçlü ${seriler.length} çift, eşik $esik dBm',
                  child: SizedBox(
                    height: _grafikYuksekligi,
                    child: CustomPaint(
                      painter: _GrafikCizici(
                        seriler: seriler,
                        esikY: grafikY(depo.esik, _grafikYuksekligi),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: grafikSolBosluk, top: 4),
                  child: Row(
                    children: [
                      Text('90 sn önce', style: altYazi),
                      Expanded(
                        child: Text(
                          'kesik çizgi: eşik $esik dBm',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: altYazi,
                        ),
                      ),
                      Text('şimdi', style: altYazi),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [for (final seri in seriler) _LejantOgesi(seri: seri)],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LejantOgesi extends StatelessWidget {
  const _LejantOgesi({required this.seri});

  final GrafikSerisi seri;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Renkler.kisi(seri.renk), shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Text(seri.ad, style: Yazi.olcu(13, rakam: true)),
      ],
    );
  }
}

class _GrafikCizici extends CustomPainter {
  _GrafikCizici({required this.seriler, required this.esikY});

  final List<GrafikSerisi> seriler;

  /// Eşik çizgisinin y konumu; grafik sınırları içindedir (S15).
  final double esikY;

  @override
  void paint(Canvas canvas, Size size) {
    // Eşik üstü ("yakın") bölge.
    if (esikY > 0) {
      canvas.drawRect(
        Rect.fromLTRB(grafikSolBosluk, 0, size.width, esikY),
        Paint()..color = Renkler.vurguZemin,
      );
    }
    _yaz(canvas, 'eşik üstü — yakın', const Offset(32, 12), Renkler.vurguBasili);
    _yaz(canvas, '−40', const Offset(0, 14), Renkler.metin2);
    _yaz(canvas, '−65', const Offset(0, 76), Renkler.metin2);
    _yaz(canvas, '−90', const Offset(0, 140), Renkler.metin2);

    for (final seri in seriler) {
      final yol = Path();
      for (final (i, nokta) in seri.noktalar.indexed) {
        if (i == 0) {
          yol.moveTo(nokta.x, nokta.y);
        } else {
          yol.lineTo(nokta.x, nokta.y);
        }
      }
      canvas.drawPath(
        yol,
        Paint()
          ..color = Renkler.kisi(seri.renk)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    kesikCizgi(
      canvas,
      Offset(grafikSolBosluk, esikY),
      Offset(size.width, esikY),
      Paint()
        ..color = Renkler.metin
        ..strokeWidth = 1.2,
      dolu: 5,
      bos: 4,
    );
  }

  /// Metni, taban çizgisinin sol ucu `tabanSol`a gelecek biçimde yazar.
  void _yaz(Canvas canvas, String metin, Offset tabanSol, Color renk) {
    final cizer = TextPainter(
      text: TextSpan(text: metin, style: Yazi.olcu(11, satir: 1.2, renk: renk)),
      textDirection: TextDirection.ltr,
    )..layout();
    final taban = cizer.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    cizer.paint(canvas, Offset(tabanSol.dx, tabanSol.dy - taban));
    cizer.dispose();
  }

  @override
  bool shouldRepaint(_GrafikCizici oldDelegate) => true;
}
```

```dart title=lib/ekranlar/kurulum/kart_sagligi_bolumu.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/kicker.dart';
import '../../mantik/kurulum.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// KART SAĞLIĞI: en düşük pilli 8 kart; pili düşük olan satır vurgulanır.
class KartSagligiBolumu extends StatelessWidget {
  const KartSagligiBolumu({super.key, required this.depo});

  final EtkinlikDeposu depo;

  @override
  Widget build(BuildContext context) {
    final satirlar = kartSagligi(depo.kisiler);
    final sorunlu = sorunluKartSayisi(depo.kisiler);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Kart sağlığı'),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${depo.duyulanKartSayisi}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: ' kart duyuluyor · '),
              TextSpan(
                text: '⚠ $sorunlu sorunlu',
                style: const TextStyle(color: Renkler.ciddi),
              ),
            ],
          ),
          style: Yazi.olcu(14),
        ),
        const SizedBox(height: 8),
        for (final satir in satirlar) _SaglikSatiriGorunumu(satir: satir),
      ],
    );
  }
}

/// Sütunlar: kart no (40) · kişi/kurum (esnek) · durum · pil (48, sağa yaslı).
class _SaglikSatiriGorunumu extends StatelessWidget {
  const _SaglikSatiriGorunumu({required this.satir});

  final SaglikSatiri satir;

  @override
  Widget build(BuildContext context) {
    final durumRengi = satir.sorunlu ? Renkler.ciddi : Renkler.metin2;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: satir.sorunlu ? Renkler.ciddiZemin : null,
        border: const Border(bottom: BorderSide(color: Renkler.ayrac)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(satir.kart, style: Yazi.olcu(14, agirlik: FontWeight.w600, rakam: true)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                satir.kisi,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Yazi.olcu(14, renk: satir.adsiz ? Renkler.metin2 : Renkler.metin),
              ),
            ),
            const SizedBox(width: 10),
            Text(satir.durum, style: Yazi.olcu(13, renk: durumRengi)),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              child: Text(
                '%${satir.pil}',
                textAlign: TextAlign.right,
                style: Yazi.olcu(14, renk: durumRengi, rakam: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart title=lib/ekranlar/kurulum/kurulum_ekrani.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';
import 'esik_bolumu.dart';
import 'kart_sagligi_bolumu.dart';
import 'sinyal_grafigi.dart';

/// Kurulum sekmesi: eşik, canlı sinyal, kalibrasyon, kart sağlığı.
class KurulumEkrani extends StatelessWidget {
  const KurulumEkrani({super.key, required this.depo});

  final EtkinlikDeposu depo;

  static const double _bolumAraligi = 28;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: depo,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text('Kurulum', style: Yazi.baslik(26, 1.1)),
              ),
              const SizedBox(height: 4),
              Text(
                'Teknik ekran — eşik ayarı, sinyaller ve kart sağlığı. Etkinlik öncesi kullanılır.',
                style: Yazi.olcu(14, renk: Renkler.metin2),
              ),
              const SizedBox(height: _bolumAraligi),
              EsikBolumu(depo: depo),
              const SizedBox(height: _bolumAraligi),
              SinyalBolumu(depo: depo),
              const SizedBox(height: _bolumAraligi),
              const _Kalibrasyon(),
              const SizedBox(height: _bolumAraligi),
              KartSagligiBolumu(depo: depo),
            ],
          ),
        );
      },
    );
  }
}

class _Kalibrasyon extends StatelessWidget {
  const _Kalibrasyon();

  @override
  Widget build(BuildContext context) {
    final dugmeYazisi = Yazi.olcu(14, agirlik: FontWeight.w600, satir: 1.2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Kalibrasyon'),
        const SizedBox(height: 8),
        Text(
          'Elinizdeki iki kartın çiftini seçin. Çift listede yoksa kartlar açık mı, alıcı duyuyor mu '
          'kontrol edin.',
          style: Yazi.olcu(14),
        ),
        const SizedBox(height: 10),
        // Kalibrasyon sihirbazı tasarlanmadı (şartname §2).
        HapDugme(
          etiket: '— çift seçin —',
          yukseklik: 48,
          genis: true,
          zemin: Renkler.yuzey,
          onTap: islevsiz,
          icerik: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('— çift seçin —', style: dugmeYazisi),
              Text('⌄', style: dugmeYazisi),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (164 + 10 = 174 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 13: Kurulum ekranı — eşik, canlı sinyal grafiği, kalibrasyon, kart sağlığı

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 14: Rapor ekranı

**Files:**
- Create: `lib/ekranlar/rapor/rapor_ekrani.dart`
- Test: `test/ekranlar/rapor_ekrani_test.dart`

**Interfaces:**
- Consumes: `EtkinlikDeposu` (Task 5); `raporKpileri`, `raporSatirlari`, `Kpi`, `RaporSatiri` (Task 4); `baslik`, `altAd` (Task 2); `HapDugme`, `islevsiz`, `Kicker` (Task 7).
- Produces: `RaporEkrani({required EtkinlikDeposu depo})`

- [ ] **Step 1: Başarısız testi yaz**

```dart title=test/ekranlar/rapor_ekrani_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/ekranlar/rapor/rapor_ekrani.dart';
import 'package:yakinlik_mobil/tema/renkler.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

Future<EtkinlikDeposu> _kur(WidgetTester tester) async {
  telefonBoyutu(tester);
  final depo = EtkinlikDeposu();
  addTearDown(depo.dispose);
  await tester.pumpWidget(temali(RaporEkrani(depo: depo)));
  return depo;
}

void main() {
  testWidgets('başlık ve düğmeler', (tester) async {
    await _kur(tester);
    expect(find.text('ETKİNLİK RAPORU'), findsOneWidget);
    expect(find.text('Yatırımcı Buluşması'), findsOneWidget);
    expect(find.text('28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 15:10'), findsOneWidget);
    expect(find.text('Yazdır / PDF'), findsOneWidget);
    expect(find.text('⤓ Katılımcılar'), findsOneWidget);
    expect(find.text('⤓ Görüşmeler'), findsOneWidget);
    expect(find.text('Yenile'), findsOneWidget);
  });

  testWidgets('beş KPI', (tester) async {
    await _kur(tester);
    expect(find.text('Görüşme'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('10 tanesi sürüyor'), findsOneWidget);
    expect(find.text('Yatırımcı–girişimci toplam'), findsOneWidget);
    expect(find.text('8 dk 42 sn'), findsOneWidget);
    expect(find.text('bugün'), findsOneWidget);
    expect(find.text('Yatırımcıya ulaşan girişimci'), findsOneWidget);
    expect(find.text('10/12'), findsOneWidget);
    expect(find.text('Potansiyel anlaşma'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('işaretlenmedi'), findsOneWidget);
    expect(find.text('Katılımcı'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('kayıtlı'), findsOneWidget);
  });

  testWidgets('girişimci satırları', (tester) async {
    await _kur(tester);
    expect(find.text('Girişimciler ve ulaştıkları yatırımcılar'), findsOneWidget);
    expect(find.text('Peak Enerji · İrem Korkmaz'), findsOneWidget);
    expect(find.text('1 dk 14 sn'), findsOneWidget);
    expect(find.text('Emre Kaya (1 dk 14 sn)'), findsOneWidget);
    expect(find.text('Veri Köprüsü · Can Yıldız'), findsOneWidget);
    expect(find.text('⚠ Hiç yatırımcıyla görüşmedi'), findsNWidgets(2));
    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('görüşmemiş girişimcinin detayı ciddi renktedir', (tester) async {
    await _kur(tester);
    final gorusmedi = tester.widget<Text>(find.text('⚠ Hiç yatırımcıyla görüşmedi').first);
    expect(gorusmedi.style!.color, Renkler.ciddi);
    final gorustu = tester.widget<Text>(find.text('Emre Kaya (1 dk 14 sn)'));
    expect(gorustu.style!.color, Renkler.metinKoyu2);
  });

  testWidgets('süreler ve hazırlanma saati akar', (tester) async {
    final depo = await _kur(tester);
    for (var i = 0; i < 60; i++) {
      depo.ilerlet();
    }
    await tester.pump();
    expect(find.text('18 dk 42 sn'), findsOneWidget); // 522 + 10 × 60 sn
    expect(find.text('2 dk 14 sn'), findsOneWidget);
    expect(find.text('28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 15:11'), findsOneWidget);
  });

  testWidgets('uzun oturum: saatli süreler yazılır, KPI kartı taşmaz', (tester) async {
    final depo = await _kur(tester);
    for (var i = 0; i < 4000; i++) {
      depo.ilerlet();
    }
    await tester.pump();
    expect(find.text('11 sa 15 dk'), findsOneWidget); // 522 + 10 × 4000 sn
    expect(find.text('1 sa 8 dk'), findsNWidgets(7)); // ör. 74 + 4000 sn
    expect(find.text('1 sa 7 dk'), findsNWidgets(3)); // ör. 19 + 4000 sn
    expect(find.text('28.09.2026 · Demo Salonu · Hazırlanma: 02.10.2026 16:16'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('düğmeler işlevsizdir: dokununca hiçbir şey değişmez', (tester) async {
    await _kur(tester);
    for (final etiket in ['Yazdır / PDF', '⤓ Katılımcılar', '⤓ Görüşmeler', 'Yenile']) {
      await tester.tap(find.text(etiket));
      await tester.pump();
    }
    expect(find.text('8 dk 42 sn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Testin düştüğünü gör**

```bash
flutter test test/ekranlar/rapor_ekrani_test.dart
```

Beklenen: derleme hatası — `rapor_ekrani.dart` için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/rapor/rapor_ekrani.dart
import 'package:flutter/widgets.dart';

import '../../bilesenler/hap_dugme.dart';
import '../../bilesenler/kicker.dart';
import '../../mantik/kisi_gorunum.dart';
import '../../mantik/rapor.dart';
import '../../tema/olculer.dart';
import '../../tema/renkler.dart';
import '../../tema/yazi.dart';
import '../../veri/etkinlik_deposu.dart';

/// Rapor sekmesi: başlık, düğmeler, 5 KPI ve girişimci satırları.
class RaporEkrani extends StatelessWidget {
  const RaporEkrani({super.key, required this.depo});

  final EtkinlikDeposu depo;

  static const double _bolumAraligi = 24;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: depo,
      builder: (context, _) {
        final kpiler = raporKpileri(depo.kisiler, depo.tick, kayitli: depo.kayitliKatilimci);
        final satirlar = raporSatirlari(depo.kisiler, depo.tick, depo.bul);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 10, Olculer.sayfaKenari, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Kicker('Etkinlik raporu'),
              const SizedBox(height: 4),
              Semantics(
                header: true,
                child: Text(depo.etkinlikAdi, style: Yazi.baslik(26, 1.1)),
              ),
              const SizedBox(height: 6),
              Text(
                '${depo.tarihMekan} · Hazırlanma: ${depo.raporTarihi} ${depo.saatKisa}',
                style: Yazi.olcu(14, renk: Renkler.metin2),
              ),
              const SizedBox(height: _bolumAraligi),
              // Yazdırma ve dışa aktarma ekranları tasarlanmadı (şartname §2).
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HapDugme(etiket: 'Yazdır / PDF', tur: HapTuru.birincil, onTap: islevsiz),
                  HapDugme(etiket: '⤓ Katılımcılar', onTap: islevsiz),
                  HapDugme(etiket: '⤓ Görüşmeler', onTap: islevsiz),
                  HapDugme(etiket: 'Yenile', tur: HapTuru.hayalet, onTap: islevsiz),
                ],
              ),
              const SizedBox(height: _bolumAraligi),
              _KpiIzgarasi(kpiler: kpiler),
              const SizedBox(height: _bolumAraligi),
              Semantics(
                header: true,
                child: Text('Girişimciler ve ulaştıkları yatırımcılar', style: Yazi.baslik(18, 1.2)),
              ),
              const SizedBox(height: 8),
              for (final satir in satirlar) _RaporSatiriGorunumu(satir: satir),
            ],
          ),
        );
      },
    );
  }
}

/// 2 sütunlu KPI ızgarası; aynı satırdaki kartlar eşit yüksekliktedir.
class _KpiIzgarasi extends StatelessWidget {
  const _KpiIzgarasi({required this.kpiler});

  final List<Kpi> kpiler;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kpiler.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _KpiKarti(kpi: kpiler[i])),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < kpiler.length ? _KpiKarti(kpi: kpiler[i + 1]) : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _KpiKarti extends StatelessWidget {
  const _KpiKarti({required this.kpi});

  final Kpi kpi;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Renkler.yuzey, borderRadius: Olculer.koseYaricap),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kpi.ad, style: Yazi.olcu(13, renk: Renkler.metin2)),
            const SizedBox(height: 4),
            // Uzun süreler ("11 sa 15 dk") alt satıra kırılmasın: sığmazsa küçülür.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                kpi.deger,
                maxLines: 1,
                style: Yazi.olcu(28, agirlik: FontWeight.w600, satir: 1, rakam: true),
              ),
            ),
            const SizedBox(height: 4),
            Text(kpi.not, style: Yazi.olcu(12, renk: Renkler.metin2)),
          ],
        ),
      ),
    );
  }
}

/// Bir girişimci: renk karesi, kurum · ad, toplam süre; altında detay.
class _RaporSatiriGorunumu extends StatelessWidget {
  const _RaporSatiriGorunumu({required this.satir});

  final RaporSatiri satir;

  @override
  Widget build(BuildContext context) {
    final kisi = satir.kisi;
    final alt = altAd(kisi);
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Renkler.ayrac)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Renkler.kisi(kisi.renk),
                      borderRadius: const BorderRadius.all(Radius.circular(1)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: baslik(kisi),
                      children: [
                        if (alt.isNotEmpty)
                          TextSpan(
                            text: ' $alt',
                            style: const TextStyle(fontWeight: FontWeight.w400, color: Renkler.metin2),
                          ),
                      ],
                    ),
                    style: Yazi.olcu(15, agirlik: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(satir.toplam, style: Yazi.olcu(15, renk: Renkler.metinKoyu2, rakam: true)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              satir.detay,
              style: Yazi.olcu(14, renk: satir.gorusmedi ? Renkler.ciddi : Renkler.metinKoyu2),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (174 + 7 = 181 test) ve `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Adım 14: Rapor ekranı — KPI kartları ve girişimci satırları

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 15: Kabuk, uygulama ve birleştirme

**Files:**
- Create: `lib/ekranlar/kabuk.dart`, `lib/uygulama.dart`
- Modify: `lib/main.dart` (geçici içerik son hâliyle değişir)
- Test: `test/ekranlar/kabuk_test.dart`, `test/ekranlar/tasma_test.dart`

**Interfaces:**
- Consumes: `PanoEkrani`, `PanoDurumu` (Task 8–9); `kisiDetayiGoster`, `DetayEylemi` (Task 10); `KartVerDurumu`, `KartVerEkrani` (Task 11–12); `KurulumEkrani` (Task 13); `RaporEkrani` (Task 14); `EtkinlikDeposu` (Task 5); `yakinlikTemasi` (Task 6).
- Produces:
  - `Kabuk({EtkinlikDeposu? depo})` — depo verilmezse kendi deposunu kurar ve saati başlatır
  - `KopukBandi()`
  - `YakinlikUygulamasi({EtkinlikDeposu? depo})` — `static const double enBuyukYaziOlcegi = 1.3`

- [ ] **Step 1: Başarısız testleri yaz**

```dart title=test/ekranlar/kabuk_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/bilesenler/basili_opaklik.dart';
import 'package:yakinlik_mobil/ekranlar/kabuk.dart';
import 'package:yakinlik_mobil/ekranlar/kisi_detayi/kisi_detay_sayfasi.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

// Not: Kart Ver adım 2'de Nabız sonsuz animasyondur; o adım açıkken
// pumpAndSettle KULLANILMAZ.

const _cem = 'Nova Robotik · Cem Erdem';
const _bantMetni = '⚠ Sunucuya bağlanılamıyor, yeniden deneniyor… son veri gösteriliyor';

Future<EtkinlikDeposu> _baslat(WidgetTester tester, {bool aliciBagli = true}) async {
  telefonBoyutu(tester);
  final depo = EtkinlikDeposu(aliciBagli: aliciBagli);
  addTearDown(depo.dispose);
  await tester.pumpWidget(YakinlikUygulamasi(depo: depo));
  await tester.pump();
  return depo;
}

Finder _sekme(String ad) =>
    find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

int _seciliSekme(WidgetTester tester) =>
    tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex;

void main() {
  testWidgets('açılış: Pano ve dört sekme', (tester) async {
    await _baslat(tester);
    expect(find.text('Yatırımcı Buluşması'), findsOneWidget);
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    for (final ad in ['Pano', 'Kart Ver', 'Kurulum', 'Rapor']) {
      expect(_sekme(ad), findsOneWidget, reason: ad);
    }
    expect(_seciliSekme(tester), 0);
  });

  testWidgets('sekmeler arasında gezinme', (tester) async {
    await _baslat(tester);
    await tester.tap(_sekme('Kart Ver'));
    await tester.pump();
    expect(find.text('Karşılama masası — gelen kişiye kart verin'), findsOneWidget);
    await tester.tap(_sekme('Kurulum'));
    await tester.pump();
    expect(find.text('EŞİK'), findsOneWidget);
    await tester.tap(_sekme('Rapor'));
    await tester.pump();
    expect(find.text('ETKİNLİK RAPORU'), findsOneWidget);
    await tester.tap(_sekme('Pano'));
    await tester.pump();
    expect(find.text('GİRİŞİMCİLER'), findsOneWidget);
    expect(_seciliSekme(tester), 0);
  });

  testWidgets('sekme değişince ekran durumu korunur', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text('Yatırımcı'));
    await tester.pump();
    await tester.tap(_sekme('Rapor'));
    await tester.pump();
    await tester.tap(_sekme('Pano'));
    await tester.pump();
    expect(find.text('YATIRIMCILAR'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(10));
  });

  testWidgets("eşik etiketi Kurulum sekmesine geçirir", (tester) async {
    await _baslat(tester);
    await tester.tap(find.text('Eşik −72 dBm'));
    await tester.pump();
    expect(_seciliSekme(tester), 2);
    expect(find.text('EŞİK'), findsOneWidget);
  });

  testWidgets('kişiye dokununca detay açılır; ✕ ile kapanır, sekme değişmez', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text(_cem));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsOneWidget);
    expect(find.text('Kartı değiştir'), findsOneWidget);
    await tester.tap(find.text('✕'));
    await tester.pumpAndSettle();
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(_seciliSekme(tester), 0);
  });

  testWidgets('detay → Kartı değiştir: Kart Ver sekmesi, adım 2, kişi seçili', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text(_cem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kartı değiştir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // sayfanın kapanma animasyonu
    expect(find.byType(KisiDetaySayfasi), findsNothing);
    expect(_seciliSekme(tester), 1);
    expect(find.text('Kişi: $_cem'), findsOneWidget);
    expect(find.text('Kartı alıcıya yaklaştırın…'), findsOneWidget);
  });

  testWidgets('detay → Kartı iade al: Kart İadesi, kişi seçili', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text(_cem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kartı iade al'));
    await tester.pumpAndSettle();
    expect(_seciliSekme(tester), 1);
    expect(find.text('Kart İadesi'), findsOneWidget);
    expect(find.text('Kart 24 iade alınsın mı?'), findsOneWidget);
  });

  testWidgets('bildirimden ve ağdan kişi detayı açılır', (tester) async {
    await _baslat(tester);
    await tester.tap(find.text('Bildirimler'));
    await tester.pump();
    await tester.tap(find.text('Kart kayboldu'));
    await tester.pumpAndSettle();
    expect(find.text('Kaan Öztürk'), findsOneWidget);
    expect(find.text('Yatırımcı · ★★★'), findsOneWidget);
    await tester.tap(find.text('✕'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ağ'));
    await tester.pump();
    await tester.tap(find.text('Nova Robotik'));
    await tester.pumpAndSettle();
    expect(find.text(_cem), findsOneWidget);
  });

  testWidgets('saat: dışarıdan verilen depo ilerleyince ekran güncellenir', (tester) async {
    final depo = await _baslat(tester);
    depo.ilerlet();
    await tester.pump();
    expect(find.text('15:10:10'), findsOneWidget);
  });

  testWidgets('saat: kendi deposuyla açılınca kendiliğinden akar', (tester) async {
    telefonBoyutu(tester);
    await tester.pumpWidget(const YakinlikUygulamasi());
    await tester.pump();
    expect(find.text('15:10:09'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('15:10:11'), findsOneWidget);
  });

  testWidgets('alıcı bağlıyken kopuk bandı yok', (tester) async {
    await _baslat(tester);
    expect(find.byType(KopukBandi), findsNothing);
    expect(find.text('● Alıcı bağlı'), findsOneWidget);
  });

  testWidgets('alıcı kopukken bant her sekmede görünür; son veri gösterilmeye devam eder', (tester) async {
    await _baslat(tester, aliciBagli: false);
    expect(find.text(_bantMetni), findsOneWidget);
    expect(find.text('● Alıcı yok'), findsOneWidget);
    expect(find.byType(BasiliOpaklik), findsNWidgets(12));
    await tester.tap(_sekme('Rapor'));
    await tester.pump();
    expect(find.text(_bantMetni), findsOneWidget);
    expect(find.text('8 dk 42 sn'), findsOneWidget);
  });

  testWidgets('sistem yazı ölçeği 1.3 ile sınırlanır', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _baslat(tester);
    final olcek = MediaQuery.textScalerOf(tester.element(find.byType(Kabuk)));
    expect(olcek.scale(10), closeTo(13, 1e-6));
  });

  testWidgets('yerel Türkçe: yerleşik Material metinleri Türkçe', (tester) async {
    await _baslat(tester);
    final baglam = tester.element(find.byType(Kabuk));
    expect(Localizations.localeOf(baglam).languageCode, 'tr');
    expect(MaterialLocalizations.of(baglam).pasteButtonLabel, 'Yapıştır');
  });
}
```

```dart title=test/ekranlar/tasma_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

import '../yardimci.dart';

// Her ekran ve durum, farklı telefon genişliklerinde ve en büyük yazı
// ölçeğinde taşmadan çizilmelidir. Flutter'da taşma (RenderFlex overflow) bir
// hata olarak raporlanır; `tester.takeException()` onu yakalar.
//
// 360 px: şartnamedeki 390–430 aralığının altındaki yaygın Android genişliği.
// Ölçek 2.0: uygulama bunu 1.3'e sınırlar.

const _genislikler = [360.0, 390.0, 402.0, 430.0];
const _olcekler = [1.0, 2.0];

void main() {
  for (final genislik in _genislikler) {
    for (final olcek in _olcekler) {
      testWidgets('taşma yok: ${genislik.round()} px, sistem yazı ölçeği $olcek', (tester) async {
        telefonBoyutu(tester, genislik: genislik, yukseklik: 800);
        tester.platformDispatcher.textScaleFactorTestValue = olcek;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final depo = EtkinlikDeposu();
        addTearDown(depo.dispose);
        await tester.pumpWidget(YakinlikUygulamasi(depo: depo));

        Future<void> denetle(String neresi) async {
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$neresi (${genislik.round()} px, ölçek $olcek)');
        }

        Future<void> dokun(Finder hedef) async {
          await tester.ensureVisible(hedef);
          await tester.pump();
          await tester.tap(hedef);
          await tester.pump();
        }

        Finder sekme(String ad) =>
            find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

        await denetle('Pano · Kişiler');
        await dokun(find.text('Tümü'));
        await denetle('Pano · Tümü filtresi');
        await dokun(find.text('Ağ'));
        await denetle('Pano · Ağ');
        await dokun(find.text('Bildirimler'));
        await denetle('Pano · Bildirimler');

        await dokun(find.text('Kart kayboldu'));
        await tester.pumpAndSettle();
        await denetle('Kişi Detayı');
        await tester.tap(find.text('✕'));
        await tester.pumpAndSettle();

        await tester.tap(sekme('Kart Ver'));
        await denetle('Kart Ver · adım 1');
        await dokun(find.text('Nova Robotik · Cem Erdem'));
        await denetle('Kart Ver · adım 2 (bekleme)');
        await dokun(find.text('Demo: boş bir kartı yaklaştır'));
        await tester.pump(const Duration(milliseconds: 1500));
        await denetle('Kart Ver · kart bulundu');
        await dokun(find.text('Numarayı yaz'));
        await denetle('Kart Ver · numara');
        await tester.enterText(find.byType(TextField), '14');
        await denetle('Kart Ver · numara yazıldı');
        await dokun(find.text('Bu kartı seç'));
        await denetle('Kart Ver · adım 3');
        await dokun(find.text('Onayla'));
        await denetle('Kart Ver · son atama bandı');
        await dokun(find.text('↶ Geri al'));
        await denetle('Kart Ver · bilgi bandı');
        await dokun(find.text('Kart iadesi'));
        await denetle('Kart İadesi');
        await dokun(find.text('Nova Robotik · Cem Erdem'));
        await denetle('Kart İadesi · onay kutusu');

        await tester.tap(sekme('Kurulum'));
        await denetle('Kurulum');
        depo.esikAyarla(-95);
        await denetle('Kurulum · eşik −95');

        await tester.tap(sekme('Rapor'));
        await denetle('Rapor');

        // Uzun oturum: bir saati aşan süreler de taşmamalı.
        for (var i = 0; i < 4000; i++) {
          depo.ilerlet();
        }
        await denetle('Rapor · uzun oturum');
        await tester.tap(sekme('Pano'));
        await dokun(find.text('Kişiler'));
        await denetle('Pano · uzun oturum');
      });
    }
  }
}
```

- [ ] **Step 2: Testlerin düştüğünü gör**

```bash
flutter test test/ekranlar/kabuk_test.dart test/ekranlar/tasma_test.dart
```

Beklenen: derleme hatası — `lib/ekranlar/kabuk.dart` ve `lib/uygulama.dart` için `No such file or directory`.

- [ ] **Step 3: Kodu yaz**

```dart title=lib/ekranlar/kabuk.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/olculer.dart';
import '../tema/renkler.dart';
import '../tema/yazi.dart';
import '../veri/etkinlik_deposu.dart';
import 'kart_ver/kart_ver_durumu.dart';
import 'kart_ver/kart_ver_ekrani.dart';
import 'kisi_detayi/kisi_detay_sayfasi.dart';
import 'kurulum/kurulum_ekrani.dart';
import 'pano/pano_durumu.dart';
import 'pano/pano_ekrani.dart';
import 'rapor/rapor_ekrani.dart';

/// Uygulamanın kabuğu: dört sekme, alıcı kopuk bandı ve Kişi Detayı.
class Kabuk extends StatefulWidget {
  const Kabuk({super.key, this.depo});

  /// Testlerde dışarıdan verilir (saat testin denetiminde olur). Verilmezse
  /// Kabuk kendi deposunu kurar, saati başlatır ve kapanırken bırakır.
  final EtkinlikDeposu? depo;

  @override
  State<Kabuk> createState() => _KabukState();
}

class _KabukState extends State<Kabuk> {
  static const int _sekmeKartVer = 1;
  static const int _sekmeKurulum = 2;

  late final EtkinlikDeposu _depo;
  late final PanoDurumu _panoDurumu;
  late final KartVerDurumu _kartVerDurumu;
  int _sekme = 0;

  @override
  void initState() {
    super.initState();
    _depo = widget.depo ?? (EtkinlikDeposu()..baslat());
    _panoDurumu = PanoDurumu();
    _kartVerDurumu = KartVerDurumu(_depo);
  }

  @override
  void dispose() {
    _kartVerDurumu.dispose();
    _panoDurumu.dispose();
    if (widget.depo == null) _depo.dispose();
    super.dispose();
  }

  void _sekmeSec(int sekme) {
    // Gizlenen sekmedeki girdinin klavyesi açık kalmasın.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _sekme = sekme);
  }

  Future<void> _kisiDetayiAc(String kisiId) async {
    final eylem = await kisiDetayiGoster(context, depo: _depo, kisiId: kisiId);
    if (!mounted || eylem == null) return;
    switch (eylem) {
      case DetayEylemi.kartDegistir:
        _kartVerDurumu.kartDegistirBaslat(kisiId);
      case DetayEylemi.kartIade:
        _kartVerDurumu.iadeBaslat(kisiId);
    }
    _sekmeSec(_sekmeKartVer);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Krem zemin üstünde koyu durum çubuğu simgeleri.
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (!_depo.aliciBagli) const KopukBandi(),
              Expanded(
                // Sekme değişince ekran durumu ve kaydırma konumu korunur.
                child: IndexedStack(
                  index: _sekme,
                  children: [
                    PanoEkrani(
                      depo: _depo,
                      durum: _panoDurumu,
                      onKisi: _kisiDetayiAc,
                      onKurulumaGit: () => _sekmeSec(_sekmeKurulum),
                    ),
                    KartVerEkrani(depo: _depo, durum: _kartVerDurumu),
                    KurulumEkrani(depo: _depo),
                    RaporEkrani(depo: _depo),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _sekme,
          onTap: _sekmeSec,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Pano'),
            BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: 'Kart Ver'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Kurulum'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Rapor'),
          ],
        ),
      ),
    );
  }
}

/// Alıcı kopukken en üstte görünen bant. Veri silinmez; son veri gösterilir.
class KopukBandi extends StatelessWidget {
  const KopukBandi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Olculer.sayfaKenari, 4, Olculer.sayfaKenari, 0),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Renkler.ciddiZemin, borderRadius: Olculer.koseYaricap),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text.rich(
              TextSpan(
                text: '⚠ Sunucuya bağlanılamıyor, yeniden deneniyor… ',
                children: [
                  TextSpan(
                    text: 'son veri gösteriliyor',
                    style: TextStyle(color: Renkler.ciddiKoyu.withValues(alpha: 0.75)),
                  ),
                ],
              ),
              style: Yazi.olcu(13, renk: Renkler.ciddiKoyu),
            ),
          ),
        ),
      ),
    );
  }
}
```

```dart title=lib/uygulama.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ekranlar/kabuk.dart';
import 'tema/tema.dart';
import 'veri/etkinlik_deposu.dart';

/// Uygulamanın kökü: tema, Türkçe yerel, yazı ölçeği sınırı.
class YakinlikUygulamasi extends StatelessWidget {
  const YakinlikUygulamasi({super.key, this.depo});

  /// Testlerde dışarıdan verilir; verilmezse Kabuk kendi deposunu kurar.
  final EtkinlikDeposu? depo;

  /// Sistem yazı ölçeği bu aralığa sınırlanır (sıkışık satırlar taşmasın).
  static const double enKucukYaziOlcegi = 1;
  static const double enBuyukYaziOlcegi = 1.3;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yakınlık Panosu',
      debugShowCheckedModeBanner: false,
      theme: yakinlikTemasi(),
      themeMode: ThemeMode.light,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: enKucukYaziOlcegi,
        maxScaleFactor: enBuyukYaziOlcegi,
        child: child!,
      ),
      home: Kabuk(depo: depo),
    );
  }
}
```

`lib/main.dart`'ın geçici içeriğini son hâliyle değiştir:

```dart title=lib/main.dart
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'uygulama.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Tasarım dikey telefon içindir (390–430 px genişlik).
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const YakinlikUygulamasi());
}
```

- [ ] **Step 4: Testler geçsin**

```bash
flutter test && flutter analyze
```

Beklenen: `All tests passed!` (181 + 14 + 8 = 203 test) ve `No issues found!`

Bir taşma testi düşerse hata iletisindeki `reason` hangi ekranda ve hangi genişlikte olduğunu söyler. Düzeltme, o satırdaki sabit genişlikli çocuğu `Flexible`/`Expanded` içine almak ya da metne `maxLines` + `overflow` vermektir; ölçüleri (Ek A) değiştirme.

- [ ] **Step 5: Uygulamayı çalıştırıp gözle doğrula**

```bash
xcrun simctl boot "iPhone 17 Pro" 2>/dev/null; open -a Simulator
flutter run -d "iPhone 17 Pro"
```

Beklenen: uygulama Pano ile açılır, saat 15:10:09'dan akar, dört sekme gezilebilir. `q` ile çık.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Adım 15: Kabuk ve uygulama — dört sekme, kopuk bandı, detay kısayolları, Türkçe yerel

Tüm ekranlar 360/390/402/430 px genişlikte ve en büyük yazı ölçeğinde
taşmadan çiziliyor (tasma_test).

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 16: Görsel doğrulama, README ve teslim

**Files:**
- Create: `integration_test/ekran_goruntuleri_test.dart`, `test_driver/integration_test.dart`, `docs/teslim/NOT.md`, `docs/teslim/ekran/…` (ekran görüntüleri)
- Modify: `README.md` (şablonun yerine)

**Interfaces:**
- Consumes: `YakinlikUygulamasi`, `EtkinlikDeposu` (önceki görevler).
- Produces: teslim belgeleri ve ekran görüntüleri; kod arayüzü üretmez.

- [ ] **Step 1: Ekran görüntüsü testini ve sürücüsünü yaz**

```dart title=integration_test/ekran_goruntuleri_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yakinlik_mobil/uygulama.dart';
import 'package:yakinlik_mobil/veri/etkinlik_deposu.dart';

/// Her ekranın ve durumun görüntüsünü alır: `docs/teslim/ekran/<platform>/`.
/// Depo dışarıdan verilir; saat akmaz, görüntüler tekrarlanabilir olur.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = Platform.isIOS ? 'ios' : 'android';

  Finder sekme(String ad) =>
      find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(ad));

  testWidgets('tüm ekranlar', (tester) async {
    await tester.pumpWidget(YakinlikUygulamasi(depo: EtkinlikDeposu(aliciBagli: true)));
    await tester.pump(const Duration(milliseconds: 600));
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();

    Future<void> bekle([int ms = 400]) => tester.pump(Duration(milliseconds: ms));

    Future<void> cek(String ad) async {
      await bekle();
      await binding.takeScreenshot('$platform/$ad');
    }

    Future<void> dokun(Finder hedef) async {
      await tester.ensureVisible(hedef);
      await bekle(150);
      await tester.tap(hedef);
      await bekle();
    }

    Future<void> asagiKaydir() async {
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -520));
      await bekle(600);
    }

    await cek('01_pano_kisiler');
    await dokun(find.text('Ağ'));
    await cek('02_pano_ag');
    await dokun(find.text('Bildirimler'));
    await cek('03_pano_bildirimler');
    await dokun(find.text('Kişiler'));
    await dokun(find.text('Nova Robotik · Cem Erdem'));
    await bekle(600);
    await cek('04_kisi_detayi');
    await dokun(find.text('✕'));
    await bekle(600);

    await tester.tap(sekme('Kart Ver'));
    await cek('05_kart_ver_adim1');
    await dokun(find.text('Nova Robotik · Cem Erdem'));
    await cek('06_kart_ver_bekleme');
    await dokun(find.text('Demo: boş bir kartı yaklaştır'));
    await bekle(1600);
    await cek('07_kart_ver_bulundu');
    await dokun(find.text('Numarayı yaz'));
    await cek('08_kart_ver_numara');
    await dokun(find.text('Kart 88'));
    await cek('09_kart_ver_kontrol');
    await dokun(find.text('Onayla'));
    await cek('10_kart_ver_son_atama');
    await dokun(find.text('Kart iadesi'));
    await dokun(find.text('Nova Robotik · Cem Erdem'));
    await cek('11_kart_iadesi_onay');

    await tester.tap(sekme('Kurulum'));
    await cek('12_kurulum_ust');
    await asagiKaydir();
    await cek('13_kurulum_alt');

    await tester.tap(sekme('Rapor'));
    await cek('14_rapor_ust');
    await asagiKaydir();
    await cek('15_rapor_alt');
  });

  testWidgets('alıcı kopuk', (tester) async {
    await tester.pumpWidget(YakinlikUygulamasi(depo: EtkinlikDeposu(aliciBagli: false)));
    await tester.pump(const Duration(milliseconds: 600));
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('$platform/16_pano_alici_kopuk');
  });
}
```

```dart title=test_driver/integration_test.dart
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Ekran görüntülerini docs/teslim/ekran/ altına yazar.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String ad, List<int> baytlar, [Map<String, Object?>? args]) async {
      final dosya = File('docs/teslim/ekran/$ad.png');
      dosya.createSync(recursive: true);
      dosya.writeAsBytesSync(baytlar);
      return true;
    },
  );
}
```

```bash
flutter analyze
```

Beklenen: `No issues found!`

- [ ] **Step 2: iPhone 17 Pro simülatöründe görüntüleri al**

```bash
xcrun simctl boot "iPhone 17 Pro" 2>/dev/null; open -a Simulator
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/ekran_goruntuleri_test.dart -d "iPhone 17 Pro"
ls docs/teslim/ekran/ios
```

Beklenen: `All tests passed!` ve 16 dosya (`01_pano_kisiler.png` … `16_pano_alici_kopuk.png`). İlk derleme birkaç dakika sürer.

- [ ] **Step 3: Prototiple yan yana karşılaştır ve farkları düzelt**

Prototipi yerelde sun ve tarayıcıda aç:

```bash
python3 -m http.server 8765 --directory docs/tasarim
# Tarayıcı: http://localhost:8765/Yakinlik%20Mobil.dc.html
```

Prototip 402 × 874 çerçevede açılır (iPhone 17 Pro ile aynı). 16 görüntünün her biri için prototipi aynı duruma getir ve şunları karşılaştır:

| Bak | Beklenen |
|---|---|
| Renkler | Zemin `#f7f2e9`, yüzey `#fffdf8`, vurgu `#9a6512`; birlikte satırı `#e0f2e4` |
| Yazı | Boyut ve ağırlık Ek A ile aynı; rakamlar titremiyor (eşit genişlik) |
| Boşluk | Yatay kenar 20; bölüm aralıkları Ek A ile aynı (±2 px) |
| Köşe | Kart/liste 12; düğme, çip, girdi, etiket hap; alt sayfa 20 |
| Simgeler | `● ⚠ ★ ✓ ↶ ✕ ← → ⤓ ⌄` tek renk ve yazı renginde; renkli emoji ya da boş kutu yok |
| Metin | Türkçe harfler (`İ ı ş ğ ç ö ü`) doğru; kicker'lar `GİRİŞİMCİLER` gibi |

Bilinçli farklar (hata değildir): şartname §3'teki S1–S17 (ör. çipler hap biçimli, "Görünmüyor" turuncu, sekme ikonları Material).

Bir simge renkli emoji ya da boş kutu çıkıyorsa, o simgeyi aynı boyut ve renkte Material ikonla değiştir (şartname §10): `⚠ → Icons.warning_amber_rounded`, `⤓ → Icons.file_download_outlined`, `⌄ → Icons.expand_more`, `↶ → Icons.undo`, `✕ → Icons.close`, `✓ → Icons.check`. İkon, metnin başına `WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(…, size: <punto>, color: <yazı rengi>))` ile konur; metinler ve testlerdeki `find.text` beklentileri buna göre güncellenir.

Her düzeltmeden sonra:

```bash
flutter test && flutter analyze
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/ekran_goruntuleri_test.dart -d "iPhone 17 Pro"
```

Fark kalmayınca sunucuyu kapat (`Ctrl+C`).

- [ ] **Step 4: Android duman testi (Pixel_8)**

```bash
flutter emulators --launch Pixel_8
flutter devices   # emulator-5554 görünene kadar bekle
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/ekran_goruntuleri_test.dart -d emulator-5554
ls docs/teslim/ekran/android
```

Beklenen: `All tests passed!` ve 16 dosya. Android görüntülerinde simgeleri (özellikle `⤓ ⌄ ↶`) ve Türkçe harfleri denetle; sorun varsa Step 3'teki ikon değişimini uygula.

Android araç zinciri çalışmazsa (lisans, Gradle, emülatör): `flutter doctor -v` çıktısındaki Android bölümünü teslim notuna aynen yaz ve bu adımı "yapılamadı" diye işaretle; uydurma sonuç yazma.

- [ ] **Step 5: README'yi yaz**

Şablonun `README.md`'sini şu içerikle değiştir:

````markdown
# Yakınlık Panosu — Mobil

SaasBridge "Yakınlık Panosu"nun saha görevlileri için telefon uygulaması (Flutter, iOS + Android).
Dört sekme: **Pano** (Kişiler · Ağ · Bildirimler), **Kart Ver / İade**, **Kurulum**, **Rapor**; artı **Kişi Detayı**.

Bu sürüm sunucuya bağlanmaz: tasarım prototipindeki gömülü sahte veriyle çalışır. Onayla, Geri al ve
İade al yalnız bant gösterir; veriyi değiştirmez.

## Çalıştırma

Gerekenler: Flutter 3.44.6 (Dart 3.12.2), iOS için Xcode, Android için Android SDK.

```bash
flutter pub get
flutter run                                    # açık simülatör/emülatörde
flutter run --dart-define=ALICI_BAGLI=false    # "alıcı kopuk" durumunu görmek için
flutter test                                   # birim + widget testleri
flutter analyze
```

Ekran görüntülerini yeniden almak için:

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/ekran_goruntuleri_test.dart -d "iPhone 17 Pro"
```

## Yapı

```
lib/
  tema/        renk token'ları, ölçüler, yazı stilleri, ThemeData
  veri/        modeller, sahte veri, EtkinlikDeposu (veriye tek erişim noktası)
  mantik/      saf Dart: biçimleme, süzme, yerleşim, rapor hesapları
  bilesenler/  ortak parçalar: hap düğme, çip, bölmeli anahtar, rol şekli…
  ekranlar/    kabuk, pano/, kisi_detayi/, kart_ver/, kurulum/, rapor/
test/          mantik/ ve veri/ (birim), bilesenler/ ve ekranlar/ (widget), mimari_test
```

Kurallar (`test/mimari_test.dart` denetler):
- Renk sabiti yalnız `lib/tema/` altında yazılır.
- `lib/mantik/` Flutter içe aktarmaz.
- Sahte veriye yalnız `EtkinlikDeposu` erişir. Gerçek sunucuya geçiş yalnız `lib/veri/` katmanını değiştirir.
- Yeşil yalnız "şu an birlikte" demektir.

## Belgeler

- Tasarım kaynağı: `docs/tasarim/` (README + HTML prototip)
- Şartname: `docs/superpowers/specs/2026-10-03-yakinlik-mobil-design.md`
- Uygulama planı: `docs/superpowers/plans/2026-10-03-yakinlik-mobil.md`
- Teslim notu ve ekran görüntüleri: `docs/teslim/`

## Bu sürümde olmayanlar

Sunucu bağlantısı · kişi düzenleme, kalibrasyon, PDF/CSV dışa aktarma (düğmeleri görünür ama işlevsiz) ·
koyu tema · 1b (Sade) varyantı · uygulama ikonu.
````

- [ ] **Step 6: Teslim notunu yaz**

Önce sayıları al:

```bash
flutter test 2>&1 | tail -1          # "All tests passed!" satırı ve test sayısı
flutter analyze 2>&1 | tail -1
ls docs/teslim/ekran/ios | wc -l
ls docs/teslim/ekran/android 2>/dev/null | wc -l
```

`docs/teslim/NOT.md`'yi şu içerikle oluştur. "Doğrulama" bölümündeki dört değeri yukarıdaki komutların **gerçek çıktısından** yaz; Android adımı yapılamadıysa satırını `yapılamadı: <neden>` diye yaz.

````markdown
# Teslim Notu — Yakınlık Panosu Mobil (1a Liste)

## Ne yapıldı

Tasarım teslim paketindeki 1a (Liste) varyantı Flutter ile yazıldı: Kabuk (4 sekme), Pano (Kişiler · Ağ ·
Bildirimler), Kişi Detayı (alt sayfa), Kart Ver (3 adımlı sihirbaz) ve Kart İadesi, Kurulum, Rapor.
Uygulama prototipteki gömülü sahte veriyle çalışır; sunucuya bağlanmaz.

Ekran görüntüleri: `docs/teslim/ekran/ios/` ve `docs/teslim/ekran/android/` (01–16).

## Neyi neden böyle yaptım

- **Katmanlar web reposuyla aynı.** `tema / veri / mantik / bilesenler / ekranlar`. Hesap ekranda değil
  `mantik/`'te; her kuralın birim testi var. Gerçek sunucuya geçiş yalnız `veri/` katmanını değiştirir.
- **Paket eklenmedi.** Grafik ve ağ çizgileri `CustomPaint`, durum `ChangeNotifier`. Uygulama çevrimdışı
  çalışır ve bağımlılık riski taşımaz.
- **README ile prototip ayrıştığında README'ye uyuldu** (şartname §3, S1–S17). Öne çıkanlar: çipler ve adım
  göstergesi hap biçimli; "Görünmüyor" uyarı renginde; süreler web kuralıyla (`1 dk`, `1 sa 16 dk`);
  prototipe broadsheet temasından sızan renkler web token'larıyla değiştirildi.
- **Dokunma hedefleri 44 px.** Etiket (28), çip (36) gibi küçük görsellerin ölçüsü değişmedi; dokunma alanı
  görünmez biçimde genişletildi. İstisna: Pano bölüm anahtarı (README: 40 px) ve Ağ satırları (30 px aralık).
- **Türkçe harf çevirisi elle yapıldı.** Dart'ın büyük/küçük harf çevirisi yerelsiz olduğu için arama
  (`İREM` → `irem`) ve kicker başlıkları (`GİRİŞİMCİLER`) kendi fonksiyonlarımızla çevrilir.
- **Taşma testle güvenceye alındı.** Her ekran 360 / 390 / 402 / 430 px genişlikte ve en büyük yazı
  ölçeğinde taşmadan çiziliyor. Sistem yazı ölçeği 1.3 ile sınırlı.
- **Prototipteki küçük hatalar düzeltildi.** Adsız kart `Kart 14` diye yazılır (prototipte boş/`null`);
  demo yaklaştırma beklerken geri dönülürse eski kart sonradan belirmez; eşik çizgisi grafiğin dışına taşmaz.

## Bilinçli olarak yapılmayanlar

- Onayla / Geri al / İade al sahte veriyi değiştirmez; yalnız bant gösterir (karar: yalnız prototip eşdeğeri).
- `Düzenle`, `— çift seçin —`, `Yazdır / PDF`, `⤓ Katılımcılar`, `⤓ Görüşmeler`, `Yenile` işlevsizdir;
  arkalarındaki ekranlar tasarlanmadı.
- 1b varyantı, koyu tema, sunucu bağlantısı, kalıcılık, uygulama ikonu.

## Doğrulama

| Denetim | Sonuç |
|---|---|
| `flutter test` | (komut çıktısındaki test sayısı ve sonuç) |
| `flutter analyze` | (komut çıktısı) |
| iOS (iPhone 17 Pro) ekran görüntüleri | (dosya sayısı) / 16 |
| Android (Pixel_8) ekran görüntüleri | (dosya sayısı) / 16 |

Prototiple yan yana karşılaştırmada bulunan ve düzeltilen farklar:

(Step 3'te bulunan her fark için bir madde: ekran — fark — düzeltme. Fark bulunmadıysa "Fark bulunmadı." yaz.)

## Sonraki adımlar

1. Gerçek sunucuya bağlanma: `/state`, `/events` (SSE), `/control`, `/api/*`; sunucu adresi ayarı.
2. İşlevsiz düğmelerin ekranları: kişi düzenleme, kalibrasyon sihirbazı, PDF/CSV.
3. Koyu tema; uygulama ikonu.
````

- [ ] **Step 7: Son doğrulama ve commit**

```bash
flutter test && flutter analyze
git add -A
git status --short | head -30
git commit -m "Adım 16: Görsel doğrulama, README ve teslim notu

- integration_test ile iOS (ve Android) ekran görüntüleri: docs/teslim/ekran/
- Prototiple yan yana karşılaştırma; bulunan farklar teslim notunda
- README: çalıştırma, yapı, kurallar

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git log --oneline
```

Beklenen: `All tests passed!`, `No issues found!` ve 16 "Adım N" commit'i (+ şartname ve plan commit'leri).
