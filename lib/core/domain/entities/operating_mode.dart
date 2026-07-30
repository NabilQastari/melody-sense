/// Operating Mode utama dalam Melody Sense.
/// 
/// Memisahkan 3 cara berinteraksi dengan aplikasi:
/// - [explorer]: Khusus virtual piano di layar HP (input ESP32 diabaikan).
/// - [maestro]: Khusus kontrol perangkat fisik ESP32 dengan tampilan hardware-tailored (TTS nonaktif).
/// - [sense]: Khusus kontrol perangkat fisik ESP32 dengan fitur aksesibilitas penuh (TTS, haptik, audio cues).
enum AppOperatingMode {
  explorer,
  maestro,
  sense,
}
