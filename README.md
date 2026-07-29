# Melody Sense 🎵

> **MELODY SENSE: APLIKASI PERMAINAN EDUKASI UNTUK PEMBELAJARAN NADA MENGGUNAKAN SMART PIANO BERBASIS ESP32**
> 
> *Kompetisi KMIPN — Kategori Pengembangan Aplikasi Permainan*  
> *Politeknik Negeri Ujung Pandang | Tim: "AKU IKUT DIA NGIKUD"*

---

## 📌 Tentang Proyek

**Melody Sense** bukan sekadar piano digital biasa, melainkan sebuah **ekosistem pembelajaran musik berbasis gamifikasi** yang menghubungkan aplikasi Android (Flutter) dengan perangkat fisik **Smart Piano berbasis ESP32** via jaringan Wi-Fi / WebSocket.

Aplikasi ini dirancang untuk membantu pengguna belajar dan mengenali nada dasar (*ear training*) dengan cara yang menyenangkan, intuitif, dan tidak terasa seperti belajar teori musik formal.

---

## ✨ Fitur Utama Aplikasi

### 🎮 Mode Latihan (Ear Training)
- **🎵 Note Recognition**: Latihan mengenali nada tunggal. Dilengkapi mekanik Ronde Misteri (+20 XP), *Compare Playback* saat salah, dan 3 nyawa.
- **🎼 Interval Training**: Latihan mengenali jarak antara dua nada dan jumlah semitone. Dilengkapi visual jembatan jarak (*Distance Bridge curve*), tombol *Next Round*, dan *Compare Playback* adaptif.
- **🥁 Rhythm Match**: Mode permainan ritme lagu (*Song-Based Playback*) tanpa timeout auto-advance. Menyediakan pilihan lagu (*Mary Had a Little Lamb*, *Happy Birthday*, *Ode to Joy*) dengan kalkulasi Waktu Penyelesaian (detik), Akurasi (%), dan Rating 3 Bintang (⭐⭐⭐).
- **🎹 Free Play**: Sandbox piano bebas 14 tuts (`B3–C5` kromatik) tanpa batas waktu dan tanpa nyawa.

---

### 📚 Sistem Submode Edukatif
Setiap mode latihan inti dilengkapi 3 submode bertahap:
1. **📖 Introduce**: Slide Carousel (`PageView`) interaktif yang menjelaskan teori dasar dan modul sampel audio aktif sebelum memulai latihan.
2. **🎮 Start Practice**: Mode latihan utama berstruktur 10 ronde dengan nyawa, skor, dan akumulasi XP.
3. **🎯 Guided Practice**: Mode latihan terbimbing tanpa penalti nyawa, dilengkapi petunjuk visual (*key highlight*) otomatis.

---

## 🎨 Layar & Sistem UI

- **🏠 Dashboard**: Layar utama berisi info level & XP pengguna, dialog status koneksi Smart Piano ESP32, grid 2x2 challenge mode, dan rekor *Personal Best*.
- **🗺️ Progression Path**: Peta jalur level berliku (*CustomPainter winding path*) dengan simpul level adaptif (*completed*, *active*, *locked*, *mystery chest*).
- **📊 Stats & Badges**: Grafik bar akurasi 14 nada (`B3–C5`), 6 badge/achievement otomatis, dan riwayat sesi latihan.
- **⚙️ Settings & Sense Mode**: Pengaturan volume audio, toggle aksesibilitas disabilitas (*Sense Mode* — TTS & Braille fisik), serta opsi reset database.

---

## ♿ Sense Mode (Aksesibilitas Disabilitas)

Sense Mode adalah fitur terintegrasi yang dirancang khusus untuk mendukung pengguna tunanetra dan *low vision*:
- **Hardware**: Label Braille pada tombol fisik Smart Piano ESP32.
- **Software**: Feedback narasi TTS penuh (`flutter_tts`), earcon bunyi pembeda, haptic feedback, dan opsi *high-contrast*.

---

## 🛠️ Arsitektur & Tech Stack

Aplikasi dibangun menggunakan **Clean Architecture (Feature-First)**:

| Layer | Teknologi / Package | Kegunaan |
|---|---|---|
| **Framework** | Flutter (Dart SDK ^3.11) | Cross-platform mobile development |
| **State Management** | `flutter_riverpod` (^2.5.1) | Reactive state & dependency injection |
| **Audio Engine** | `flutter_soloud` (^3.4.6) | Native C++ low-latency audio engine dengan polyphony |
| **Database** | `drift` (^2.20.0) + `sqlite3_flutter_libs` | Local SQLite database untuk histori sesi, attempt, & progression |
| **Preferences** | `shared_preferences` (^2.3.2) | Penyimpanan setting & progress edukasi |
| **Animations** | `flutter_animate` (^4.5.0) | Animasi UI deklaratif & micro-interactions |
| **Navigation** | `go_router` (^14.2.7) | Declarative routing |

---

## 🎹 Perangkat Fisik (Smart Piano ESP32)

- **Mikrokontroler**: ESP32 dengan Wi-Fi built-in.
- **Tuts Fisik**: 13 push button (1 oktaf kromatik penuh `C4–C5`).
- **Komunikasi**: Protocol **WebSocket** persisten dua arah untuk pengiriman event nada secara real-time (`{"note": "C4", "velocity": 100}`).
- **Output Suara**: 2 Passive Buzzer pada breadboard prototipe.

---

## 📂 Struktur Direktori Utama

```
lib/
├── main.dart                          # Entry point aplikasi (ProviderScope & HomeScreen)
├── core/                              # Shared components, theme, database, audio, providers
│   ├── audio/                         # AudioService (flutter_soloud)
│   ├── data/                          # Drift database, tables, DAOs, & repositories
│   ├── domain/                        # Entities & Repository interfaces
│   ├── providers/                     # Database, audio, & education progress providers
│   ├── theme/                         # AppColors design system
│   └── widgets/                       # Virtual Piano (14 tuts), SessionResultScreen, AppBottomNav
└── features/                          # Feature modules (Clean Architecture)
    ├── dashboard/                     # Dashboard Screen
    ├── practice/                      # Practice Mode Selector
    ├── progression/                   # Progression Path Screen
    ├── stats/                         # Stats & History Screen
    ├── free_play/                     # Free Play Screen
    ├── note_recognition/              # Note Recognition (State, Controller, Screens)
    ├── interval_training/             # Interval Training (State, Controller, Screens)
    ├── rhythm_match/                  # Rhythm Match (Domain, Controller, Screens)
    └── settings_screen.dart           # App Settings
```

---

## 🚀 Cara Menjalankan Aplikasi

1. **Prasyarat**:
   - Flutter SDK (^3.11.4)
   - Android Studio / VS Code dengan Flutter Extension
   - Android Emulator atau HP Physical Device

2. **Clone & Install Dependencies**:
   ```bash
   git clone https://github.com/NabilQastari/melody-sense.git
   cd melody_sense
   flutter pub get
   ```

3. **Jalankan Unit Test**:
   ```bash
   flutter test
   ```

4. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

---

© 2026 Tim **AKU IKUT DIA NGIKUD** — Politeknik Negeri Ujung Pandang.
