import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api_constants.dart';

/// WebSocket Service - Handles real-time bidirectional communication
///
/// What is WebSocket?
/// - Unlike HTTP (request → response), WebSocket keeps connection open
/// - Server can push data to client anytime (no polling needed)
/// - Perfect for real-time features: chat, live updates, streaming
///
/// In this app:
/// - Client sends camera frames (base64 images)
/// - Server responds with YOLO detections in real-time
///
/// Key features:
/// - Auto-reconnection if connection drops
/// - Stream-based API (reactive programming)
/// - Proper cleanup to avoid memory leaks
class WebSocketService {
  // WebSocket channel for bidirectional communication
  WebSocketChannel? _channel;

  // Stream controller to broadcast incoming data to listeners
  // Why StreamController?
  // - Multiple widgets can listen to the same stream
  // - Decouples data source from data consumers
  StreamController<Map<String, dynamic>>? _dataController;

  // Timer for scheduling reconnection attempts
  Timer? _reconnectTimer;

  // Connection state tracking
  bool _isConnected = false;
  bool _shouldReconnect = true; // Flag to stop reconnection on manual disconnect
  int _reconnectAttempts = 0;

  // Configuration constants
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  /// Get stream of incoming detection data
  ///
  /// Usage in controller:
  /// ```dart
  /// _wsService.dataStream.listen((data) {
  ///   // Handle new detections
  /// });
  /// ```
  Stream<Map<String, dynamic>> get dataStream {
    // Lazy initialization - only create if someone subscribes
    _dataController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _dataController!.stream;
  }

  /// Check if WebSocket is currently connected
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  ///
  /// Connection flow:
  /// 1. Check if already connected (avoid duplicate connections)
  /// 2. Create WebSocket channel with server URL
  /// 3. Listen to incoming messages
  /// 4. Handle errors and disconnections
  /// 5. Reset reconnect counter on success
  Future<void> connect() async {
    // Prevent duplicate connections
    if (_isConnected) {
      debugPrint('⚠️ WebSocket already connected');
      return;
    }

    try {
      // Build WebSocket URL (ws:// or wss:// for secure)
      final wsUrl = '${ApiConstants.wsUrl}${ApiConstants.wsDashboardEndpoint}';
      debugPrint('🔌 Connecting to WebSocket: $wsUrl');

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to incoming messages
      // Why separate handlers?
      // - _onMessage: handle normal data
      // - _onError: handle connection errors
      // - _onDone: handle clean disconnections
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false, // Keep listening even if parse error occurs
      );

      // Update state
      _isConnected = true;
      _reconnectAttempts = 0; // Reset counter on successful connection

      debugPrint('✅ WebSocket connected');
    } catch (e) {
      debugPrint('❌ WebSocket failed: $e');
      _scheduleReconnect();
    }
  }

  /// Send camera frame to backend for detection
  ///
  /// Why base64?
  /// - WebSocket text messages are easier than binary
  /// - Backend can easily decode base64 to image
  /// - Cross-platform compatibility
  ///
  /// @param base64Frame - Camera image encoded as base64 string
  void sendFrame(String base64Frame) {
    // Check if connection is alive
    if (_isConnected && _channel != null) {
      try {
        // Send data through WebSocket
        _channel!.sink.add(base64Frame);
        debugPrint('📤 Frame sent');
      } catch (e) {
        debugPrint('❌ Send failed: $e');
      }
    } else {
      debugPrint('⚠️ Cannot send: not connected');
    }
  }

  /// Handle incoming WebSocket messages
  ///
  /// Expected message format from backend:
  /// {
  ///   "detections": [
  ///     {
  ///       "label": "heart",
  ///       "confidence": 0.95,
  ///       "bbox": [0.1, 0.2, 0.3, 0.4]
  ///     }
  ///   ]
  /// }
  void _onMessage(dynamic message) {
    try {
      // Parse JSON string to Map
      final data = jsonDecode(message as String);

      // Check if message contains detections
      if (data['detections'] != null) {
        // Broadcast to all listeners via stream
        _dataController?.add(data);
        debugPrint('✅ Got ${(data['detections'] as List).length} detections');
      }
    } catch (e) {
      // Log parse errors but don't crash
      debugPrint('❌ Parse error: $e');
    }
  }

  /// Handle WebSocket errors
  ///
  /// Common errors:
  /// - Network disconnection
  /// - Server crash
  /// - Invalid data format
  void _onError(error) {
    debugPrint('❌ WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  ///
  /// This is called when connection closes cleanly
  /// (vs _onError which handles unexpected errors)
  void _onDone() {
    debugPrint('🔌 WebSocket closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Schedule automatic reconnection attempt
  ///
  /// Why auto-reconnect?
  /// - Network can be unstable (WiFi drops, mobile data switches)
  /// - Backend might restart
  /// - Improves user experience (no manual reconnection needed)
  ///
  /// Strategy:
  /// - Try up to 5 times
  /// - Wait 3 seconds between attempts
  /// - Give up after max attempts (avoid infinite loop)
  void _scheduleReconnect() {
    // Don't reconnect if manually disconnected
    if (!_shouldReconnect) return;

    // Give up after max attempts
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('❌ Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;

    // Cancel previous timer if exists
    _reconnectTimer?.cancel();

    // Schedule reconnection after delay
    _reconnectTimer = Timer(_reconnectDelay, () => connect());

    debugPrint('🔄 Reconnect scheduled (attempt $_reconnectAttempts/$_maxReconnectAttempts)');
  }

  /// Manually disconnect WebSocket
  ///
  /// Use cases:
  /// - User navigates away from detection screen
  /// - App goes to background
  /// - User logs out
  ///
  /// Why proper cleanup?
  /// - Avoid memory leaks
  /// - Release system resources
  /// - Prevent background battery drain
  Future<void> disconnect() async {
    debugPrint('🧹 Disconnecting WebSocket...');

    // Prevent auto-reconnection
    _shouldReconnect = false;
    _isConnected = false;

    // Cancel timers
    _reconnectTimer?.cancel();

    // Close connections
    await _channel?.sink.close();
    await _dataController?.close();

    // Clear references
    _channel = null;
    _dataController = null;

    debugPrint('✅ Disconnected');
  }

  /// Dispose - called when service is no longer needed
  void dispose() {
    disconnect();
  }
}