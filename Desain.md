# Melody Sense — Design System v3 (Whisker-Inspired, Playful Penuh)

> Dokumen ini mendefinisikan **gaya visual** untuk Melody Sense, terinspirasi dari referensi deck "The Whisker Watch" (torn paper, sticker, halftone, comic-ink, hand-drawn). Level: **playful penuh**.
>
> ⚠️ **Yang TIDAK berubah:** palet warna resmi & layout/struktur aplikasi. Dokumen ini hanya mendefinisikan *skin*/treatment visual di atas struktur yang sudah ada — bukan restrukturisasi screen, bukan penggantian warna.
>
> 🔁 **v3 vs v2:** hasil implementasi terakhir (lihat Bagian 0) masih terlalu halus/rapi dibanding referensi — torn edge nyaris tak terlihat, sticker belum miring, belum ada halftone/stripe/ink-outline sama sekali. v3 memperjelas ukuran, angka, dan urutan prioritas supaya hasil build benar-benar terasa "playful penuh" seperti referensi, bukan sekadar rounded card biasa.

---

## 0. Gap Analysis — Kondisi Saat Ini vs Referensi vs Target

Perbandingan screenshot hasil build sekarang (card Dashboard) terhadap referensi "The Whisker Watch":

| Elemen | Referensi (Whisker Watch) | Kondisi Sekarang | Target v3 |
|---|---|---|---|
| Tepi kartu | Robekan besar, tidak beraturan, terlihat jelas dari jarak normal | Zig-zag nyaris rata, amplitudo sangat kecil, cuma terlihat kalau di-zoom | Amplitudo dinaikkan, dibuat **jelas terlihat tanpa zoom** (lihat 3.1) |
| Outline / garis | Tebal, tegas, terasa seperti spidol/kuas, sedikit tidak rata (hand-drawn) | Tipis, presisi, terasa seperti border digital biasa | Outline tebal 3px + jitter halus (lihat 3.4) |
| Badge / stiker | Bulat/oval, **miring**, outline tebal, terasa seperti stiker ditempel | Pill shape lurus, tidak miring, terasa seperti chip Material biasa | Wajib rotasi -6°~8°, outline tebal (lihat 3.2) |
| Judul section | Banner/pita robek putih di belakang teks tebal hitam | Teks biasa tanpa banner/outline apa pun | Banner robek + double outline (lihat 3.4) |
| Tekstur latar | Halftone dot & diagonal stripe dipakai di banyak tempat sebagai aksen | Tidak ada tekstur sama sekali, latar polos | Wajib minimal 1 aksen tekstur per card hero (lihat 3.3, 3.6) |
| Doodle/motif kecil | Ada ilustrasi kecil bertebaran (bintang, hantu, cakar) sebagai pengisi ruang kosong | Tidak ada elemen dekoratif kecil sama sekali | Motif musik kecil bertebaran secukupnya (lihat 3.8) |

**Kesimpulan:** dokumen v2 sudah benar arahnya, tapi angka/parameter yang dipakai terlalu konservatif sehingga saat diimplementasi hasilnya "hilang" jadi rounded card polos. v3 menaikkan angka minimum & menambah 2 elemen signature baru (banner judul, doodle motif) yang di referensi justru paling menentukan kesan "playful penuh"-nya.

---

## 1. Prinsip Utama

1. **Warna tetap 100% dari palet resmi** — tidak ada warna baru ditambahkan di luar 4 token + turunannya.
2. **Layout tidak berubah** — posisi card, urutan section, struktur bottom nav, grid Practice, dsb tetap seperti implementasi saat ini. Yang berubah hanya *cara render* elemen (border, shadow, tekstur, tipografi, ikon).
3. **Playful penuh, tapi tetap edukatif** — torn paper, sticker, halftone, banner robek dipakai luas dan **harus terlihat jelas tanpa perlu di-zoom**, tapi motif diganti dari horror (hantu, cakar, darah) menjadi musik (not balok, nada, gelombang suara, alat musik, bintang).
4. **Konsisten lintas mode** — treatment yang sama dipakai di Explorer (Teal accent lokal), Maestro (Indigo), Sense (Deep Orange) sebagai *tint* di atas base palette, bukan warna baru yang lepas dari sistem.
5. **Kalau ragu, lebih besar/lebih tebal, bukan lebih halus** — referensi terasa "penuh" karena robekan, outline, dan stiker semuanya berukuran cukup besar relatif ke card. Efek yang terlalu subtle akan hilang saat dirender di layar HP kecil.

---

## 2. Palet Warna (Sumber Kebenaran — TIDAK BERUBAH)

| Token | Hex | Kegunaan |
|---|---|---|
| Primary Dark | `#51508B` | Heading, tombol utama, ikon aktif, outline "ink" |
| Background | `#F2F5FF` | Latar layar |
| Surface Tint | `#D5D4FF` | Card ungu muda, progress track (belum terisi) |
| Accent | `#8197E5` | Highlight tuts aktif, progress fill, aksen interaktif |

**Turunan untuk kebutuhan style baru** (derivasi dari 4 token di atas, bukan warna baru):
- `Primary Dark @ 100%` → warna **outline/ink** pengganti hitam pekat di referensi — dipakai di SEMUA elemen bergaya comic-ink (torn edge, banner, sticker, divider).
- `Primary Dark @ 8–12% opacity` di atas Background → shadow halus di belakang elemen sobek (pengganti drop-shadow hitam).
- `Primary Dark @ 25–40% opacity` → warna dot halftone & garis stripe (lebih gelap dari turunan shadow supaya tekstur tetap kebaca, tidak hilang seperti sekarang).
- `Accent @ 100%` → warna **stiker/badge** utama (pengganti merah di referensi).
- `Surface Tint` → warna dasar torn-paper card & warna banner judul (pengganti hitam/gelap di referensi — dibalik karena tema Melody Sense terang, bukan gelap).
- `Background` → dipakai sebagai "kertas" torn paper itu sendiri saat card diletakkan di atas Surface Tint, dan sebaliknya.

> Aturan: kontras torn-paper selalu dibentuk dari **pasangan Background ↔ Surface Tint**, dengan outline **Primary Dark**, dan badge **Accent**. Tidak pernah keluar dari 4 warna ini.

---

## 3. Elemen Signature (diadaptasi dari referensi)

### 3.1 Torn Paper Card — **DIPERBESAR dari v2**
- Setiap card besar (mode card, session result card, hero header) punya **tepi sobek** yang jelas terlihat, minimal di 1 sisi (atas/bawah), idealnya di 2 sisi berlawanan untuk card hero (meniru foto robek di referensi).
- **Amplitudo zig-zag: 8–14px** (v2 memakai 4-8px yang ternyata hilang saat dirender — naikkan ke rentang ini sebagai minimum, bukan maksimum), lebar tiap gerigi 14–22px, sedikit acak per titik (jangan simetris sempurna, biar terasa hand-torn).
- Outline `Primary Dark` tebal **3px**, mengikuti kontur sobekan (bukan garis lurus di atas sobekan).
- Layer di belakangnya: kartu duplikat offset **4–6px** (naik dari 2-3px) warna Surface Tint sebagai "bayangan kertas" — efek kertas bertumpuk seperti di referensi. Rotasi kartu duplikat -1° s/d 1° supaya tidak terlihat sejajar sempurna dengan kartu utama.

### 3.2 Sticker Badge — **wajib miring, bukan opsional**
- Pengganti icon status kecil (mis. badge "Baru", jumlah XP, status ronde, Level) → bentuk **stiker bulat/oval miring -6° s/d 8°** (rotasi WAJIB diterapkan, ini yang paling sering hilang di implementasi), outline tebal 2.5-3px, isi Accent atau Primary Dark, teks Background.
- Beri sedikit drop-shadow offset (2px, warna Primary Dark @ 15%) di belakang stiker supaya terasa "ditempel", bukan menyatu rata dengan card.
- Dipakai di: badge achievement, penanda "Root Note" di piano, angka streak/Level/XP di Dashboard, status ronde di Practice.

### 3.3 Halftone Accent — **wajib ada minimal 1 titik per card hero**
- Pola dot bertahap (halftone) dipakai sebagai tekstur dekoratif di sudut card atau di belakang header/badge — **bukan** di seluruh background (biar tetap terbaca).
- Warna dot: `Primary Dark @ 25-40%` di atas Background/Surface Tint (v2 memakai kontras terlalu tipis antar-tint sehingga tidak kelihatan — naikkan opacity dot spesifik ini, area lain di luar dot tetap ikuti aturan opacity rendah).
- Ukuran dot 3-6px, mengecil ke arah tepi (radial fade), area sebar kira-kira seperempat card (pojok kanan atas/bawah).
- Motif pengganti bintang/hantu referensi → **not balok kecil (♪ ♫)** dan **titik nada** yang mengecil ke arah tepi.

### 3.4 Comic-Ink Outline & Title Banner — **elemen baru paling penting, sebelumnya tidak ada di v2**
- Judul section (mis. "PRACTICE", "DASHBOARD", "Hello, Maestro!") tidak cukup hanya diberi outline teks — di referensi judul selalu duduk di atas **banner/pita robek** kecil.
- Implementasi: bentuk pita/persegi panjang pendek dengan tepi robek halus (versi mini dari 3.1, amplitudo 4-6px cukup untuk ukuran banner), warna Surface Tint atau Background (kontras dengan card di baliknya), outline `Primary Dark` 2.5px, rotasi ringan -2° s/d 2°.
- Teks di atas banner: font display tebal (lihat Bagian 4), warna Primary Dark, boleh ditambah outline ganda tipis (outline luar Primary Dark @ 100%, isi teks Background/Accent) + offset-shadow solid 2px (`Primary Dark @ 15%`, bukan blur).
- Dipakai konsisten sebagai header tiap tab/screen dan sebagai judul mode card ("Note Recognition", "Interval Training", dst).

### 3.5 Duotone Illustration
- Semua ilustrasi karakter/maskot & ikon musik memakai treatment **duotone 2 warna** dari palet (mis. Primary Dark + Background, atau Accent + Surface Tint) — bukan ilustrasi full color.
- Gaya garis mengikuti referensi: **line-art tebal, bold, sedikit kasar/hand-drawn** (bukan ikon flat modern super rapi) — supaya senada dengan outline tebal di elemen lain.
- Foto/gambar hasil capture (mis. thumbnail sesi) di-tint duotone yang sama saat ditampilkan di card, supaya menyatu dengan gaya sticker.

### 3.6 Diagonal Stripe Texture
- Background beberapa section (hero card Dashboard, header mode) memakai garis diagonal 1.5px (naik dari 1px supaya kebaca), spasi 10-14px, warna `Primary Dark @ 15-20%` di atas Background — subtle tapi harus tetap kelihatan sebagai tekstur, bukan hilang total.
- Area stripe dibatasi (mis. seperempat/sepertiga card), tidak menutupi area teks utama.

### 3.7 Torn/Ripped Divider
- Pengganti `Divider()` polos antar section → garis sobek horizontal, versi mini dari torn paper card (amplitudo 4-6px, cukup terlihat sebagai garis "robek" bukan garis lurus), warna outline `Primary Dark @ 50%` (naik dari 40% karena di 40% hampir tidak kebaca di atas Background terang).

### 3.8 Doodle Motif Kecil — **elemen baru**
- Referensi mengisi ruang kosong dengan motif kecil bertebaran (bintang, hantu mini, cakar) di sudut-sudut card/section untuk memperkuat kesan "penuh" tanpa mengganggu keterbacaan.
- Padanan musik: not balok kecil (♪♫), gelombang suara mini, bintang kecil, titik nada — digambar line-art tipis (1.5-2px), warna `Primary Dark @ 15-25%`, ukuran kecil (8-16px), tersebar 2-4 buah per card hero di area kosong (jangan menimpa teks/tombol).
- Dipakai di: hero header Dashboard, background kosong di session result card, area kosong achievement card.

---

## 4. Tipografi

| Peran | Font Style | Treatment |
|---|---|---|
| Display / Judul screen | Font sans-serif tebal, sedikit condensed (mis. via `google_fonts`: **Baloo 2** / **Fredoka** — playful, rounded, cocok tema edukasi anak/remaja) | Duduk di atas **title banner** (3.4) + outline ganda + drop offset |
| Sub-heading / label section | Sama family, weight SemiBold | Tanpa banner/outline, warna Primary Dark |
| Body text | Font sans netral existing (tetap seperti sekarang, mis. Inter/Roboto) | Tidak berubah — demi keterbacaan |
| Angka besar (skor, XP, streak) | Font display, weight ExtraBold | Ditempatkan di dalam sticker badge (3.2), badge WAJIB miring |

> Body text & angka statistik **tidak** memakai gaya sticker/outline — supaya tetap terbaca cepat dan tidak lelah dibaca. Playful diterapkan di elemen dekoratif & judul, bukan di seluruh teks.

---

## 5. Pemetaan ke Komponen Existing

| Komponen (sudah ada di kode) | Treatment baru |
|---|---|
| `dashboard_screen.dart` — hero/header | Torn paper card besar (2 sisi sobek) + diagonal stripe di background header + judul di dalam title banner (3.4) + 2-3 doodle motif musik kecil di area kosong |
| Mode card (Explorer/Maestro/Sense) di `PracticeScreen` | Torn paper card per mode, badge sticker status **miring** di pojok (mis. "ESP32 Connected", "Touchscreen Active") dengan warna tint sesuai mode (Teal/Indigo/Deep Orange) sebagai *aksen lokal*, outline & torn edge tetap Primary Dark, judul mode di atas title banner mini |
| `virtual_piano.dart` | Root Note Badge → sticker bulat miring; tuts aktif tetap highlight Accent (tidak berubah) — border tuts ditambah ink-outline tebal |
| `session_result_screen.dart` | Card hasil pakai torn paper 2 sisi + rating 3 bintang digambar gaya hand-drawn/ink + doodle motif musik kecil mengisi ruang kosong |
| `achievement` badge (Dashboard/Stats) | Full sticker badge style (3.2, miring wajib), halftone dot di belakang ikon (3.3) |
| `Semitone Bridge Arc` (Interval Training) | Garis busur tetap, tapi label jarak semitone dibungkus sticker mini miring |
| Bottom Nav (`app_bottom_nav.dart`) | **Tidak diberi torn paper** (area fungsional, harus tetap bersih & stabil) — hanya ikon aktif diberi micro sticker-dot indicator |
| `settings_screen.dart` | Divider standar diganti torn divider (3.7); tidak ada torn card besar (area utilitas, minim dekorasi) |

---

## 6. Batasan (Do's & Don'ts)

**Do:**
- Torn paper, title banner, & sticker miring di card konten utama (Dashboard hero, mode card, achievement, session result) — pastikan efeknya **terlihat jelas tanpa zoom**, bukan sekadar variasi 1-2px.
- Halftone, stripe, & doodle motif hanya sebagai aksen tepi/background/ruang kosong, opacity rendah tapi tetap kebaca (lihat angka spesifik di Bagian 3).
- Duotone konsisten pakai kombinasi dari 4 token warna resmi saja.

**Don't:**
- Jangan ubah posisi/urutan/ukuran struktural komponen yang sudah ada (layout tetap).
- Jangan tambah warna baru di luar 4 token + turunan opacity-nya.
- Jangan pakai torn paper/sticker/banner di elemen fungsional kritikal: bottom nav, tombol primer aksi (Play/Submit), form input, dan Settings — area ini tetap bersih untuk menjaga usability & aksesibilitas (penting karena ada Sense Mode untuk pengguna tunanetra).
- Jangan pakai halftone/stripe/doodle dengan opacity yang membuat kontras teks turun di bawah standar aksesibilitas.
- Jangan menurunkan angka (amplitudo, opacity, rotasi) di bawah nilai minimum pada Bagian 3 hanya demi "terlihat lebih rapi" — itu yang membuat v2 kehilangan kesan playful-nya saat diimplementasi.

---

## 7. Catatan Implementasi Flutter

- **Font**: tambah `google_fonts` (jika belum ada) untuk Baloo 2 / Fredoka sebagai `displayFontFamily` di `ThemeData.textTheme`.
- **Torn paper & badge**: buat 1 reusable widget baru, mis. `TornPaperCard` (via `CustomPainter`, parameter amplitude & jumlah sisi sobek) dan `StickerBadge` (parameter rotasi default -6°~8°, jangan biarkan default 0°), ditaruh di `lib/core/widgets/` supaya dipakai ulang lintas fitur — konsisten dengan pola shell widget yang sudah ada (`explorer_gameplay_screen.dart`, dsb).
- **Title Banner**: widget baru `TitleBanner` (torn ribbon mini + teks di atasnya), dipakai menggantikan `Text()` polos di semua judul section/screen/mode card.
- **Halftone/stripe/doodle pattern**: cukup 1-2 `CustomPainter` generik (`DotPatternPainter`, `StripePatternPainter`, `DoodleScatterPainter`) dengan parameter warna, opacity, & density, dipakai sebagai `background:` di beberapa card — hindari duplikasi painter per screen.
- **Duotone**: gunakan `ColorFiltered` + `ColorFilter.matrix` atau preprocessing asset (ilustrasi baru dibuat langsung 2 warna, tidak perlu filter runtime kalau asset dikontrol tim desain).
- **QA visual**: sebelum merge, cek di ukuran layar HP standar (bukan preview desktop besar) — jika torn edge/stripe/halftone tidak terlihat jelas pada jarak lihat normal, naikkan parameter (amplitudo/opacity), jangan turunkan.
- Semua widget baru ini bersifat **opsional/tambahan** — tidak mengubah struktur `Scaffold`/`IndexedStack` di `home_screen.dart` maupun state management (Riverpod) yang sudah berjalan.

---

## 8. Ringkasan Cepat

| Aspek | Status |
|---|---|
| Warna | Tetap — 4 token resmi, tanpa penambahan |
| Layout aplikasi | Tetap — tidak ada perubahan struktur screen |
| Gaya visual | Diperkuat — torn paper (amplitudo naik), title banner (baru), sticker miring (wajib), halftone/stripe (opacity naik), doodle motif (baru), comic-ink (level: playful penuh, dikalibrasi ulang agar tidak hilang saat build) |
| Area aman dari dekorasi | Bottom nav, tombol aksi primer, form/settings |
| Elemen baru di v3 | Title Banner (3.4), Doodle Motif Kecil (3.8), Gap Analysis (Bagian 0) |
