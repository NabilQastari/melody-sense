import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/audio/audio_service.dart';

/// Instance tunggal [AudioService] untuk seluruh app. Otomatis
/// di-preload (initialize) saat pertama kali diakses, dan resource-nya
/// dilepas otomatis saat provider di-dispose.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});