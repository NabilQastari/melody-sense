import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/network/websocket_service.dart';

/// Instance tunggal [WebSocketService] untuk seluruh app.
/// Dipakai oleh Dashboard (connect/disconnect) dan Maestro Mode
/// (subscribe ke note events).
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});

/// Stream status koneksi WebSocket, untuk UI reaktif.
/// Dimulai dengan state sync saat ini agar widget yang baru mount
/// langsung dapat nilai (tidak perlu menunggu event stream pertama).
final webSocketConnectionStateProvider =
    StreamProvider<WebSocketConnectionState>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.connectionStateStream;
});

/// Stream nada dari ESP32 (tombol fisik ditekan).
/// Dipakai Maestro Mode untuk menerima input nada real-time.
final webSocketNoteStreamProvider = StreamProvider<String>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.noteStream;
});
