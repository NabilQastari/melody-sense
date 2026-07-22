# Melody Sense — Konteks Proyek & Progres Pengembangan

> File ini berisi ringkasan diskusi dan keputusan yang sudah diambil untuk proyek **Melody Sense**, dibuat agar sesi chat baru dapat langsung memahami konteks tanpa perlu mengulang penjelasan dari awal.

## Aturan Kerja (WAJIB diikuti)

**Di akhir setiap sesi pengembangan, file ini WAJIB di-update** dengan:
1. Ringkasan apa yang dibahas/diputuskan/dikerjakan di sesi tersebut
2. Update tabel "Rencana Sesi Pengembangan" (status sesi jadi selesai)
3. Update bagian "Status Proyek Saat Ini" agar sesi berikutnya tahu harus mulai dari mana

Tujuannya: chat/sesi baru bisa langsung lanjut tanpa mengulang penjelasan dari awal.

**Saat menunjukkan struktur folder ke user di tengah percakapan (bukan saat update file ini):** tunjukkan hanya bagian yang baru/berubah (diff), bukan seluruh tree — supaya gampang dipindai. Bagian "Struktur folder" di file ini sendiri tetap harus lengkap/akurat (ini dokumen acuan, bukan chat reply), aturan diff ini khusus untuk respons di chat.

> ⚠️ **Catatan penting:** Sebelum mengedit/mengganti file ini di akhir sesi, PASTIKAN semua bagian dari versi sebelumnya tetap ada (terutama bagian "Mode Disabilitas (Sense Mode)" dan catatan revisi hardware) — jangan sampai memulai dari versi lama yang belum ter-update dan tidak sengaja menghapus bagian yang sudah ditambahkan sesi-sesi sebelumnya.

---

## Tentang Proyek

**Nama:** Melody Sense
**Judul lengkap (proposal):** "MELODY SENSE: APLIKASI PERMAINAN EDUKASI UNTUK PEMBELAJARAN NADA MENGGUNAKAN SMART PIANO BERBASIS ESP32"
**Kompetisi:** KMPIN — Pengembangan Aplikasi Permainan
**Institusi:** Politeknik Negeri Ujung Pandang
**Tim:** "AKU IKUT DIA NGIKUD"
- Ketua Tim: Muh. Nabil Qastari (47224038)
- Anggota: Fauzih Falih (47224048), Khadijah Meidina Eka Putri (47224037)

**Konsep:** Game edukasi berbasis Android yang terhubung dengan Smart Piano berbasis ESP32 melalui jaringan Wi-Fi, untuk membantu pengguna belajar dan mengenali nada dasar (*ear training*) melalui pengalaman gamifikasi.

**Filosofi utama:** Bukan sekadar piano digital, melainkan **ekosistem pembelajaran musik** yang menggabungkan perangkat fisik (Smart Piano) dengan aplikasi Android, sehingga proses belajar terasa seperti bermain game — **tidak terasa seperti belajar teori musik**.

**Status proposal:** Sudah di-handle tim (bagian A.3 poin a-i selesai). Sekarang masuk ke **fase pengembangan aplikasi**.

---

## Progres Hardware Saat Ini

Prototipe embedded system sederhana sudah berhasil dibuat (belum terhubung ke aplikasi Android):

- Arduino Mega 2560
- 11 Push Button: 9 tombol nada, 1 tombol Auto Play, 1 tombol Cheat Note (status: tentatif)
- 2 Passive Buzzer, Breadboard 830 + Mini Breadboard, Kabel Jumper

Pengembangan hardware fisik **awalnya** direncanakan dilanjutkan setelah lolos tahap 1 kompetisi. Untuk sekarang, pengembangan aplikasi fokus ke **Explorer Mode** (virtual, tidak butuh hardware).

**Protokol komunikasi final (untuk Maestro Mode nanti):** Wi-Fi + **WebSocket** (bukan BLE, bukan REST API murni) — karena butuh koneksi persisten dua arah, latensi rendah untuk event tombol real-time.

> ⚠️ **Revisi keputusan (paska Sesi 3, sebelum Sesi 4):** Timeline hardware dimajukan. Alih-alih menunggu lolos tahap 1, tim akan membuat **breadboard prototype fungsional** (belum rapi/final) berbasis **ESP32** (WiFi built-in) lebih awal, berjalan **paralel** dengan pengembangan software. Tujuannya validasi arsitektur WebSocket + Sense Mode (lihat bagian "Mode Disabilitas / Sense Mode"), bukan mengejar desain fisik akhir kompetisi.
> - Spek minimal: ESP32 + beberapa tombol fisik (cukup 1 oktaf/8 tombol untuk pembuktian konsep) + firmware sederhana yang mengirim event nada (`{"note": "C4", "velocity": 100}`) via WebSocket.
> - Sisi app tidak perlu menunggu ESP32 selesai — `WebSocketService` bisa mulai ditest lebih dulu pakai mock WebSocket server, kontrak JSON note event dijaga konsisten dari awal.
> - Kode Braille di tombol fisik (untuk Sense Mode) direncanakan menyusul di iterasi breadboard berikutnya, setelah validasi dasar WebSocket berhasil.
> - Belum diputuskan: siapa di tim yang pegang firmware ESP32, dan detail lengkap kontrak JSON note event (field selain note/velocity, misal timestamp/button_id) — masih open question, belum disentuh di Sesi 4.

> ⚠️ **Revisi keputusan lanjutan (paska Sesi 10):** Spek breadboard ESP32 di atas (8 tombol/1 oktaf natural) direvisi jadi **13 tombol (1 oktaf kromatik penuh)** — lihat detail lengkap & dampaknya ke piano virtual di bagian "Diskusi & Keputusan Baru (Paska Sesi 10): Piano Kromatik 13 Tuts + Update Komponen Hardware ESP32" di akhir dokumen ini.
> - **Komponen tambahan dikonfirmasi:** 5× push button baru (untuk 5 tuts sharp/flat) + 1× ESP32.
> - **Komponen suara:** tetap pakai 2 buzzer pasif yang sudah ada (dipindah dari prototipe Mega) — mini speaker dipertimbangkan tapi **tidak dipilih** (butuh modul amplifier tambahan, dianggap belum perlu).

---

## Keputusan Arsitektur & Tech Stack (Sesi 1, direvisi Sesi 3)

**Platform:** Flutter (tim sudah berpengalaman dengan Flutter, bukan native Android/Kotlin)

**Tidak menggunakan game engine** (Unity/Godot/Flame) — gameplay Melody Sense tidak butuh physics/sprite rendering kompleks, cukup ditangani widget & animation system Flutter. Flame bisa ditambahkan belakangan sebagai package kalau suatu saat butuh mini-game dengan physics.

**Tech stack:**

| Layer | Pilihan | Alasan |
|---|---|---|
| State management | **Riverpod** | Ringan, modern, dipilih tim |
| Audio | **flutter_soloud** ⚠️ *(direvisi Sesi 3, awalnya just_audio)* | Native low-level engine (SoLoud), latensi jauh lebih rendah & mendukung polyphony (nada sama bisa "di-spam"/ditumpuk tanpa nunggu instance sebelumnya). just_audio dicoba duluan tapi delay masih terasa & tidak bisa spam tuts yang sama (satu AudioPlayer cuma punya satu posisi playback) |
| Local storage (data terstruktur) | **Drift** (SQLite wrapper) | Untuk data relasional: sessions, attempts (histori lengkap), personal_best, achievements |
| Local storage (settings ringan) | **shared_preferences** | Key-value sederhana (volume, preferensi) |
| WebSocket (nanti, Maestro Mode) | **web_socket_channel** | Package resmi Dart |
| Navigasi | **go_router** | Navigasi antar mode/layar |
| Animasi UI | **flutter_animate** *(baru, direncanakan Sesi 11.1)* | Package animasi deklaratif (`.animate().scale()`, `.shake()`, `.fadeIn()`, dst) — dipilih daripada menulis manual `AnimatedContainer`/`TweenAnimationBuilder` satu-satu, supaya animasi feedback teks & tombol di Note Recognition lebih ringkas ditulis dan konsisten dipakai ulang di mode latihan lain nanti |
| Arsitektur | **Clean Architecture, feature-first** | Presentation → Domain → Data per fitur, modular & scalable |

**Struktur folder (gabungan Sesi 1–7, kondisi aktual):**
```
melody_sense/
├── lib/
│   ├── main.dart                      # entry point — home: HomeScreen() (Sesi 7), ProviderScope wajib
│   │
│   ├── core/                          # shared: theme, constants, utils, network, audio service
│   │   ├── theme/
│   │   │   └── app_colors.dart        # palet warna resmi (lihat "Design System")
│   │   ├── audio/
│   │   │   └── audio_service.dart     # AudioService (flutter_soloud) + Completer `ready` (Sesi 4, fix bug nada senyap)
│   │   ├── providers/
│   │   │   ├── database_providers.dart    # appDatabaseProvider, dst. (Sesi 2)
│   │   │   └── audio_providers.dart       # audioServiceProvider + audioReadyProvider (baru, Sesi 4)
│   │   ├── widgets/
│   │   │   ├── virtual_piano.dart             # komponen piano dasar (tap + swipe/glissando)
│   │   │   ├── explorer_gameplay_screen.dart  # SHELL Explorer Mode, responsif portrait/landscape
│   │   │   ├── maestro_gameplay_screen.dart   # SHELL Maestro Mode, responsif portrait/landscape
│   │   │   ├── session_result_screen.dart     # SHELL hasil sesi, reusable semua mode latihan (Sesi 4); `_StaticBottomNav` DIHAPUS (Sesi 7), `onContinue`/`onRetry` VoidCallback diganti `retryScreenBuilder` WidgetBuilder (fix bug dead context)
│   │   │   ├── app_bottom_nav.dart            # (Sesi 6→redesign Sesi 7) — bottom nav 4 tab, desain ikon+teks+underline indicator (bukan circle), dipakai HANYA di HomeScreen
│   │   │   └── home_screen.dart               # BARU (Sesi 7) — shell utama app: Scaffold + IndexedStack (4 tab) + AppBottomNav. Satu navbar untuk seluruh app, hilang otomatis saat gameplay di-push di atasnya.
│   │   ├── data/
│   │   │   ├── local/
│   │   │   │   ├── app_database.dart          # DriftDatabase utama
│   │   │   │   ├── connection/connection.dart
│   │   │   │   ├── daos/          # achievement, attempt, personal_best, session
│   │   │   │   └── tables/        # achievements, attempts, personal_bests, sessions
│   │   │   └── repositories/      # practice_repository_impl, progression_repository_impl
│   │   └── domain/
│   │       ├── entities/
│   │       │   ├── practice_entities.dart     # TrainingMode, PracticeSession, NoteAttempt, NoteAccuracyStat + (catatan: kAvailableNotes & RoundFeedback BELUM dipindah ke sini meskipun direncanakan Sesi 6 — masih di note_recognition_state.dart, diimport lintas fitur pakai `show`)
│   │       │   └── progression_entities.dart
│   │       └── repositories/      # practice_repository, progression_repository (interface)
│   │
│   └── features/
│       ├── practice/              # (Sesi 6) — tab "Pick a Challenge", konten tab di HomeScreen
│       │   └── presentation/
│       │       ├── models/challenge_info.dart          # data challenge (presentation layer)
│       │       ├── widgets/challenge_card.dart          # card per challenge
│       │       ├── widgets/difficulty_badge.dart        # badge BEGINNER/INTERMEDIATE/ADVANCE
│       │       └── screens/practice_screen.dart         # konten tab (bukan Scaffold mandiri, Sesi 7 refactor)
│       ├── note_recognition/
│       │   └── presentation/
│       │       ├── state/note_recognition_state.dart              # state immutable (Sesi 4); masih berisi kAvailableNotes & RoundFeedback (belum dipindah)
│       │       ├── controllers/note_recognition_controller.dart   # StateNotifier.autoDispose (Sesi 4)
│       │       └── screens/note_recognition_screen.dart           # wrapper → ExplorerGameplayScreen, gate audioReadyProvider (Sesi 4)
│       ├── interval_training/     # full domain logic Sesi 6
│       │   └── presentation/
│       │       ├── state/interval_training_state.dart             # state + IntervalDefinition + kValidIntervalRounds
│       │       ├── controllers/interval_training_controller.dart  # StateNotifier.autoDispose
│       │       └── screens/interval_training_screen.dart          # tersambung penuh ke controller (Sesi 6)
│       ├── melody_echo/
│       │   └── presentation/screens/melody_echo_screen.dart        # wrapper tipis → MaestroGameplayScreen, DITUNDA ke Sesi 10 (keputusan user)
│       ├── maestro_mode/
│       │   └── presentation/screens/maestro_challenge_screen.dart  # wrapper tipis → MaestroGameplayScreen
│       ├── rhythm_match/          # domain logic Sesi 6, screen Sesi 7 (BELUM DITES — build error import)
│       │   └── presentation/
│       │       ├── state/rhythm_match_state.dart                  # state + konstanta BPM/hit window
│       │       ├── controllers/rhythm_match_controller.dart       # StateNotifier.autoDispose + Timer
│       │       └── screens/rhythm_match_screen.dart               # BARU (Sesi 7) — wrapper → ExplorerGameplayScreen
│       ├── stats/                 # BARU (Sesi 7) — tab Stats "Your Progress"
│       │   └── presentation/
│       │       ├── providers/stats_providers.dart                 # Riverpod providers (FutureProvider/StreamProvider)
│       │       └── screens/stats_screen.dart                     # konten tab: Level card, Note Accuracy bar chart, Badges grid, Practice History
│       ├── placeholder/           # BARU (Sesi 7) — placeholder screens, TIDAK LAGI DIPAKAI (digantikan inline di HomeScreen)
│       │   └── presentation/screens/placeholder_screens.dart     # ⚠️ orphan file, bisa dihapus
│       └── progression/           # direncanakan, belum dikerjakan
│
├── test/
│   └── app_database_test.dart     # 14 unit test (semua DAO) — Sesi 2
│
└── README_SESI2.md                # dokumentasi cara pakai skema database — Sesi 2
```

**Catatan penting soal struktur:**
- Folder `features/maestro_mode/` **tidak ada di rencana awal Sesi 1** — muncul di Sesi 3 karena Maestro Mode ternyata butuh layar cross-cutting sendiri (dipakai lintas jenis challenge), bukan spesifik ke satu fitur latihan.
- Desain 05a (Note Recognition portrait) dan 05b (Explorer Landscape) awalnya dikira 2 layar terpisah, ternyata **1 layar yang sama, cuma beda orientasi** — begitu juga 05c (Melody Echo portrait) dan 05d (Maestro Landscape). Karena itu, alih-alih 4 screen terpisah, dibuat **2 shell UI reusable** (`ExplorerGameplayScreen`, `MaestroGameplayScreen`) yang otomatis switch layout pakai `OrientationBuilder`, dan 4 fitur cuma jadi wrapper tipis yang menyuplai data ke shell yang sesuai.
- Sejak Sesi 4, pola shell reusable ini diperluas: `SessionResultScreen` juga dibuat sebagai shell tunggal yang dipakai semua mode latihan (bukan dibuat ulang per fitur).
- Folder `features/practice/` **tidak ada di rencana awal** — ditambahkan Sesi 6 atas permintaan user, supaya pemilihan mode latihan bisa dilakukan dari dalam app (tab), bukan dengan mengubah `home:` di `main.dart` manual tiap mau test mode lain.
- **Pelajaran dari bug Sesi 6:** sempat ada percobaan meminjam `kAvailableNotes`/`RoundFeedback` langsung dari `note_recognition_state.dart` lewat `import ... show` di `interval_training_state.dart` — ternyata `import ... show` tidak diteruskan transitif ke file lain yang meng-import file itu (beda dengan `export`), menyebabkan `RoundFeedback` undefined di controller. Diperbaiki dengan memindahkan keduanya ke `practice_entities.dart` (domain layer, sudah jadi rumah `TrainingMode`) yang sudah di-import langsung oleh kedua controller — sekarang tidak ada lagi dependency fitur-ke-fitur untuk konstanta dasar ini.

Prinsip: Domain layer tidak boleh bergantung ke Flutter/Drift — logic game bisa ditest tanpa UI. Data layer yang menyimpan detail WebSocket, jadi saat Maestro Mode masuk, Presentation & Domain di semua fitur latihan tidak perlu diubah.

---

## Design System (ditambahkan Sesi 3)

Palet warna resmi, diambil langsung dari file desain tim:

| Token | Hex | Kegunaan |
|---|---|---|
| Primary Dark | `#51508B` | Heading, tombol utama, ikon aktif |
| Background | `#F2F5FF` | Latar layar |
| Surface Tint | `#D5D4FF` | Card ungu muda, progress track (belum terisi) |
| Accent | `#8197E5` | Highlight tuts piano aktif, progress fill, aksen interaktif |

Diimplementasikan di `lib/core/theme/app_colors.dart` sebagai `AppColors` class. Beberapa varian turunan (opacity/fade) ditambahkan di situ untuk kebutuhan praktis UI, tapi 4 warna di atas adalah sumber kebenaran (source of truth) — semua desain baru harus konsisten dengan palet ini.

---

## Mode Disabilitas ("Sense Mode") — Rencana Fitur

> Ditambahkan paska Sesi 3, sebelum Sesi 4 dimulai. Bagian ini untuk kebutuhan **proposal kompetisi** dan **desain UI di Stitch** — deskripsi fitur belum ada implementasi kode, murni rencana/spesifikasi. **Belum disentuh di Sesi 4.**

**Nama fitur:** **Sense Mode** *(dipilih; konsisten dengan nama produk "Melody Sense", dan mencerminkan pendekatan multi-indera — raba lewat Braille, dengar lewat suara — tanpa framing klinis seperti "mode disabilitas")*

**Pendekatan:** Physical-first — dibangun di atas fondasi **Maestro Mode** (piano fisik via WebSocket), bukan piano virtual. Alasan: tombol fisik Smart Piano sudah tactile secara alami, jadi Sense Mode tinggal memanfaatkan input yang sudah ada, bukan menciptakan ulang cara input nada yang aksesibel.

**Keputusan penting:** Sense Mode adalah **satu paket terintegrasi**, tidak dipecah jadi toggle terpisah untuk tunanetra total vs low vision. Kombinasi fiturnya:
- **Di alat (hardware):** kode **Braille** pada setiap tombol fisik piano — label taktil nada, ditambahkan di iterasi breadboard prototype berikutnya (lihat "Progres Hardware Saat Ini")
- **Di aplikasi (software):** feedback suara penuh (TTS) untuk semua interaksi, dilengkapi opsi high-contrast/font besar untuk sub-kelompok low vision di dalam mode yang sama

**Fitur yang direncanakan:**
1. **Narasi TTS penuh** (`flutter_tts`) — instruksi soal, target nada/interval, feedback benar/salah, skor akhir, level up, achievement unlock. Semua yang biasanya cuma teks di layar, disuarakan.
2. **Kode Braille di tombol fisik** — label taktil nada langsung di hardware Smart Piano, memastikan input nada bisa dilakukan tanpa melihat layar sama sekali.
3. **Earcon pembeda** — bunyi khusus untuk benar/salah yang jelas beda dari bunyi nada itu sendiri, supaya tidak ambigu didengar.
4. **Haptic feedback pelengkap** — getar di HP sebagai konfirmasi tambahan, menyatu dengan feedback fisik dari tombol piano.
5. **Kompatibilitas TalkBack/screen reader** untuk semua layar non-piano — menu utama, pilihan mode, kartu skor, dsb tetap perlu navigasi layar biasa, dilabeli pakai `Semantics` widget Flutter.
6. **Kontrol kecepatan narasi** — pengguna bisa atur seberapa cepat TTS bicara.
7. **Toggle high-contrast / font besar** — untuk sub-kelompok low vision, dipaketkan di mode yang sama (bukan mode terpisah).

**Peran app:** bergeser dari "tempat menekan nada" menjadi "narator & pemberi feedback" — semua instruksi, hasil, dan skor disuarakan, sementara nada dimainkan langsung di piano fisik (dibantu label Braille).

**Dampak arsitektur:**
- **Reuse:** `PracticeRepository`, skema Drift, shell `MaestroGameplayScreen` (dan sekarang `SessionResultScreen` dari Sesi 4) — tidak ada perubahan
- **Baru:** kemungkinan `ttsServiceProvider` (pola sama seperti `audioServiceProvider`/`audioReadyProvider`), plus lapisan narasi di atas shell Maestro yang sudah ada

**Catatan timeline:** Sense Mode secara fungsional tetap bergantung pada Smart Piano fisik + WebSocket, namun karena breadboard prototype ESP32 **dimajukan** dan dikerjakan paralel (lihat "Progres Hardware Saat Ini"), bagian TTS/Semantics (poin 1, 5, 6, 7) bisa mulai dikerjakan lebih awal — nempel ke shell Maestro yang UI-nya sudah ada dari Sesi 3 (masih dummy data) — sementara integrasi Braille + WebSocket menyusul begitu breadboard siap.

**Open questions (belum diputuskan, belum bergerak sejak sebelum Sesi 4):**
- Kontrak JSON note event lengkap — field apa saja selain `note`/`velocity` (misal `timestamp`, `button_id`)?
- Siapa di tim yang pegang firmware ESP32?
- Rencana user testing dengan pengguna tunanetra/low vision asli — terutama untuk kalibrasi kecepatan TTS default dan pola earcon yang familiar (mendekati kebiasaan TalkBack)?

---

## Skema Database Lokal (Sesi 1–2)

Dipilih skema relasional (Drift) karena butuh **histori lengkap tiap sesi latihan** (bukan cuma angka agregat) untuk mendukung grafik tren dari waktu ke waktu.

**Tabel:**
- **`sessions`** — id, mode, started_at, ended_at, xp_earned, score
- **`attempts`** — id, session_id (FK), note, is_correct, response_time_ms, timestamp (satu baris per tekan nada, dasar untuk grafik akurasi per nada)
- **`personal_best`** — mode (PK), best_score, achieved_at
- **`achievements`** — id, title, unlocked, progress_current, progress_target, unlocked_at
- **`settings`** — key-value (disimpan terpisah pakai shared_preferences, bukan Drift)

**Keputusan:** XP total & level dihitung **on-the-fly** dari `SUM(xp_earned)` di tabel `sessions`, bukan disimpan sebagai angka terpisah — lebih simpel, selalu akurat, dan skalanya (single-user local) tidak akan jadi masalah performa.

Implementasi konkret (DAO, domain entities, repository, Riverpod providers) sudah jadi di Sesi 2 — lihat `README_SESI2.md` untuk detail.

---

## Fitur Aplikasi (Ringkasan)

**Mode Latihan Inti (Ear Training)**
- Note Recognition (✅ end-to-end sejak Sesi 4), Interval Training, Melody Echo, Rhythm Match

**Dua Mode Input**
- **Explorer Mode** (virtual, fokus pengembangan sekarang) — piano virtual di layar, UI sudah jadi di Sesi 3, Note Recognition sudah hidup penuh di Sesi 4
- **Maestro Mode** (fisik, pasca tahap 1) — pakai Smart Piano via WebSocket, UI sudah jadi di Sesi 3 (data masih dummy, nunggu WebSocket di Sesi 9)

**Gamifikasi (lokal, per-device, tanpa login/akun)**
- XP & Level, Personal Best, Badge/Achievement — logic-nya sudah digarap penuh Sesi 5 (lihat "Status Proyek Saat Ini"), tapi belum semua tersambung ke UI (mis. layar Progression path untuk Difficulty adaptif & Beginner→Intermediate→Advanced belum ada)

**Fitur Pendukung**
- Statistik & grafik progres pribadi, Auto Play

**Tentatif**
- Cheat Note — kemungkinan diganti fitur lain, keputusan masih ditunda (belum ada progress sampai Sesi 4)

**Mode Aksesibilitas — "Sense Mode" (baru, direncanakan paska Sesi 3)**
- Satu paket terintegrasi untuk pengguna tunanetra/low vision, dibangun di atas Maestro Mode (fisik). Detail lengkap ada di bagian "Mode Disabilitas (Sense Mode)" di atas. Belum ada progress implementasi.

---

## Rencana Sesi Pengembangan

| Sesi | Fokus | Status |
|---|---|---|
| 1 | Brainstorming arsitektur (stack, no game engine, skema DB) + setup awal project (install tools, scaffold, folder structure) | ✅ Selesai |
| 2 | Implementasi struktur data lokal (Drift schema: sessions, attempts, personal_best, achievements) | ✅ Selesai |
| 3 | Audio service + virtual piano UI (fondasi Explorer Mode) | ✅ Selesai |
| 4 | Fitur Note Recognition end-to-end (jadi template pola untuk fitur lain) | ✅ Selesai |
| 5 | Sistem gamifikasi (XP, level, personal best, achievement logic) | ✅ Selesai |
| 6 | Fitur latihan lain (Interval Training, Rhythm Match) + Practice tab | ✅ Selesai — Melody Echo **ditunda ke Sesi 10** (keputusan user). |
| 7 | Statistik & grafik progres + refactor navbar arsitektur | ✅ Selesai |
| 8 | Progression path UI (peta level) + polish Explorer Mode | ✅ Selesai |
| 9 | Halaman Dashboard (baru ditambahkan Sesi 5 — belum ada detail konten/desain, lihat catatan) | ✅ Selesai |
| 10 | Brainstorming (Fitur Peningkatan UX & Edukasi Latihan) | ⏸️ Dijeda sementara — brainstorming Note Recognition & Interval Training menghasilkan rencana konkret (lihat 11.1 & 11.2), lanjut brainstorming mode latihan lain (Melody Echo, Rhythm Match) setelah 11.2 selesai |
| 11 | Implementasi dari Rencana Pembaruan (UX & Edukasi Latihan) | ⏳ Belum mulai |
| 11.1 | Update Note Recognition (Mekanik & Visual Tambahan) — sub-sesi dari Sesi 11, dikerjakan lebih dulu sebagai test case | ✅ Selesai |
| 11.2 | Update Interval Training (Mekanik & Visual Tambahan) — sub-sesi dari Sesi 11, lanjutan pola 11.1 | ✅ Selesai |
| 12 | Persiapan Maestro Mode (WebSocket client) + **Melody Echo** (ditunda dari Sesi 6) | ⏳ Belum mulai |
| 13 | Testing & persiapan submission tahap 2 | ⏳ Belum mulai |
| 14 | Fitur Kustomisasi & Reward Peti Rahasia (Piano Skins / Themes) | ⏳ Belum mulai |
| 15 | Update Piano Virtual jadi Kromatik (13 tuts: natural + sharp/flat) + penyesuaian di semua mode latihan (Note Recognition, Interval Training, Rhythm Match, Melody Echo) | ⏳ Belum mulai — baru tahap keputusan, lihat "Diskusi & Keputusan Baru (Paska Sesi 10)" |

*(Rencana ini bisa disesuaikan/dipecah lebih lanjut sesuai kebutuhan saat pengembangan berjalan. Sesi 9 "Dashboard" disisipkan saat Sesi 5. Sesi 10 & 11 ditambahkan di akhir Sesi 9 atas permintaan user untuk memprioritaskan peningkatan UX, kesenangan, dan nilai edukatif mode latihan).*

> ⚠️ **Catatan Sesi 6:** Sebelum masuk kerjaan inti Sesi 6, user minta dibuatkan **Practice tab** (`features/practice/`) di luar rencana sesi manapun — supaya mode latihan bisa dipilih dari dalam app, bukan ganti `home:` di `main.dart` manual. Dikerjakan duluan di sesi yang sama.

> ⚠️ **Catatan revisi (paska Sesi 3, masih berlaku):** Sesi Maestro Mode (sekarang Sesi 10) tidak lagi murni menunggu di ujung roadmap. Breadboard prototype ESP32 + `WebSocketService` (mock server dulu) dimajukan sebagai **track paralel** yang bisa mulai kapan saja setelah Sesi 3, berjalan bersamaan dengan sesi-sesi lain. Belum ada progress konkret di track ini.

> ⚠️ **Catatan Sesi 9 "Dashboard":** belum dibahas kontennya — cuma dipastikan dapat slot sesi tersendiri. Placeholder sudah ada di `HomeScreen` (tab Dashboard menampilkan pesan "Coming soon — Sesi 9"). Yang perlu diputuskan sebelum sesi ini mulai: apa isi Dashboard (ringkasan progress? shortcut ke tiap mode latihan? XP/level summary?), dan apakah butuh desain (Stitch) dulu atau langsung dikerjakan dari deskripsi.

---

## Setup Awal — Checklist Install (Sesi 1, direvisi Sesi 3)

**Tools:**
1. Flutter SDK (stable channel)
2. Editor: VS Code + extension Flutter & Dart (atau Android Studio)
3. Android Studio — untuk Android SDK & emulator
4. Git
5. Verifikasi dengan `flutter doctor`

**Scaffold:**
```
flutter create melody_sense
```

**Dependencies (`pubspec.yaml`) — kondisi aktual setelah Sesi 3:**
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0
  flutter_soloud: ^3.4.6      # ganti dari just_audio (lihat Tech Stack)
  shared_preferences: ^2.3.2
  go_router: ^14.2.7

dev_dependencies:
  build_runner: ^2.4.13
  drift_dev: ^2.20.0
```

**Assets audio (WAJIB ditambahkan manual):**
```yaml
flutter:
  assets:
    - assets/audio/notes/
```
9 file `.mp3` dengan nama persis: `B3.mp3`, `C4.mp3`, `D4.mp3`, `E4.mp3`, `F4.mp3`, `G4.mp3`, `A4.mp3`, `B4.mp3`, `C5.mp3`, ditaruh di `assets/audio/notes/`. **✅ Sudah tersedia sejak Sesi 4** (tim sudah menyediakan sample nada piano, blocker dari Sesi 3 sudah clear). Verifikasi pitch/ketepatan nada dari file ini belum dilaporkan eksplisit — asumsi sudah benar kecuali ada laporan sebaliknya.

Setelah `flutter pub get`, jalankan `flutter run` untuk memastikan project baru berjalan normal sebelum mulai coding fitur.

---

## Ringkasan Sesi 2

Implementasi konkret struktur data lokal (Drift) sudah dibuat sebagai file siap-pakai, mengikuti skema & prinsip Clean Architecture dari Sesi 1:

- **Tabel Drift**: `Sessions`, `Attempts` (FK ke Sessions, cascade delete), `PersonalBests` (mode sebagai PK), `Achievements` — persis skema yang disepakati.
- **DAO**: `SessionDao` (termasuk `watchTotalXp()` — XP dihitung on-the-fly via SUM, bukan kolom terpisah, sesuai keputusan Sesi 1), `AttemptDao` (termasuk `getAccuracyPerNote()` untuk dasar grafik akurasi per nada di Sesi 7), `PersonalBestDao` (`submitScore()` hanya overwrite kalau skor baru lebih tinggi), `AchievementDao` (`incrementProgress()` otomatis unlock saat target tercapai, `seedIfEmpty()` untuk data achievement awal).
- **Domain entities** (`practice_entities.dart`, `progression_entities.dart`): murni Dart, tidak bergantung ke Drift — memenuhi prinsip domain layer testable tanpa Flutter/Drift.
- **Repository interface + impl**: `PracticeRepository` & `ProgressionRepository` sebagai kontrak yang akan dipakai fitur-fitur latihan (Sesi 4-6) tanpa mereka perlu tahu detail Drift.
- **Riverpod providers**: `appDatabaseProvider`, `practiceRepositoryProvider`, `progressionRepositoryProvider`.
- File lengkap ada di folder `lib/core/` (lihat README_SESI2.md untuk struktur & cara pakai).

**Belum diputuskan/dikerjakan di Sesi 2:**
- Daftar konkret Achievement (judul & target progress) — infrastrukturnya (`seedIfEmpty`) sudah siap, datanya belum diisi.
- Unit test untuk repository — ditunda, kemungkinan digabung ke Sesi 4.

---

## Ringkasan Sesi 3

Fokus: **Audio service + virtual piano UI (fondasi Explorer Mode)**. Desain dikirim bertahap satu per satu oleh user (aturan kerja sesi ini), dikerjakan iteratif dengan banyak koreksi berdasarkan hasil testing langsung di Flutter.

**Palet warna resmi ditetapkan** (lihat bagian "Design System") berdasarkan file desain tim — dipakai konsisten di semua widget sejak saat itu.

**Virtual piano (`core/widgets/virtual_piano.dart`):**
- Awalnya pakai `InkWell.onTap` per tuts — ternyata trigger saat jari **dilepas**, bukan saat disentuh. Diperbaiki pakai `onTapDown`.
- Direstrukturisasi total dari "tiap tuts punya gesture detector sendiri" jadi **satu `GestureDetector` membungkus seluruh piano**, menghitung tuts mana yang disentuh dari posisi X — supaya bisa mendukung **swipe/glissando** (satu sentuhan yang digeser lintas beberapa tuts memicu beberapa nada berurutan).
- Highlight tuts sempat "nempel" terus setelah ditekan — diperbaiki dengan `Timer` auto-clear (280ms) di level shell (`ExplorerGameplayScreen`), meniru tuts piano fisik yang kembali normal setelah dilepas.
- Tinggi piano awalnya angka tetap (`height: 220`) → overflow di orientasi landscape (layar pendek). Diperbaiki jadi height opsional (fleksibel via `Expanded`) dengan cap maksimum via `LayoutBuilder`, supaya adaptif tapi tidak memanjang berlebihan.

**Insight penting soal desain:** 4 desain gameplay (05a, 05b, 05c, 05d) awalnya dikira 4 layar berbeda. Setelah dikonfirmasi ke user, ternyata **05a/05b adalah 1 layar yang sama (Explorer Mode) cuma beda orientasi**, begitu juga **05c/05d (Maestro Mode)**. Arsitektur direvisi total: dari 4 screen independen menjadi **2 shell UI reusable** (`ExplorerGameplayScreen`, `MaestroGameplayScreen`) yang otomatis switch layout portrait/landscape pakai `OrientationBuilder`, lalu 4 fitur (note_recognition, interval_training, melody_echo, maestro_challenge) jadi wrapper tipis yang cuma menyuplai data.

**Folder baru yang tidak direncanakan di Sesi 1:** `features/maestro_mode/` — dibutuhkan karena Maestro Mode ternyata butuh layar cross-cutting sendiri (dipakai lintas jenis challenge fisik), bukan spesifik ke satu fitur latihan seperti awalnya diasumsikan.

**Audio Service — perjalanan 2 tahap:**
1. **Tahap 1 (just_audio, sesuai rencana awal):** Implementasi awal pakai `just_audio` dengan pola satu `AudioPlayer` di-preload per nada. Setelah dites: delay masih terasa, dan **tidak bisa "spam" tuts yang sama** (satu player cuma punya satu posisi playback aktif). Sempat dioptimasi (hapus `seek()` dari jalur kritis, konfigurasi `AudioSession` sekali di awal) — membantu sedikit tapi belum cukup.
2. **Tahap 2 (pindah ke flutter_soloud):** Sesuai kontingensi yang sudah diantisipasi sejak Sesi 1 ("kalau kurang responsif, pertimbangkan flutter_soloud"), audio engine diganti total. `flutter_soloud` (native, berbasis SoLoud C++ engine) menyelesaikan dua masalah sekaligus: latensi jauh lebih rendah, dan setiap panggilan `play()` menghasilkan voice instance baru & independen (polyphony) — nada yang sama bisa ditumpuk/di-spam tanpa saling menunggu. API publik `AudioService` (`initialize`/`playNote`/`playSequence`/`dispose`) tidak berubah, jadi provider & screen yang sudah disambungkan sebelumnya tidak perlu diubah.

**Screen yang jadi (lewat shell, bukan dibangun independen):**
- `note_recognition_screen.dart` — Explorer, target nada tunggal, pakai heart/lives, tersambung ke AudioService
- `interval_training_screen.dart` — Explorer, target interval + sequence chip, tersambung ke AudioService
- `melody_echo_screen.dart` — Maestro, mascot + sound wave placeholder, piano non-interaktif (status hardware)
- `maestro_challenge_screen.dart` — Maestro, combo counter + progress persen, piano non-interaktif

Maestro Mode (Melody Echo, Maestro Challenge) **sengaja tidak** disambungkan ke AudioService — karena suara di mode itu keluar dari buzzer piano fisik, bukan speaker HP.

**Belum diselesaikan / catatan untuk sesi berikutnya (dari Sesi 3):**
- **File audio asli (9× `.mp3`) belum ada** — masih placeholder path, `playNote()` no-op sampai file disediakan tim. Ini blocker utama sebelum Explorer Mode bisa benar-benar "berbunyi" dengan nada yang sesungguhnya. *(✅ Diselesaikan di awal Sesi 4)*
- Belum ada verifikasi pitch/kebenaran nada dari file audio (baru dites soal delay, belum soal ketepatan nada) — perlu dicek ulang begitu file asli terpasang.
- Fitur Cheat Note masih tentatif, belum ada progress.
- Ilustrasi maskot di Melody Echo masih placeholder ikon (`Icons.face_rounded`), belum ada aset final.
- Detail payload WebSocket tetap di Sesi 9 sesuai rencana awal — tidak disentuh sesi ini.

---

## Ringkasan Sesi 4

Fokus: **Fitur Note Recognition end-to-end** — jadi pola template untuk fitur latihan lain di Sesi 6. File audio asli (9× `.mp3`) sudah disediakan tim di awal sesi ini, jadi blocker dari Sesi 3 sudah clear.

**Domain logic Note Recognition (`features/note_recognition/presentation/`):**
- `state/note_recognition_state.dart` — state immutable: `targetNote`, `sessionId`, `xp`, hearts, `roundIndex`, `correctCount`, `totalRounds` (10), plus getter `progress`, `accuracy`, `isWin`.
- `controllers/note_recognition_controller.dart` — `StateNotifier` (`StateNotifierProvider.autoDispose`) yang: mulai sesi lewat `PracticeRepository.startSession()` di constructor, generate nada target acak (hindari sama persis dengan ronde sebelumnya), cek jawaban di `submitAnswer()` (log tiap attempt lewat `logAttempt()`, update hearts/xp/correctCount), dan tutup sesi (`finishSession()` + `ProgressionRepository.submitScore()`) begitu hearts habis atau 10 ronde selesai.
- **Aturan sesi:** 10 ronde per sesi, +10 XP per jawaban benar, skor sesi = total XP. Menang = ronde habis dengan hearts tersisa; kalah = hearts habis duluan.

**Shell baru — `core/widgets/session_result_screen.dart` (desain "06 - Session Results"):**
- Dibuat sebagai shell **reusable untuk semua mode latihan** (keputusan eksplisit user), bukan cuma Note Recognition — pola sama seperti `ExplorerGameplayScreen`/`MaestroGameplayScreen`.
- Menerima `isWin`, `accuracy`, `xpEarned`, `streakDays`, `leveledUp`, `onContinue`, `onRetry`.
- **Kasus kalah belum ada desain terpisah** — atas keputusan user, dipakai layout yang sama dengan menang, cuma judul/subtitle/ikon/warna ring diganti (mis. "Perfect Pitch!"/"Nice Job!" vs "Keep Practicing!").
- `streakDays` & `leveledUp` **sudah diisi data asli sejak Sesi 5** — lihat `ProgressionRepository.completeSession()` dan "Status Proyek Saat Ini".
- Bottom nav (Dashboard/Practice/Progression/Stats) di desain dirender **statis/dekoratif**, belum fungsional — nunggu `go_router` dipasang penuh.

**Navigasi hasil sesi:** `NoteRecognitionScreen` pakai `Navigator.pushReplacement` ke `SessionResultScreen` begitu `isSessionOver`. Retry membuka `NoteRecognitionScreen` baru (provider `autoDispose` otomatis bikin controller & sesi baru dari nol — tidak perlu panggil `restart()` manual). Continue → `pop()` balik ke layar sebelum masuk Note Recognition.

**Bug ditemukan & diperbaiki: nada pertama di Note Recognition tidak bersuara.**
- Akar masalah: `audioServiceProvider` (`core/providers/audio_providers.dart`) memanggil `service.initialize()` tanpa `await` sebelum provider mengembalikan instance-nya. `initialize()` meng-*load* 9 file `.mp3` secara async; kalau user menekan tuts SEBELUM proses load itu selesai, `playNote()` menemukan `_sources[note]` masih `null` → no-op senyap (sesuai desain "aman, tidak crash"-nya) — makanya nada pertama tidak berbunyi, nada berikutnya normal.
- Fix: `AudioService` (`core/audio/audio_service.dart`) ditambah `Completer<void> ready` yang selesai begitu semua sample ter-load. Provider baru `audioReadyProvider` (`FutureProvider<void>`) meng-*expose* itu ke UI. `NoteRecognitionScreen` sekarang menahan tampilan piano sampai **dua syarat** terpenuhi: sesi sudah dibuat (`state != null`) DAN `audioReady` bukan `isLoading`.
- **Catatan untuk sesi berikutnya:** fix ini baru dipasang di `NoteRecognitionScreen`. Fitur latihan lain yang nanti langsung memutar audio dari interaksi user (Interval Training, dst. — Sesi 6) perlu pola gate yang sama, atau dipertimbangkan naik ke level lebih tinggi (mis. splash screen yang nunggu `audioReadyProvider` sebelum masuk fitur manapun).

**Desain baru yang diterima sesi ini (belum semua dikerjakan):**
- **06 - Session Results** → dikerjakan sesi ini (lihat atas).
- **07 - Your Progress** (dashboard note accuracy, practice history, badges) → **belum dikerjakan**, cocok untuk Sesi 7 (statistik & grafik progres).
- **05d - Gameplay Session, Maestro Landscape** (bar chart per nada, "C Major Arpeggio") → beda dari `MaestroGameplayScreen` yang sudah dibangun Sesi 3. **Sengaja di-skip** atas instruksi user, dicatat sebagai desain yang perlu diklarifikasi ulang kalau/saat Maestro Mode digarap lagi (Sesi 9).

**Belum diselesaikan / catatan untuk sesi berikutnya:**
- Layar hasil sesi versi "kalah" masih pakai styling generik (ring abu-abu) — kalau tim mau desain kalah yang lebih spesifik nanti, tinggal dikirim.
- `streakDays` dan `leveledUp` di `SessionResultScreen` sudah diisi data asli sejak Sesi 5 (lihat "Status Proyek Saat Ini").
- Fitur Cheat Note masih tentatif, belum ada progress (belum disentuh sejak Sesi 3).
- Verifikasi pitch/ketepatan nada dari file audio asli belum eksplisit dilaporkan.
- Bagian **Mode Disabilitas (Sense Mode)** dan percepatan hardware ESP32 (diputuskan sebelum Sesi 4) **belum disentuh sama sekali** di Sesi 4 — masih di tahap rencana, open questions-nya masih sama.

---

## Ringkasan Sesi 6 (SELESAI — Melody Echo ditunda ke Sesi 10)

**0. Practice tab (di luar rencana sesi, dikerjakan duluan):**
- `features/practice/presentation/screens/practice_screen.dart` — "Pick a Challenge", list 4 mode (card + badge BEGINNER/INTERMEDIATE/ADVANCE) + banner Daily Streak (masih mock).
- Navigasi pakai `Navigator.push` biasa.
- `core/widgets/app_bottom_nav.dart` dibuat reusable — kemudian **direfactor total di Sesi 7** (lihat Ringkasan Sesi 7).

**1. Interval Training — selesai end-to-end:**
- Pola generate target: pasangan **(root note, interval)** dari `kValidIntervalRounds`.
- Alur main: root note diperdengarkan, user menebak nada kedua — dicek via `completeSession()`, identik pola Note Recognition.
- **Bug ditemukan & diperbaiki:** `RoundFeedback` undefined (import transitif issue), provider undefined (analyzer belum refresh).

**2. Rhythm Match — domain logic selesai:**
- Spek: tap tuts yang benar pada waktu yang tepat (gabung nada + ritme), penilaian biner.
- `rhythm_match_state.dart`: tempo `kRhythmMatchBpm = 90`, toleransi `kHitWindowMs = 300`.
- `rhythm_match_controller.dart`: pakai `Timer` untuk auto-Miss + `submitTap()` cek nada DAN timing.
- **Screen (`rhythm_match_screen.dart`) dibuat di awal Sesi 7** — tapi **belum dites** (ada build error import `kAvailableNotes`/`RoundFeedback` yang sudah di-fix tapi belum di-run). Card Rhythm Match di Practice tab sudah **enabled** (`enabled: true` + builder).

**3. `kAvailableNotes` & `RoundFeedback` — BELUM dipindah ke `practice_entities.dart`:**
- Direncanakan dipindah di Sesi 6 tapi kenyataannya **masih di `note_recognition_state.dart`**. Fitur lain (interval_training, rhythm_match) mengimport dengan `show`. Ini technical debt yang aman tapi belum sesuai rencana di context file versi sebelumnya.

**4. Melody Echo — DITUNDA ke Sesi 10** (keputusan user). Masih wrapper statis sejak Sesi 3.

**Catatan teknis:**
- Daily Streak di Practice tab masih **mock** (`_mockStreakDays = 5` hardcoded).
- Constructor 4 screen mode tidak butuh parameter wajib — sudah tervalidasi.

---

## Ringkasan Sesi 7 (SELESAI)

**1. Stats Screen — "Your Progress" (features/stats/):**
- `stats_providers.dart` — 5 Riverpod providers: `noteAccuracyProvider` (FutureProvider), `recentSessionsProvider` (StreamProvider), `achievementsProvider` (StreamProvider), `levelInfoProvider` (StreamProvider), `streakProvider` (FutureProvider).
- `stats_screen.dart` — ConsumerWidget, konten tab (bukan Scaffold mandiri). 4 section:
  1. **Level & Streak card** — level badge, XP progress bar, streak harian
  2. **Note Accuracy bar chart** — custom (Container-based, tanpa package charting), 9 bar untuk B3–C5
  3. **Badges grid** — 2 kolom, tiap badge: ikon, judul, progress bar. Unlocked = warna penuh + centang
  4. **Recent Sessions** — 10 sesi terakhir, mode icon + nama + tanggal relatif + skor + XP
- Semua data dari existing DAO/Repository (Sesi 2 & 5) — **murni presentation layer**, tidak ada perubahan database/domain.

**2. Navbar Architecture Refactor — HomeScreen:**
- **Masalah sebelumnya:** setiap screen (Practice, Stats, SessionResult) punya navbar sendiri → duplikasi, navigasi antar tab pakai push/pop → stack bertambah terus, desain navbar tidak konsisten.
- **Solusi:** `HomeScreen` (`core/widgets/home_screen.dart`) sebagai shell utama:
  - `IndexedStack` menampung 4 tab content (Dashboard placeholder, Practice, Progression placeholder, Stats)
  - Satu `AppBottomNav` di bawah — ganti tab = `setState` ganti index, bukan push halaman
  - Navbar hilang otomatis saat gameplay di-push ON TOP of HomeScreen
- **AppBottomNav redesign** — desain baru mengikuti SessionResult style: ikon + teks label + animated underline indicator (bukan circle background).
- `main.dart`: `home:` sekarang `HomeScreen()` (bukan `PracticeScreen()`).
- PracticeScreen & StatsScreen direfactor: stripped Scaffold/SafeArea/AppBottomNav, sekarang cuma content Column yang hidup di dalam IndexedStack.
- Dashboard & Progression: placeholder inline di HomeScreen ("Coming soon — Sesi 8/9").

**3. Fix SessionResultScreen Continue/Retry Buttons:**
- **Masalah:** `onContinue`/`onRetry` VoidCallback menangkap `context` dari calling screen (NoteRecognitionScreen, dll.) yang sudah di-`pushReplacement` → context mati → tombol tidak bekerja.
- **Fix:** VoidCallbacks diganti `retryScreenBuilder` (`WidgetBuilder?`). SessionResultScreen handle navigasi sendiri pakai context-nya sendiri yang valid:
  - Continue → `Navigator.pop(context)` (kembali ke HomeScreen)
  - Retry → `Navigator.pushReplacement(context, retryScreenBuilder)` (sesi baru)
- `_StaticBottomNav` **dihapus** dari SessionResultScreen — navbar cuma di HomeScreen.
- Semua 3 caller (NoteRecognition, IntervalTraining, RhythmMatch) diupdate: `retryScreenBuilder: (_) => const XxxScreen()`.

**File placeholder_screens.dart** (`features/placeholder/`) — orphan file, dibuat lalu **tidak lagi dipakai** setelah placeholder di-inline ke HomeScreen. Bisa dihapus.

---

## Status Proyek Saat Ini

**Sesi 7 selesai.** Semua dari Sesi 1–7 sudah dikerjakan (kecuali Melody Echo → Sesi 10). Sistem gamifikasi sudah **hidup end-to-end** dan disambungkan ke Note Recognition:
- **Level & XP**: `LevelInfo` (entity baru, domain layer) — formula linear, 100 XP/level, diturunkan on-the-fly dari `getTotalXp()` (bukan kolom terpisah, konsisten dengan keputusan Sesi 1). `ProgressionRepository.getLevelInfo()`/`watchLevelInfo()` ditambahkan.
- **Personal best**: sudah tersambung penuh lewat `completeSession()` (sebelumnya infrastruktur sudah ada dari Sesi 2, sekarang benar-benar dipanggil dari controller).
- **Achievement**: `seedIfEmpty()` akhirnya diisi — 6 achievement konkret didefinisikan di `achievement_definitions.dart` (domain layer, tidak bergantung Drift): *First Notes* (1 sesi), *Dedicated Learner* (5 sesi), *Note Master* (100 nada benar kumulatif), *Perfect Round* (1 sesi tanpa salah), *Century Scorer* (skor ≥100 dalam 1 sesi), *On Fire* (streak 3 hari). `AchievementDao` dapat method baru `getByTitle()` dan `setProgress()` (untuk achievement non-akumulatif seperti streak, yang nilainya bisa naik-turun — beda dari `incrementProgress()` yang cuma nambah).
- **Streak harian**: dihitung dari `SessionDao.getDistinctSessionDays()` (tanggal unik sesi selesai) + logic di `ProgressionRepositoryImpl._computeStreakDays()` — grace period 1 hari (streak masih hidup kalau sesi terakhir kemarin).
- **Satu pintu orkestrasi**: `ProgressionRepository.completeSession()` — dipanggil controller setelah `finishSession()`, menggabungkan submit personal best + deteksi level-up + hitung streak + update semua achievement jadi satu `SessionCompletionResult`.
- `NoteRecognitionController` & `NoteRecognitionScreen` disambungkan: `streakDays`/`leveledUp` di `SessionResultScreen` sekarang data asli, bukan placeholder. Seeding achievement dipanggil (idempotent) di awal `NoteRecognitionController._start()` sebagai solusi sementara — **perlu dipindah ke titik startup app** begitu ada (belum ada `main.dart` terpusat/go_router, lihat catatan di bawah).
- State `NoteRecognitionState` dapat field `completion` (`SessionCompletionResult?`) — UI menunggu field ini terisi sebelum pindah ke `SessionResultScreen`, supaya tidak menampilkan data basi (ada jeda async antara sesi ditandai selesai dan `completeSession()` rampung).

**Belum diputuskan/dikerjakan dari Sesi 5:**
- `isNewPersonalBest` dan `newlyUnlockedAchievements` sudah dihasilkan `completeSession()` tapi **belum ditampilkan di UI** — `SessionResultScreen` belum punya slot visual untuk itu (belum ada desain). Datanya sudah tersedia di `SessionCompletionResult`, tinggal disambungkan begitu desainnya ada.
- Belum ada UI untuk menampilkan `LevelInfo` (progress bar ke level berikutnya) di luar pill "Level Up!" generik yang sudah ada — belum ada layar Dashboard/Progression yang jadi tempatnya.
- Daftar 6 achievement masih draft tim (lihat `achievement_definitions.dart`), belum direview/difinalkan.
- Titik seeding achievement (`seedDefaultAchievementsIfEmpty()`) masih numpang di `NoteRecognitionController._start()`, perlu pindah ke startup app.

**Pola yang sudah settled dan siap dipakai ulang untuk fitur lain:**
- Pola controller: `StateNotifier.autoDispose` yang start session di constructor, cek jawaban, log attempt, tutup sesi lewat `finishSession()` + `completeSession()`. **Terbukti reusable** — dipakai ulang persis untuk Interval Training & Rhythm Match di Sesi 6, cuma beda cara generate target/cek jawaban.
- Shell `SessionResultScreen` — reusable, tinggal disuplai `isWin`/`accuracy`/`xpEarned`/`streakDays`/`leveledUp`.
- Pola gate `audioReadyProvider` untuk fitur yang langsung memutar audio dari interaksi user, dan pola gate serupa (`state.completion == null`) untuk menunggu orkestrasi async selesai sebelum pindah layar.
- Pola "satu pintu orkestrasi" (`completeSession()`) — mode latihan lain tinggal panggil method yang sama dengan `TrainingMode` berbeda, tidak perlu menulis ulang logic personal best/level/streak/achievement.
- Konstanta/entity generik lintas fitur (`kAvailableNotes`, `RoundFeedback`) taruh di `core/domain/entities/practice_entities.dart`, JANGAN pinjam langsung dari state file fitur lain (lihat pelajaran bug di "Ringkasan Sesi 6" poin 1 & 3, dan catatan di "Struktur folder").

### Belum dikerjakan / catatan untuk sesi berikutnya:
- **Melody Echo** — ditunda ke Sesi 10 (bersama Maestro Mode/WebSocket).
- **Rhythm Match** — screen sudah dibuat, card sudah enabled, tapi **belum pernah di-run/dites** oleh user. Perlu ditest kelancarannya.
- **`kAvailableNotes`/`RoundFeedback`** belum dipindah ke `practice_entities.dart`.
- **`placeholder_screens.dart`** — orphan file, bisa dihapus.
## Ringkasan Sesi 8 (SELESAI)

**1. Progression Path UI:**
- `progression_screen.dart` dibuat penuh menggantikan placeholder statis di HomeScreen.
- **Top Stats**: Kartu Day Streak dan Total XP terhubung langsung secara real-time ke database melalui Riverpod (`streakProvider` & `levelInfoProvider`).
- **Jalur Berliku**: Implementasi CustomPainter (`_WindingPathPainter`) untuk menggambar rute jalan berliku putus-putus (*dashed line*) yang dinamis.
- **Level Nodes**: Menampilkan status *Completed* (ikon bintang + label banner Completed), *Active Node* (Current Unit dengan bingkai menyala, shadow, dan play badge merah), serta *Locked Node* (ikon gembok abu-abu) secara adaptif berdasarkan level asli user dari database.
- **Mystery Chest Node**: Menampilkan peti hadiah terkunci di level 10 di bagian paling bawah jalur.

**2. Polish Explorer Mode:**
- Refactor `PracticeScreen` menjadi `ConsumerStatefulWidget` agar bisa mengakses provider Riverpod.
- Menghubungkan banner Daily Streak di tab Practice ke provider `streakProvider` database asli, menghilangkan nilai mock hardcoded (`_mockStreakDays = 5`).

**Kalau chat baru melanjutkan:** **Sesi 10 (Brainstorming Peningkatan UX & Edukasi Latihan)** untuk mode latihan lainnya yang tersisa (Melody Echo, Rhythm Match) — sesi 10 dilanjutkan setelah Sesi 11.1 & 11.2 selesai.

---

## Ringkasan Sesi 9 (SELESAI)

**1. Halaman Dashboard (`dashboard_screen.dart`):**
- Diimplementasikan penuh menggantikan placeholder lama di `HomeScreen`.
- **Level & XP Header**: Menampilkan nama "Hello, Maestro!", level pill badge (diambil dinamis dari Drift via `levelInfoProvider`), dan total XP.
- **Smart Piano Status Card**: Menunjukkan status koneksi piano fisik (*Not Connected*) dan tombol **"Connect"** interaktif yang memunculkan dialog persiapan integrasi WebSocket Sesi 12.
- **2x2 Challenges Grid**: Menyediakan akses cepat ke 4 mode utama (*Note Recognition*, *Interval Training*, *Melody Echo*, dan *Rhythm Match*) yang langsung membuka screen masing-masing saat di-tap.
- **Personal Best Banner**: Card besar di bagian bawah yang menampilkan pencapaian skor tertinggi dan visual linear progress bar.

**2. Halaman Settings (`settings_screen.dart`):**
- Dibuat untuk melengkapi pengaturan volume piano virtual (menggunakan `shared_preferences` untuk simpan dan disetel ke `SoLoud.instance.setGlobalVolume`), toggle Sense Mode (Aksesibilitas), serta opsi *Danger Zone* untuk mereset seluruh database progres dan seeding ulang default achievements.
- Menghubungkan ikon gerigi settings (`Icons.settings_outlined`) di **seluruh tab** (Dashboard, Practice, Progression, Stats) menggunakan `GestureDetector` ke `SettingsScreen`.

**3. Perbaikan & Polish Suara:**
- Meningkatkan volume suara piano virtual ke **1.8x** agar bunyi nada terdengar lebih keras dan mantap.
- Mengatur index halaman utama `HomeScreen` default ke `0` (sehingga langsung membuka Dashboard saat aplikasi dibuka).
- Menghilangkan sisa warning analisis (unused import) agar status proyek tetap 100% bersih.

---

## Ringkasan Sesi 11.1 (SELESAI)

**1. Mekanik Baru Note Recognition:**
- **Ronde Misteri**: 1 ronde acak per sesi dengan hadiah double XP (+20 XP). Ditandai dengan glow & shimmer emas halus pada area prompt nada target.
- **Compare Playback**: Memutar ulang nada target diikuti nada salah yang ditekan user dengan jeda waktu singkat jika jawaban salah.
- **Kunci Input**: Lock gesture piano saat masa transisi ronde (mencegah spamming) dan auto play nada target di awal setiap ronde.

**2. Animasi & Visual (`flutter_animate`):**
- Pop-up feedback badge "Correct!" (bounce) / "Wrong!" (shake) yang memudar setelah 800ms.
- Efek denyut pulsating glow pada prompt card ketika audio diputar (`isPlaying == true`).
- Teks "Round X of Y" bertransisi slide/fade-in dari kiri ketika ronde berganti.
- Tuts piano mengecil (`scale: 0.95` via `AnimatedScale`) saat ditekan untuk efek tactility.
- Animasi entrance di `SessionResultScreen` dan count-up XP menggunakan `TweenAnimationBuilder`.

**3. Pembersihan Hutang Teknis:**
- Pemindahan `kAvailableNotes` dan `RoundFeedback` ke `practice_entities.dart` untuk menghilangkan import silang antar-fitur.
- Perbaikan `widget_test.dart` boilerplate agar test suite `flutter test` berjalan 100% lulus.

---

## Ringkasan Sesi 11.2 (SELESAI)

**1. Mekanik Baru Interval Training:**
- **Ronde Misteri**: 1 ronde acak per sesi dengan hadiah double XP (+20 XP).
- **Compare Playback Adaptif**: Memutar interval target asli, lalu interval buatan user (`rootNote` -> nada salah yang ditekan) untuk melatih telinga.
- **Kunci Input & Autoplay**: Lock tuts piano selama transisi ronde dan autoplay interval di awal setiap ronde.

**2. Visual & Animasi Tambahan:**
- **Visual Jembatan Jarak (Distance Bridge)**: Menggambar garis lengkung (*arch*) dinamis yang menghubungkan tuts `rootNote` dan tuts `lastPressedNote` (jawaban user) di atas piano virtual lengkap dengan label jarak semitone (misalnya "5 semitones") di tengah lengkungan.
- Membawa seluruh polesan visual dari 11.1 (popup feedback, tuts scale press-down, dan progress ronde slide/fade).

---

## Rencana Sesi 11.1: Update Note Recognition (Mekanik & Visual Tambahan)

> Status: ✅ **Selesai.** Hasil brainstorming Sesi 10 (yang dijeda) khusus untuk Note Recognition, disepakati untuk langsung diimplementasi sebagai sub-sesi test case sebelum lanjut brainstorming mode latihan lain. **Desain layout Note Recognition TIDAK berubah** — semua di bawah ini adalah lapisan tambahan (mekanik + animasi) di atas struktur yang sudah ada.

### A. Mekanik Tambahan (nempel ke mekanik inti: dengar satu nada → tekan tombol sesuai)

**1. Nada Misteri per sesi**
- 1 ronde acak per sesi ditandai sebagai "ronde misteri" (index ronde dipilih random saat sesi dimulai, bukan diketahui user sebelumnya)
- Ronde misteri dikasih indikator visual halus (glow/sparkle di area nada, bukan di tombol jawaban — supaya tidak membocorkan jawaban)
- Kalau user jawab **benar** di ronde misteri → dapat bonus (XP ekstra untuk ronde itu)
- Perlu tambahan state: index ronde misteri (ditentukan di awal sesi, disimpan di `NoteRecognitionState`)

**2. Compare Playback saat salah**
- Begitu user menekan tombol yang salah, otomatis mainkan ulang: nada target → jeda singkat → nada yang user tekan
- Tujuan: memperkuat kalibrasi telinga user langsung di momen salah, tanpa perlu teks penjelasan
- Cukup panggil `AudioService` dua kali berurutan dari controller, tidak butuh state baru

### B. Visual/Animasi Tambahan (layout tetap sama, cuma ditambah animasi di atas widget existing)

1. **Teks feedback "Benar!"/"Salah!"** — bounce scale (benar) / shake horizontal (salah), fade-out otomatis
2. **Tombol nada saat diputar** — glow/kedip halus mengikuti timing audio nada target
3. **Tombol nada saat ditekan** — efek ripple/press-down (scale kecil ke dalam)
4. **Tombol nada setelah dijawab** — kedip hijau (benar) / kedip merah (tombol salah yang ditekan), lalu balik normal
5. **Progress ronde** ("Ronde 3/10") — transisi slide/fade saat angka berganti
6. **Transisi antar ronde** — fade/slide halus, delay singkat sebelum nada ronde berikutnya diputar
7. **Indikator ronde misteri** — glow/sparkle halus (lihat poin A.1)
8. **XP akhir sesi** — angka dianimasikan count-up dari 0 ke nilai akhir, bukan langsung muncul

### C. Keputusan Teknis
- **Package animasi:** `flutter_animate` (lihat tabel Tech Stack) — dipilih sebagai opsi "terbaik" dibanding widget animasi manual bawaan Flutter, karena sintaks deklaratif lebih ringkas dan reusable ke mode latihan lain nanti.
- **Tidak ada perubahan desain/layout** — hanya penambahan state (index ronde misteri) dan lapisan animasi di widget yang sudah ada di `note_recognition_screen.dart` & shell `ExplorerGameplayScreen`.

### D. File yang kemungkinan tersentuh
- `pubspec.yaml` — tambah dependency `flutter_animate`
- `note_recognition_state.dart` — tambah field index ronde misteri (dan flag `isMysteryRound` per state kalau perlu)
- `note_recognition_controller.dart` — logic pilih ronde misteri random saat `_start()`, logic compare playback saat jawaban salah, logic bonus XP kalau ronde misteri dijawab benar
- `note_recognition_screen.dart` — pasang animasi di teks feedback, tombol nada, progress ronde, indikator ronde misteri

---

## Rencana Sesi 11.2: Update Interval Training (Mekanik & Visual Tambahan)

> Status: ✅ **Selesai.** Lanjutan pola dari Sesi 11.1 — brainstorming khusus Interval Training dari Sesi 10 (yang masih dijeda untuk Melody Echo & Rhythm Match) langsung diimplementasi sebagai sub-sesi Sesi 11 berikutnya. **Desain layout Interval Training TIDAK berubah** — semua di bawah ini lapisan tambahan (mekanik + animasi) di atas struktur yang sudah ada.

### A. Mekanik Tambahan (nempel ke mekanik inti: dengar dua nada berurutan → tentukan jarak interval)

**1. Interval Misteri per sesi**
- Pola identik dengan "Nada Misteri" di 11.1: 1 ronde acak per sesi ditandai indikator visual halus, jawab benar → bonus XP (+20 XP)
- Reuse logic penuh dari `note_recognition_controller.dart` (pemilihan index ronde random saat sesi mulai), tinggal diterapkan ke `interval_training_controller.dart`

**2. Compare Playback saat salah (versi adaptasi)**
- Beda dari Note Recognition: bukan cuma replay 2 nada target, tapi mainkan **interval target** (2 nada asli berurutan) → jeda → **ilustrasi interval jawaban user** (2 nada baru dimainkan dari root note yang sama, jaraknya sesuai semitone yang user jawab)
- Tujuannya user dengar langsung *bunyi* interval yang salah dia pilih, bukan cuma tahu angkanya meleset
- Butuh helper kecil di controller: fungsi generate nada kedua dari root + jarak semitone (kemungkinan sudah ada polanya di `IntervalDefinition`/`kValidIntervalRounds`)

### B. Visual Tambahan (layout tetap sama, animasi di atas widget existing)

**Reuse penuh dari 11.1** (semua sudah pakai `flutter_animate`, tinggal pasang ulang di `interval_training_screen.dart`):
1. Teks feedback "Benar!"/"Salah!" — bounce/shake, fade-out otomatis
2. Tuts piano mengecil (`AnimatedScale`) saat ditekan
3. Progress ronde ("Ronde 3/10") — transisi slide/fade
4. Transisi antar ronde — fade/slide halus + delay singkat
5. Indikator ronde misteri — glow/sparkle halus
6. XP akhir sesi — count-up dari 0 (di `SessionResultScreen`, sudah reusable di semua mode)

**Baru, spesifik ke Interval Training:**
7. **Visual "jembatan jarak"** — setelah user jawab, animasikan garis/jembatan menghubungkan 2 tuts yang dimainkan di piano, dengan label jarak (misal "5 semitone") muncul di tengah jembatan. Interval yang abstrak jadi terasa *spasial*, bukan cuma angka.

### C. Keputusan Teknis
- Package animasi tetap `flutter_animate` (sudah ada di tech stack sejak 11.1), tidak ada dependency baru.
- Tidak ada perubahan desain/layout Interval Training.

### D. File yang kemungkinan tersentuh
- `interval_training_state.dart` — tambah field index ronde misteri (pola sama seperti `note_recognition_state.dart` di 11.1)
- `interval_training_controller.dart` — logic pilih ronde misteri random, logic compare playback (generate + mainkan interval versi jawaban user), logic bonus XP ronde misteri
- `interval_training_screen.dart` — pasang ulang animasi dari 11.1 + widget baru untuk visual jembatan jarak (kemungkinan custom `CustomPainter` atau `AnimatedContainer` garis penghubung antar posisi tuts)

---

## Diskusi Tambahan (Pra-Sesi 4): Mode Disabilitas & Percepatan Hardware

Diskusi perencanaan (belum coding) yang menghasilkan dua keputusan besar:

1. **Mode Disabilitas dirancang sebagai fitur bernama "Sense Mode"** — satu paket terintegrasi (bukan toggle terpisah tunanetra/low vision) yang menggabungkan kode Braille di tombol fisik piano (hardware) dengan feedback suara penuh/TTS di aplikasi (software). Detail lengkap fitur ada di bagian "Mode Disabilitas (Sense Mode)" di atas.
2. **Timeline hardware dimajukan** — breadboard prototype fungsional berbasis ESP32 (belum rapi, sekadar validasi arsitektur) akan mulai dikerjakan lebih awal, paralel dengan pengembangan software, bukan menunggu lolos tahap 1 kompetisi. Ini membuka jalan agar Sense Mode (khususnya integrasi WebSocket + Braille) tidak sepenuhnya terblokir sampai akhir roadmap.

**Belum diputuskan (masih dibawa, tidak bergerak sejak Sesi 4):**
- Kontrak JSON note event lengkap (field selain `note`/`velocity`)
- Siapa yang pegang firmware ESP32
- Rencana user testing dengan pengguna tunanetra/low vision asli

**Untuk kebutuhan desain (Stitch):** Bagian "Mode Disabilitas (Sense Mode)" di atas berisi daftar fitur lengkap (TTS, Braille, earcon, haptic, Semantics/TalkBack, kontrol kecepatan narasi, high-contrast/font besar) yang bisa dipakai sebagai acuan brief desain layar Sense Mode.

---

## Brainstorming & Implementasi Sesi 10: Sistem Submode untuk Semua Mode Practice

> Status: 🚧 **Implementasi Bertahap.** Note Recognition & Interval Training **selesai 100%**. Rhythm Match dalam tahap brainstorming. Melody Echo belum dimulai.

### Konsep Inti

Setiap mode practice (Note Recognition, Interval Training, Melody Echo, Rhythm Match) memiliki **layar pemilihan submode** sebelum masuk ke gameplay. Free Play **tidak termasuk** — sifatnya sandbox bebas tanpa struktur sesi.

---

### Submode 1: Introduce (Perkenalan)

**Tujuan**: Edukasi teori dasar yang relevan dengan mode tersebut. User memahami *apa* yang akan dilatih sebelum mulai berlatih.

> ⚠️ **KETENTUAN WAJIB FORMAT LAYAR INTRODUCE**:
> Layar Introduce untuk **seluruh mode latihan (Note Recognition, Interval Training, Melody Echo, Rhythm Match)** WAJIB menggunakan format **Slide Carousel (`PageView`)** bertahap, bukan 1 halaman scroll panjang sekaligus.
>
> Setiap layar Introduce terdiri dari:
> 1. **Slide Teori 1 & 2**: Penjelasan materi per bagian secara visual & ringkas.
> 2. **Slide Modul Audio Interaktif**: Grid tombol nada/contoh yang dapat diputar suaranya secara aktif.
> 3. **Indikator Titik (Dot Indicator)** & Navigasi tombol Lanjut/Lewati/Selesai di bagian bawah.

**Konten per mode:**

#### Note Recognition — Introduce ✅ Selesai Diimplementasikan
- Format: Carousel **3 Slide**
  - **Slide 1**: Apa itu Nada (Note) & Notasi Ilmiah
  - **Slide 2**: Mengenal Oktaf (C4 vs C5)
  - **Slide 3**: Modul Interaktif 9 Tombol Nada (B3-C5) dengan Audio Playback
- Tombol "Selesai & Mulai Latihan" menyimpan status baca ke `SharedPreferences` (`introduced_note_recognition`).

#### Interval Training — Introduce ✅ Selesai Diimplementasikan
- Format: Carousel **4 Slide** (ditambah slide baru tentang kualitas interval)
  - **Slide 1**: Apa itu Interval & Semitone? (Penjelasan jarak lompatan nada & semitone sebagai satuan terkecil).
  - **Slide 2**: Kualitas Interval — Major, Minor & Perfect (Penjelasan karakter suara tiap kualitas beserta contoh nada).
    - 🟡 **Major** — Cerah, optimis (C→E, C→A)
    - 🔵 **Minor** — Gelap, melankolis (D→F, C→C#)
    - 🟢 **Perfect** — Stabil, murni (C→G, C→F, Octave)
  - **Slide 3**: Daftar Interval Musik (Tabel jarak semitone dengan badge warna sesuai kualitas: Major/Minor/Perfect).
  - **Slide 4**: Modul Interaktif "Sentuh & Dengarkan Jarak Interval" (Chip pilihan interval, putar audio sampel saat dipilih).
- Tombol "Selesai & Mulai Latihan" menyimpan status baca ke `SharedPreferences` (`introduced_interval_training`).

#### Melody Echo — Introduce (Belum Dimulai)
- Format: Carousel Slide
- Penjelasan Melodi vs Nada Tunggal + Modul Dengarkan Contoh Frase Melodi Pendek.

#### Rhythm Match — Introduce (Desain Disetujui, Implementasi Belum Dimulai)
- Format: Carousel **3 Slide**
  - **Slide 1**: Apa itu Ritme & Tempo? (Visual ilustrasi detak ketukan & satuan BPM)
  - **Slide 2**: Aturan Main Rhythm Match (Metronom 90 BPM, toleransi hit ±300ms)
  - **Slide 3**: Modul Interaktif "Coba Ketukan" (Metronom mini + tombol Tap besar + feedback langsung Hit/Miss)

**Karakteristik Introduce:**
- Bersifat **satu kali baca** — setelah user menyelesaikan introduce, tandai sebagai "sudah dibaca" (persist ke `SharedPreferences`).
- Bisa **diakses ulang** kapan saja dari layar submode (tidak dikunci setelah selesai).
- **Tidak ada skor/XP** — murni edukatif.

---

### Submode 2: Start Practice / Training

**Tujuan**: Mode latihan utama (gameplay loop dengan skor, XP, lives, ronde).

- **Note Recognition** ✅: 10 ronde, 3 nyawa, XP +10 / +20 (Mystery Round), compare playback saat salah.
- **Interval Training** ✅: 10 ronde, 3 nyawa, XP +10 / +20 (Mystery Round), compare playback adaptif + visual jembatan semitone saat salah. Tombol **Next Round (Lanjut Ronde)** melayang saat fase feedback untuk melewati delay transisi.

---

### Submode 3: Guided Practice / Latihan Terbimbing

**Tujuan**: Mode "setengah jalan" antara Introduce (pasif) dan Practice (aktif penuh) — latihan dengan bantuan/hint dinamis.

- **Tanpa penalti nyawa** — latihan berjalan 10 ronde tanpa hearts agar pemula tidak merasa tertekan.

#### Note Recognition — Guided Practice ✅ Selesai
- **Hint 1 tahap**: Setelah 3 detik tanpa jawaban, tuts **target note** menyala hijau terang di piano.

#### Interval Training — Guided Practice ✅ Selesai
- **Hint 2 tahap**:
  - Detik ke-3: Tuts **root note** disorot (jangkar awal interval).
  - Detik ke-6: Tuts **target note** yang benar disorot hijau terang.

#### Rhythm Match — Guided Practice (Desain Disetujui, Implementasi Belum Dimulai)
- **Indikator Visual Ketukan (Visual Beat Helper)**: Animasi lingkaran berdenyut atau bilah visual yang bergerak mengikuti tempo metronom, membantu pengguna "melihat" kapan harus menekan tuts.

---

### Alur UX yang Sudah Berlaku

```
Practice Screen → Tap kartu mode (misal "Note Recognition")
  └── Layar Submode Picker
        ├── 📖 Introduce (Slide Format) — Wajib dibaca sebelum submode lain terbuka
        ├── 🎮 Start Training          — Latihan standar 10 ronde dengan nyawa
        └── 🎯 Guided Practice         — Latihan terbimbing dengan petunjuk otomatis
```

---

### Status Implementasi Sesi 10

| Mode | Submode Picker | Introduce | Start Training | Guided Practice |
|------|:--------------:|:---------:|:--------------:|:---------------:|
| **Note Recognition** | ✅ | ✅ 3 Slide | ✅ | ✅ Hint 1 tahap |
| **Interval Training** | ✅ | ✅ 4 Slide | ✅ + Next Round | ✅ Hint 2 tahap |
| **Rhythm Match** | ⏳ Belum | ⏳ Desain OK | ⏳ Belum | ⏳ Desain OK |
| **Melody Echo** | ❌ | ❌ | ❌ | ❌ |

---

### Keputusan & Rencana Aksi Sesi 10

1. **Introduce bersifat WAJIB & Berformat Slide**:
   - Submode Training/Practice dan Guided Practice akan **terkunci/abu-abu (disabled)** jika user belum pernah menyelesaikan/membaca submode "Introduce" untuk mode tersebut.
   - Layar Introduce di semua mode **wajib berformat Slide Carousel (`PageView`)**.
   - Status kelulusan/membaca Introduce ini disimpan secara persisten di SharedPreferences lewat `educationProgressProvider`.
2. **Submode yang Digunakan**:
   - Terdiri dari 3 submode utama: **Introduce**, **Start Training**, dan **Guided Practice** (Quick Quiz dihapus sesuai permintaan user).
3. **Fitur Tambahan Interval Training (Sudah Diterapkan)**:
   - **Tombol Next Round (Lanjut Ronde)**: Melayang di atas piano saat fase feedback. Memanggil `triggerNextRound()` di controller untuk melewati delay transisi otomatis (1.2s/3.2s) secara instan.
4. **Urutan Implementasi**:
   - ✅ Mode **Note Recognition** selesai 100%.
   - ✅ Mode **Interval Training** selesai 100%.
   - ⏳ Mode **Rhythm Match** — tahap brainstorming. Submode Introduce perlu modul interaktif ketukan (tap timing). Guided Practice perlu indikator visual beat.
   - ❌ Mode **Melody Echo** — belum dimulai sama sekali.

---

## Diskusi & Keputusan Baru (Paska Sesi 10): Piano Kromatik 13 Tuts + Update Komponen Hardware ESP32

> Ditambahkan setelah "Status Implementasi Sesi 10" di atas. Bagian ini murni **diskusi & keputusan baru** — belum ada implementasi kode untuk apa pun yang disebutkan di sini.

### 1. Update Komponen Hardware (Breadboard Prototype ESP32)

Melanjutkan rencana breadboard prototype ESP32 (lihat "Progres Hardware Saat Ini"), diputuskan piano fisik dibuat **kromatik penuh 1 oktaf** (bukan cuma nada natural). Spek breadboard direvisi:

**Komponen tambahan yang dikonfirmasi:**
- **5× push button baru** — untuk 5 tuts sharp/flat (C#/Db, D#/Eb, F#/Gb, G#/Ab, A#/Bb), melengkapi 8 tombol natural yang sudah direncanakan sebelumnya → total **13 tombol** (1 oktaf kromatik penuh)
- **1× ESP32** — sesuai rencana revisi paska Sesi 3

**Keputusan komponen suara:** Tetap pakai **2 buzzer pasif** yang sudah ada dari prototipe Arduino Mega (dipindah ke breadboard ESP32), **bukan** mini speaker. Mini speaker dipertimbangkan tapi tidak dipilih karena butuh modul amplifier tambahan (mis. PAM8403) yang menambah kompleksitas tanpa kebutuhan mendesak saat ini.

**Referensi pemetaan pin (didiskusikan untuk Arduino Mega, sebagai pola acuan — bukan final untuk ESP32):**

| Rentang Pin | Fungsi (versi Mega) |
|---|---|
| 2–10 | 9 tombol nada natural |
| 11–13 | 2 buzzer + 2 tombol (Auto Play, Cheat Note) |
| 22–26 (usulan) | 5 tombol sharp/flat tambahan |

⚠️ **Catatan penting:** Pemetaan di atas untuk Arduino Mega (54 GPIO, longgar). Untuk breadboard **ESP32** (target sebenarnya, ~34 GPIO usable), pemetaan pin **belum final** dan perlu disusun ulang hati-hati karena ESP32 punya pin terlarang/khusus:
- GPIO 6–11 → dipakai flash internal, **jangan dipakai**
- GPIO 34–39 → input-only (aman untuk tombol, tidak bisa untuk output/buzzer)
- GPIO 0, 2, 15 → strapping pins, ada efek saat boot, sebaiknya dihindari

**Belum diputuskan (baru, menyusul open question lama):**
- Pemetaan pin final 13 tombol + 2 buzzer khusus di ESP32
- Notasi nada sharp/flat di kontrak JSON note event — `"C#4"` vs `"Db4"` vs nomor MIDI (makin mendesak karena hardware & software sekarang sama-sama kromatik)
- Siapa di tim yang pegang firmware ESP32 (masih belum dijawab sejak sebelum Sesi 4)

### 2. Update Besar: Piano Virtual Jadi 14 Tuts (B3 + 13 Tuts Kromatik C4–C5)

Supaya Explorer Mode (virtual) mencakup nada bass awal `B3` serta 1 oktaf kromatik penuh (`C4–C5`), piano virtual di aplikasi diperbarui dari **9 tuts natural saja** menjadi **14 tuts total** (9 tuts natural `B3–C5` + 5 tuts hitam `C#4, D#4, F#4, G#4, A#4`).

**Status: ✅ Selesai Diimplementasikan (Sesi 11)**

**Implementasi yang telah diselesaikan:**
- `core/widgets/virtual_piano.dart`: Render tuts hitam (`C#4, D#4, F#4, G#4, A#4`) secara terpresisi di atas 9 tuts putih (`B3–C5`), mendukung gesture touch & glissando.
- `kAvailableNotes` (`practice_entities.dart`) & `kSupportedNotes` (`audio_service.dart`): Diperluas menjadi 14 nada (`['B3', 'C4', 'C#4', 'D4', 'D#4', 'E4', 'F4', 'F#4', 'G4', 'G#4', 'A4', 'A#4', 'B4', 'C5']`).
- **Interval Training**: `kSemitoneByNote` diperbarui mencakup 14 nada (`B3` = -1, `C4` = 0 s/d `C5` = 12), `_buildValidRounds()` otomatis menghasilkan kombinasi interval valid.
- **Note Recognition Introduce**: Modul interaktif diperbarui mencakup 14 nada.
- **Stats Screen**: Bar chart akurasi nada diperluas mencakup 14 nada.
- **Free Play**: Deskripsi nada diperbarui mencakup 14 nada (termasuk B3 & nada sharp/flat).

---

## Implementasi Sesi 12: Mode Rhythm Match (Berbasis Permainan Lagu)

Mode **Rhythm Match** resmi selesai diimplementasikan dengan konsep permainan lagu (*Song-Based Playback*) dari awal sampai akhir tanpa timer paksaan yang melompat sendiri:

### Features & Architecture (Sesi 12):
1. **Lagu Bawaan ([song_entity.dart](file:///e:/Semester%205/KMIPN/melody_sense/lib/features/rhythm_match/domain/entities/song_entity.dart))**:
   - 🟢 **Easy**: *Mary Had a Little Lamb* (26 nada diatonis C4–G4).
   - 🟡 **Medium**: *Happy Birthday* (25 nada, menyertakan tuts hitam `A#4` & oktaf `C5`).
   - 🔴 **Hard**: *Ode to Joy (Beethoven — Tema Utama)* (47 nada simfoni Beethoven B3–G4).
2. **Visual Key & Prompt Format**: Tuts sharp/flat dan kartu prompt menampilkan simbol `#` langsung (misal `C#`, `D#`, `F#`, `G#`, `A#`) tanpa akhiran angka oktaf `#4`.
2. **Tanpa Timeout Auto-Advance**: Pengguna menekan tuts nada demi nada hingga lagu selesai. Sistem mengukur **Waktu Penyelesaian (detik)**, **Akurasi (%)**, dan **Rating Bintang (1–3 ⭐)**.
3. **Submodes**:
   - **Introduce ([rhythm_match_introduce_screen.dart](file:///e:/Semester%205/KMIPN/melody_sense/lib/features/rhythm_match/presentation/screens/rhythm_match_introduce_screen.dart))**: Carousel 3 Slide + Modul Interaktif 4 Ketukan Twinkle Star.
   - **Start Practice ([rhythm_match_song_select_screen.dart](file:///e:/Semester%205/KMIPN/melody_sense/lib/features/rhythm_match/presentation/screens/rhythm_match_song_select_screen.dart))**: Layar pilih lagu dengan rekor waktu/bintang.
   - **Guided Practice ([rhythm_match_gameplay_screen.dart](file:///e:/Semester%205/KMIPN/melody_sense/lib/features/rhythm_match/presentation/screens/rhythm_match_gameplay_screen.dart))**: Latihan terbimbing dengan petunjuk tuts target menyala hijau terang di piano.



