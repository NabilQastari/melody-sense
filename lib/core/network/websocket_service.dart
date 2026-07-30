import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Status koneksi WebSocket ke ESP32 Smart Piano.
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Service yang mengelola koneksi WebSocket persisten ke ESP32 Smart Piano.
///
/// Menerima note events dari hardware (format JSON: `{"note": "C4", "velocity": 100}`)
/// dan meng-*expose* sebagai stream nada (`String`) untuk dikonsumsi Maestro Mode.
///
/// Koneksi bersifat persisten dua arah (bukan REST) agar latensi rendah
/// untuk event tombol real-time — sesuai keputusan arsitektur Sesi 1.
class WebSocketService {
  WebSocketChannel? _channel;
  String? _currentIp;

  final _noteController = StreamController<String>.broadcast();
  final _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();

  WebSocketConnectionState _state = WebSocketConnectionState.disconnected;

  /// Stream nada yang diterima dari ESP32. Emit nama nada (mis. `"C#4"`)
  /// setiap kali tombol fisik ditekan.
  Stream<String> get noteStream => _noteController.stream;

  /// Stream status koneksi, untuk dipakai UI (Dashboard, MaestroGameplayScreen).
  Stream<WebSocketConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Status koneksi saat ini (sync).
  WebSocketConnectionState get connectionState => _state;

  /// IP address ESP32 yang sedang/terakhir terhubung.
  String? get currentIp => _currentIp;

  void _setState(WebSocketConnectionState newState) {
    _state = newState;
    _connectionStateController.add(newState);
  }

  /// Buka koneksi WebSocket ke ESP32 di alamat IP yang diberikan.
  ///
  /// URL target: `ws://{ipAddress}/ws` — sesuai pola umum ESP32 WebSocket
  /// server (AsyncWebServer). Port default 80.
  Future<void> connect(String ipAddress) async {
    // Kalau sudah terhubung ke IP yang sama, abaikan
    if (_state == WebSocketConnectionState.connected &&
        _currentIp == ipAddress) {
      return;
    }

    // Disconnect dulu kalau ada koneksi lama
    await disconnect();

    _currentIp = ipAddress;
    _setState(WebSocketConnectionState.connecting);

    try {
      String cleanAddress = ipAddress.trim();
      if (!cleanAddress.startsWith('ws://') && !cleanAddress.startsWith('wss://')) {
        if (cleanAddress.contains(':')) {
          cleanAddress = 'ws://$cleanAddress';
        } else {
          cleanAddress = 'ws://$cleanAddress:81';
        }
      }
      final uri = Uri.parse(cleanAddress);
      _channel = WebSocketChannel.connect(uri);

      // Tunggu koneksi benar-benar terbuka (handshake selesai)
      await _channel!.ready;

      _setState(WebSocketConnectionState.connected);

      // Listen incoming messages
      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          _setState(WebSocketConnectionState.error);
          _attemptReconnect();
        },
        onDone: () {
          // Koneksi ditutup oleh server atau jaringan
          if (_state != WebSocketConnectionState.disconnected) {
            _setState(WebSocketConnectionState.error);
            _attemptReconnect();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      _setState(WebSocketConnectionState.error);
      _attemptReconnect();
    }
  }

  /// Parse JSON note event dari ESP32.
  ///
  /// Format yang diharapkan: `{"note": "C#4", "velocity": 100}`
  /// Field `velocity` opsional — saat ini diabaikan (piano digital tidak
  /// butuh velocity sensitivity), tapi tetap diterima untuk forward
  /// compatibility kalau nanti firmware mengirimnya.
  void _handleMessage(dynamic data) {
    try {
      String text;
      if (data is String) {
        text = data;
      } else if (data is List<int>) {
        text = utf8.decode(data);
      } else {
        text = data.toString();
      }

      text = text.trim();
      if (text.isEmpty) return;

      String? note;
      if (text.startsWith('{')) {
        final json = jsonDecode(text) as Map<String, dynamic>;
        note = json['note'] as String?;
      } else {
        // Fallback jika firmware mengirim nama nada murni (mis. "C4")
        note = text;
      }

      if (note != null && note.isNotEmpty) {
        _noteController.add(note);
      }
    } catch (_) {
      // Abaikan pesan yang bukan JSON / nada valid
    }
  }

  /// Auto-reconnect sederhana: 1x retry setelah 3 detik.
  ///
  /// Tidak agresif (tidak loop terus-menerus) karena kalau ESP32 mati
  /// atau jaringan putus permanen, reconnect terus-terusan hanya buang
  /// resource. User bisa tap "Connect" lagi secara manual.
  Timer? _reconnectTimer;

  void _attemptReconnect() {
    _reconnectTimer?.cancel();
    if (_currentIp == null) return;

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_state == WebSocketConnectionState.error && _currentIp != null) {
        connect(_currentIp!);
      }
    });
  }

  /// Tutup koneksi WebSocket. Aman dipanggil berkali-kali.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      await _channel?.sink.close();
    } catch (_) {
      // Koneksi mungkin sudah mati — aman diabaikan saat cleanup.
    }
    _channel = null;
    _setState(WebSocketConnectionState.disconnected);
  }

  /// Kirim pesan ke ESP32 (mis. perintah Auto Play dari app).
  void send(String message) {
    if (_state != WebSocketConnectionState.connected || _channel == null) return;
    try {
      _channel!.sink.add(message);
    } catch (_) {
      // Gagal kirim — koneksi mungkin sudah mati.
    }
  }

  /// Bersihkan semua resource. Panggil saat app ditutup (lewat
  /// `ref.onDispose` di provider).
  Future<void> dispose() async {
    await disconnect();
    await _noteController.close();
    await _connectionStateController.close();
  }
}
