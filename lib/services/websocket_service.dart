import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api_constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _dataController;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  Stream<Map<String, dynamic>> get dataStream {
    _dataController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _dataController!.stream;
  }

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) {
      debugPrint('⚠️ WebSocket already connected');
      return;
    }

    try {
      final wsUrl = '${ApiConstants.wsUrl}${ApiConstants.wsDashboardEndpoint}';
      debugPrint('🔌 Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      debugPrint('✅ WebSocket connected');
    } catch (e) {
      debugPrint('❌ WebSocket failed: $e');
      _scheduleReconnect();
    }
  }

  void sendFrame(String base64Frame) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(base64Frame);
        debugPrint('📤 Frame sent');
      } catch (e) {
        debugPrint('❌ Send failed: $e');
      }
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      if (data['detections'] != null) {
        _dataController?.add(data);
        debugPrint('✅ Got ${(data['detections'] as List).length} detections');
      }
    } catch (e) {
      debugPrint('❌ Parse error: $e');
    }
  }

  void _onError(error) {
    debugPrint('❌ WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('🔌 WebSocket closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () => connect());
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _isConnected = false;
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    await _dataController?.close();
    _channel = null;
    _dataController = null;
  }

  void dispose() {
    disconnect();
  }
}