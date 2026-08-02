# 🎹 Panduan Penggunaan Lengkap Aplikasi Melody Sense

**Melody Sense** adalah aplikasi edukasi musik dan latihan pendengaran (*ear training*) interaktif berbasis multisensori. Aplikasi ini dirancang khusus untuk mendukung berbagai gaya belajar—mulai dari antarmuka visual interaktif, integrasi dengan perangkat piano fisik (*ESP32 Smart Piano*), hingga dukungan aksesibilitas penuh bagi penyandang disabilitas netra (**Sense Mode**).

---

## 📋 Daftar Isi
1. [Mode Operasional Aplikasi](#1-mode-operasional-aplikasi)
2. [Modul & Fitur Latihan Utama](#2-modul--fitur-latihan-utama)
3. [Struktur Submode Pembelajaran](#3-struktur-submode-pembelajaran)
4. [Sistem Perhitungan XP & Bonus EXP](#4-sistem-perhitungan-xp--bonus-exp)
5. [Panduan Integrasi Hardware ESP32](#5-panduan-integrasi-hardware-esp32)
6. [Panduan Aksesibilitas (Sense Mode)](#6-panduan-aksesibilitas-sense-mode)
7. [Navigasi & Tampilan Antarmuka](#7-navigasi--tampilan-antarmuka)
8. [Pertanyaan Umum (FAQ)](#8-pertanyaan-umum-faq)

---

## 🌟 1. Mode Operasional Aplikasi

Melody Sense menyediakan **3 Mode Operasional** yang dapat disesuaikan dengan kebutuhan pengguna dan perangkat yang digunakan:

| Mode Operasional | Deskripsi & Target Pengguna | Fitur Utama |
|---|---|---|
| 🧭 **Explorer Mode** | Mode visual interaktif untuk pengguna umum di perangkat smartphone/tablet. | Antarmuka grafis penuh warna (*Whisker Watch Theme*), tuts piano virtual interaktif, indikator nyawa visual, efek partikel, dan animasi responsif. |
| ⚡ **Maestro Mode** | Mode integrasi dengan perangkat piano fisik pintar (*ESP32 Hardware*). | Koneksi *real-time* via WebSocket. Tekanan tuts pada piano fisik langsung terdeteksi di aplikasi dengan *latency* rendah. |
| 🔊 **Sense Mode** | Mode inklusif penuh aksesibilitas untuk penyandang disabilitas netra. | Pemandu suara penuh (*Text-to-Speech / TTS*), umpan balik audio (*earcon*), getaran haptik, kontras tinggi, dan navigasi ramah *screenless*. |

> 💡 **Cara Beralih Mode:** Mode operasional dapat diubah sewaktu-waktu melalui tombol beralih mode pada **Dashboard** atau menu **Pengaturan (Settings)**.

---

## 🎯 2. Modul & Fitur Latihan Utama

Aplikasi menyediakan **4 Modul Latihan Pendengaran**:

### 1. 🎵 **Note Recognition (Tebak Nada)**
- **Fokus Latihan:** Mengenali tinggi-rendah nada tunggal (*Pitch Recognition*).
- **Mekanisme:**
  1. Aplikasi memainkan 1 nada acak (rentang `C4` hingga `C5`).
  2. Pemain menebak tuts yang sesuai pada piano virtual atau tuts fisik ESP32.
  3. Terdapat **Ronde Misteri (*Mystery Round*)** pada ronde acak yang memberikan hadiah **2x XP**.

### 2. 🎼 **Interval Training (Jembatan Jarak Nada)**
- **Fokus Latihan:** Mengenali hubungan dan jarak antara dua nada (*Musical Intervals*).
- **Mekanisme:**
  1. Aplikasi memainkan nada dasar (*Root Note*) diikuti nada target (*Target Note*).
  2. Antarmuka menampilkan visual jembatan jarak (*Distance Bridge*) dan nama intervalnya (misalnya: *Kuint Murni*, *Major Third*).
  3. Pemain menekan nada target yang tepat di piano.

### 3. 🎙️ **Melody Echo (Ingatan Melodi)**
- **Fokus Latihan:** Melatih memori pendengaran (*Auditory Memory*) dalam mengingat urutan nada.
- **Mekanisme:**
  1. Aplikasi memainkan sekelompok nada berurutan (bertahap mulai dari 3 nada pada ronde awal hingga 7 nada di ronde akhir).
  2. Pemain mendengarkan sekuens melodi hingga selesai.
  3. Pemain mengulangi menekan tuts-tuts tersebut dengan urutan yang persis sama.

### 4. 🥁 **Rhythm Match (Permainan Ketukan & Lagu)**
- **Fokus Latihan:** Ketepatan waktu (*timing*), ritme, dan tempo lagu.
- **Mekanisme:**
  1. Pemain memilih lagu latihan (contoh: *Mary Had a Little Lamb*, *Happy Birthday*, atau *Ode to Joy*).
  2. Tekan tuts piano target sesuai ketukan lagu yang mengalir.
  3. Hasil latihan dihitung berdasarkan akurasi %, ketukan *Perfect*, waktu penyelesaian, dan rating bintang (⭐1 hingga ⭐3).

---

## 📚 3. Struktur Submode Pembelajaran

Setiap modul latihan memiliki **3 Submode** berjenjang:

```text
Modul Latihan
 ├── 📖 1. Introduce (Perkenalan Teori & Simulasi)
 ├── ▶️ 2. Start Training (Sesi Ujian / Latihan Utama - 3 Nyawa)
 └── 🎯 3. Guided Practice (Latihan Terbimbing - Petunjuk Otomatis)
```

1. 📖 **Introduce (Perkenalan)**
   - Modul carousel interaktif yang menjelaskan teori dasar musik, contoh audio nada, dan simulasi percobaan interaktif sebelum memasuki latihan.
2. ▶️ **Start Training (Sesi Latihan Utama)**
   - Sesi latihan standar sebanyak 8–10 ronde.
   - Dilengkapi **3 Nyawa**. Jika salah menebak, nyawa berkurang 1 dan aplikasi memutar *Compare Playback* (perbandingan nada benar vs nada yang ditekan).
3. 🎯 **Guided Practice (Latihan Terbimbing)**
   - Sesi latihan tanpa risiko kalah (**tanpa penalti nyawa**).
   - **Petunjuk Otomatis (*Hint*):** Jika pemain terdiam selama 3 detik tanpa menginput nada, tuts piano target akan otomatis disorot warna hijau terang (*Key Highlight*). Pada **Sense Mode**, pemandu suara akan membacakan nada petunjuk tersebut.

---

## 🏆 4. Sistem Perhitungan XP & Bonus EXP

Melody Sense menerapkan sistem akumulasi **Experience Points (XP)** yang adil dan proporsional sesuai tingkat kesulitan latihan:

### 📊 Skala XP Per Modul Latihan:

- **Melody Echo (Ingatan Melodi):**
  - XP ronde meningkat sesuai panjang sekuens melodi:
    - 3 nada: **24 XP** | 4 nada: **28 XP** | 5 nada: **32 XP** | 6 nada: **36 XP** | 7 nada: **40 XP**.
  - ⭐ **Bonus Perfect Recall (+5 XP):** Diberikan per ronde jika menjawab tanpa menekan tombol putar ulang (*Replay*).
  - 🏆 **Bonus Penyelesaian:** `+40 XP` saat menyelesaikan 8 ronde & `+30 XP` tambahan untuk *Flawless Victory* (tanpa kehilangan nyawa).

- **Interval Training (Jarak Nada):**
  - Base XP: **16 XP** per jawaban benar (Ronde Misteri: **32 XP**).
  - ⚡ **Bonus Refleks Cepat (+5 XP):** Menjawab benar dalam waktu `< 2.5 detik`.
  - 🏆 **Bonus Penyelesaian:** `+25 XP` saat selesai & `+35 XP` *Flawless Victory*.

- **Note Recognition (Tebak Nada):**
  - Base XP: **12 XP** per jawaban benar (Ronde Misteri: **24 XP**).
  - ⚡ **Bonus Refleks Cepat (+4 XP):** Menjawab benar dalam waktu `< 2.0 detik`.
  - 🏆 **Bonus Penyelesaian:** `+20 XP` saat selesai & `+30 XP` *Flawless Victory*.

- **Rhythm Match (Ketukan Lagu):**
  - Multiplier Kesulitan Lagu: *Easy* (**1.0x**), *Medium* (**1.3x**), *Hard* (**1.6x**).
  - ⭐ **Full Perfect Combo Bonus (+30 XP):** Diberikan jika seluruh ketukan lagu bernilai *Perfect*.

> ⚖️ **Pengali Submode:** Submode *Guided Practice* memberikan pengali **60% - 70% XP** dari submode standar karena berbantuan petunjuk visual.

---

## 🔌 5. Panduan Integrasi Hardware ESP32

Untuk menghubungkan aplikasi dengan alat piano fisik pintar (*ESP32 Smart Piano*):

1. **Sambungkan Jaringan Wi-Fi:** Pastikan modul ESP32 dan smartphone/tablet terhubung ke jaringan Wi-Fi lokal yang sama.
2. **Buka Menu Stand Status / Settings:** Masuk ke menu Pengaturan di dalam aplikasi untuk memeriksa alokasi IP WebSocket.
3. **Koneksi Otomatis:** Aplikasi akan mendeteksi koneksi WebSocket. Indikator akan berubah menjadi **Terhubung (Connected)**.
4. **Mainkan Maestro / Sense Mode:** Saat terhubung, setiap tekanan tuts fisik pada piano ESP32 akan langsung terkirim dan direspon oleh aplikasi secara *real-time*.

---

## 🔊 6. Panduan Aksesibilitas (Sense Mode)

Mode aksesibilitas dirancang khusus agar dapat dioperasikan secara mandiri tanpa melihat layar:

- **Pemandu Suara (TTS / Text-to-Speech):** Semua petunjuk, navigasi menu, ronde latihan, dan umpan balik jawaban akan dibacakan oleh narator suara.
- **Audio Feedback (Earcon):** Efek suara khusus membedakan instruksi, jawaban benar (nada harmonis), dan jawaban salah.
- **Auto-Play Narasi:** Nada dan melodi latihan diputar secara berkala jika pengguna belum menginput jawaban.
- **Umpan Balik Haptik:** Getaran pada perangkat memberikan konfirmasi fisik saat tuts ditekan.

---

## 📱 7. Navigasi & Tampilan Antarmuka

- **Dashboard Utama:**
  - **Hero Header:** Menampilkan mode aktif, level pengguna, dan total akumulasi XP.
  - **Daily Streak Card:** Menandai konsistensi latihan harian.
  - **Quick Challenge Cards:** Akses cepat menuju 4 modul latihan utama.
- **Layar Statistik (Stats & Achievements):**
  - Grafik akurasi latihan per nada.
  - Daftar pencapaian (*Lencana / Badge*) yang dapat diakses dan dibuka seiring peningkatan level.
- **Layar Hasil Sesi (Session Result):**
  - Menampilkan ringkasan XP yang didapat, akurasi %, peningkatan level (*Level Up*), serta tombol untuk mencoba kembali (*Retry*) atau kembali ke Dashboard.

---

## ❓ 8. Pertanyaan Umum (FAQ)

**Q: Mengapa suara latihan tidak terdengar?**  
*A: Pastikan volume media perangkat kamu tidak dalam kondisi Silent/Mute dan izin akses audio diizinkan.*

**Q: Bisakah saya mengulang lagu atau nada jika lupa?**  
*A: Bisa. Tekan tombol **Dengarkan Ulang / Auto Play** pada layar latihan.*

**Q: Kenapa submode Start Training masih terkunci (disabled)?**  
*A: Kamu perlu setidaknya membuka dan membaca modul **Introduce (Perkenalan)** pada mode tersebut terlebih dahulu.*

**Q: Bagaimana cara mendapatkan file APK untuk di-install?**  
*A: File APK rilis resmi dapat dihasilkan melalui perintah `flutter build apk --release` di terminal project.*
