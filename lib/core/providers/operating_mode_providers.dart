import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/operating_mode.dart';

/// Provider state acuan mode interaksi utama yang sedang aktif (Explorer, Maestro, atau Sense).
final operatingModeProvider = StateProvider<AppOperatingMode>((ref) {
  return AppOperatingMode.explorer;
});
