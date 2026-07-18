import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/audio/audio_service.dart';

/// Instance tunggal [AudioService] untuk seluruh app. `initialize()`
/// sengaja TIDAK di-`await` di sini (provider ini harus tetap
/// sinkron) — layar yang butuh audio WAJIB menunggu lewat
/// [audioReadyProvider] sebelum mengizinkan user berinteraksi,
/// supaya tidak terulang bug "nada pertama senyap" (playNote
/// terpanggil sebelum load selesai).
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});

/// Selesai (punya value) begitu semua sample nada sudah ter-load dan
/// [AudioService] siap dipakai. Watch ini di layar manapun yang
/// menyambungkan tuts piano ke audio, dan tahan interaksi user
/// (tampilkan loading) selama masih `isLoading`.
final audioReadyProvider = FutureProvider<void>((ref) {
  return ref.watch(audioServiceProvider).ready;
});