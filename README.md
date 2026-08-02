# Melody Sense 🎵 — Web Platform

> **MELODY SENSE: PLATFORM WEB EDUKASI PEMBELAJARAN NADA & INTERACTIVE EAR TRAINING BERBASIS MULTISENSORI**
> 
> *Kompetisi KMIPN — Kategori Pengembangan Aplikasi Permainan & Platform Edukasi Web*  
> *Politeknik Negeri Ujung Pandang | Tim: "AKU IKUT DIA NGIKUD"*

---

## 📌 Tentang Website Melody Sense

**Melody Sense Web** adalah platform web interaktif untuk **pembelajaran musik dan latihan pendengaran (*ear training*) berbasis gamifikasi** yang dapat diakses langsung melalui peramban web (*web browser*) modern tanpa perlu menginstal aplikasi tambahan.

Website ini menghadirkan pengalaman belajar nada dasar (*pitch recognition*), interval musik, ingatan melodi, dan ritme lagu dengan antarmuka web yang responsif, visual yang menarik, serta sistem aksesibilitas inklusif (**Sense Mode Web**) yang ramah bagi penyandang disabilitas netra.

---

## ✨ Fitur Utama Website

### 🎮 Modul Latihan Pendengaran (Web Ear Training)
- **🎵 Note Recognition (Tebak Nada Web)**: Latihan mendeteksi tinggi-rendah nada tunggal (`C4–C5`). Dilengkapi mekanik *Mystery Round* (Bonus +20 XP), *Compare Playback* saat jawaban kurang tepat, dan indikator nyawa interaktif.
- **🎼 Interval Training (Jembatan Jarak Nada)**: Latihan mengenali jarak antara dua nada dan jumlah semitone. Antarmuka web menampilkan kurva visual *Distance Bridge*, petunjuk nama interval, dan audio perbandingan adaptif.
- **🎙️ Melody Echo (Ingatan Melodi)**: Melatih memori pendengaran (*auditory memory*) dengan menebak sekuens melodi bertahap (3 hingga 7 nada).
- **🥁 Rhythm Match (Permainan Ketukan & Tempo)**: Latihan ketepatan ritme berbasis lagu (*Song-Based Rhythm Playback*) seperti *Mary Had a Little Lamb*, *Happy Birthday*, dan *Ode to Joy* dengan kalkulasi persentase akurasi, waktu penyelesaian, dan skor 3 Bintang (⭐⭐⭐).
- **🎹 Free Play Web Piano**: Mode sandbox piano virtual 14 tuts (`B3–C5` kromatik) tanpa batas waktu yang dapat dimainkan menggunakan klik mouse, *touchscreen*, maupun **Pintasan Keyboard (Hotkeys)**.

---

### 📚 Sistem Submode Edukatif Web
Setiap modul latihan di website dilengkapi dengan 3 submode berjenjang:
1. **📖 Introduce (Perkenalan Teori)**: Slide Carousel interaktif berbasis web untuk mempelajari teori dasar musik dan mendengarkan sampel nada sebelum latihan.
2. **🎮 Start Practice (Sesi Ujian Utama)**: Mode latihan utama berstruktur 8–10 ronde dengan sistem nyawa, skor, dan akumulasi XP.
3. **🎯 Guided Practice (Latihan Terbimbing)**: Mode latihan bebas risiko penalti nyawa dengan petunjuk visual otomatis (*Key Highlight*) pada tuts piano web.

---

## ♿ Sense Mode Web (Aksesibilitas Inklusif)

Website Melody Sense dirancang inklusif agar dapat diakses secara mandiri oleh pengguna penyandang disabilitas netra (*visually impaired*) langsung dari peramban web:
- **🔊 Web Speech API / TTS**: Pembacaan naskah, nama nada, dan navigasi antarmuka web secara otomatis menggunakan sintetis suara *Text-to-Speech*.
- **🎵 Earcon & Audio Feedback**: Efek suara pembeda untuk setiap aksi (jawaban benar, salah, perpindahan menu, dan petunjuk).
- **⌨️ Screen Reader & Keyboard Friendly**: Dukungan navigasi penuh menggunakan keyboard tanpa tergantung pada tetikus (*mouse*).
- **👁️ High-Contrast Web Theme**: Mode tampilan visual kontras tinggi untuk kenyamanan pengguna *low vision*.

---

## ⌨️ Kontrol Web & Pintasan Keyboard (Hotkeys)

Di website Melody Sense, Anda dapat memainkan tuts piano virtual menggunakan keyboard komputer:

| Tuts Nada | Tangga Nada | Tombol Keyboard |
|---|---|---|
| **B3** | Diatonik | `Z` |
| **C4** | Diatonik | `A` |
| **C#4 / Db4** | Kromatik | `W` |
| **D4** | Diatonik | `S` |
| **D#4 / Eb4** | Kromatik | `E` |
| **E4** | Diatonik | `D` |
| **F4** | Diatonik | `F` |
| **F#4 / Gb4** | Kromatik | `T` |
| **G4** | Diatonik | `G` |
| **G#4 / Ab4** | Kromatik | `Y` |
| **A4** | Diatonik | `H` |
| **A#4 / Bb4** | Kromatik | `U` |
| **B4** | Diatonik | `J` |
| **C5** | Diatonik | `K` |

---

## 🎨 Tampilan & Navigation Web

- **🏠 Web Dashboard**: Pusat kendali utama yang menampilkan informasi profil, statistik level & XP, tantangan latihan 2x2, serta status mode operasional.
- **🗺️ Progression Path**: Peta jalur level berliku interaktif (*Interactive Winding Path*) untuk memantau progres pembelajaran.
- **📊 Stats & Badges**: Grafik analisis akurasi 14 nada (`B3–C5`), daftar pencapaian lencana (*achievement badges*), dan riwayat sesi latihan.
- **⚙️ Web Settings**: Pengaturan volume audio web, beralih ke *Sense Mode*, dan manajemen data lokal peramban.

---

## 🛠️ Arsitektur & Tech Stack Web

Website ini dibangun menggunakan teknologi web modern dan arsitektur modular **Clean Architecture (Feature-First)**:

| Layer | Teknologi / Package | Kegunaan pada Web |
|---|---|---|
| **Web Framework** | Flutter Web (Dart SDK ^3.11) | Framework pengembangan aplikasi web responsif multi-platform |
| **State Management** | `flutter_riverpod` (^2.5.1) | Manajemen state reaktif & *dependency injection* di web |
| **Web Audio Engine** | Low-Latency Web Audio Synthesizer | Pengolahan suara piano polyphonic berlatensi rendah di peramban |
| **Web Database** | `drift` (^2.20.0) + IndexedDB / SQLite Web | Penyimpanan database lokal web untuk histori sesi & progres XP |
| **Web Storage** | `shared_preferences` (^2.3.2) | Penyimpanan konfigurasi & preferensi pengguna web |
| **Routing & Navigation** | `go_router` (^14.2.7) | Navigasi URL deklaratif & dukungan *deep linking* di browser |
| **Web Sockets** | `web_socket_channel` (^3.0.1) | Integrasi komunikasi real-time opsional dengan Smart Piano ESP32 |
| **Accessibility API** | Web Speech API & `flutter_tts` | Sintesis suara narasi untuk fitur *Sense Mode Web* |

---

## 🌐 Integrasi Perangkat ESP32 via WebSocket (Opsional)

Selain menggunakan tuts piano virtual di layar web, website Melody Sense juga mendukung integrasi dengan **Smart Piano Fisik berbasis ESP32**:
- **Komunikasi Persisten**: Menghubungkan browser dengan ESP32 melalui protokol **WebSocket** (`ws://`).
- **Real-Time Input**: Penekanan tuts fisik pada piano ESP32 langsung terdeteksi di website secara *real-time* tanpa latensi spionase.

---

## 📂 Struktur Direktori Web Project

```text
lib/
├── main.dart                          # Entry point aplikasi web (ProviderScope & Router)
├── core/                              # Shared components, web theme, database, & audio providers
│   ├── audio/                         # Web Audio Engine & Polyphonic Sound Service
│   ├── data/                          # Drift database Web (IndexedDB / Local Storage)
│   ├── providers/                     # Database, audio, & web state providers
│   ├── theme/                         # AppColors design system & high-contrast web theme
│   └── widgets/                       # Web Virtual Piano (14 tuts), Results Dialog, Bottom Navigation
└── features/                          # Feature Modules (Clean Architecture)
    ├── dashboard/                     # Web Dashboard Screen
    ├── practice/                      # Practice Selector (Note, Interval, Echo, Rhythm)
    ├── progression/                   # Web Progression Path Screen
    ├── stats/                         # Accuracy Charts & Achievements Screen
    ├── free_play/                     # Web Virtual Piano Free Play Screen
    ├── note_recognition/              # Note Recognition Web Module
    ├── interval_training/             # Interval Training Web Module
    ├── rhythm_match/                  # Rhythm Match Web Module
    └── settings_screen.dart           # Web Application Settings
web/
├── index.html                         # Entry point HTML5 web application
├── manifest.json                      # PWA (Progressive Web App) manifest configuration
└── favicon.png                        # Icon website Melody Sense
```

---

## 🚀 Cara Menjalankan Website Secara Lokal

### Prasyarat:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (^3.11.4 atau terbaru)
- Peramban web modern (Google Chrome, Microsoft Edge, Mozilla Firefox, atau Safari)
- VS Code / Android Studio dengan ekstensi Flutter

### Langkah-Langkah:

1. **Clone Repositori**:
   ```bash
   git clone https://github.com/NabilQastari/melody-sense.git
   cd melody_sense
   ```

2. **Install Web Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Jalankan Website di Mode Development (Chrome)**:
   ```bash
   flutter run -d chrome
   ```

4. **Build untuk Rilis Deployment Web**:
   ```bash
   flutter build web --release
   ```
   *Hasil build web akan tersimpan pada direktori `build/web/` dan siap di-deploy ke web hosting (GitHub Pages, Vercel, Netlify, atau Firebase Hosting).*

---

© 2026 Tim **AKU IKUT DIA NGIKUD** — Politeknik Negeri Ujung Pandang.
