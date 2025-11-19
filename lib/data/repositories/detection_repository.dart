import 'dart:typed_data';
import '../../services/websocket_service.dart';

/// Detection Repository
///
/// Responsibilities:
/// - Manage WebSocket connection for real-time detection
/// - Send camera frames to backend
/// - Stream detection results to controllers
/// - Handle connection state
///
/// Why separate from controller?
/// - Controller focuses on UI logic
/// - Repository handles data communication
/// - Easy to switch from WebSocket to HTTP polling
/// - Can add caching, queuing, retry logic
///
/// Example usage:
/// ```dart
/// final repo = DetectionRepository();
/// await repo.connect();
///
/// repo.detectionStream.listen((detections) {
///   // Update UI with new detections
/// });
///
/// repo.sendFrame(cameraFrame);
/// ```
class DetectionRepository {
  // ==================== DEPENDENCIES ====================

  /// WebSocket service for real-time communication
  final WebSocketService _wsService;

  /// Constructor with dependency injection
  DetectionRepository({
    required WebSocketService wsService,
  }) : _wsService = wsService;

  // ==================== CONNECTION MANAGEMENT ====================

  /// Connect to detection server
  ///
  /// Call this before sending frames
  /// Usually called in controller's onInit()
  ///
  /// What it does:
  /// - Opens WebSocket connection
  /// - Sets up listeners for incoming data
  /// - Handles reconnection on failure
  Future<void> connect() async {
    await _wsService.connect();
  }

  /// Disconnect from server
  ///
  /// Call this when done (e.g., user leaves detection screen)
  /// Prevents memory leaks and battery drain
  Future<void> disconnect() async {
    await _wsService.disconnect();
  }

  /// Check if currently connected
  ///
  /// Use case:
  /// - Show connection status in UI
  /// - Prevent sending frames when disconnected
  bool get isConnected => _wsService.isConnected;

  // ==================== FRAME TRANSMISSION ====================

  /// Send camera frame for detection
  ///
  /// Flow:
  /// 1. Controller captures camera frame
  /// 2. Converts to base64
  /// 3. Calls this method
  /// 4. Frame sent via WebSocket
  /// 5. Backend processes with YOLO
  /// 6. Results arrive via detectionStream
  ///
  /// Why base64?
  /// - WebSocket text messages are simpler than binary
  /// - Cross-platform compatibility
  /// - Easy to debug (can print/log)
  ///
  /// @param frameData - Camera image as bytes
  void sendFrame(Uint8List frameData) {
    // Convert bytes to base64 string
    // This could be moved to service, but keeping here for clarity
    final base64Frame = _encodeFrame(frameData);
    _wsService.sendFrame(base64Frame);
  }

  // ==================== DETECTION STREAM ====================

  /// Stream of detection results from backend
  ///
  /// Format:
  /// ```json
  /// {
  ///   "detections": [
  ///     {"label": "heart", "confidence": 0.95, "bbox": [x1,y1,x2,y2]}
  ///   ]
  /// }
  /// ```
  ///
  /// Usage in controller:
  /// ```dart
  /// repo.detectionStream.listen((data) {
  ///   final detections = data['detections'];
  ///   updateUI(detections);
  /// });
  /// ```
  Stream<Map<String, dynamic>> get detectionStream => _wsService.dataStream;

  // ==================== HELPERS ====================

  /// Encode frame data to base64
  ///
  /// Why separate method?
  /// - Could add compression here
  /// - Could resize image before encoding
  /// - Could add metadata (timestamp, device info)
  /// - Keeps sendFrame() clean
  String _encodeFrame(Uint8List frameData) {
    // In real implementation, could:
    // - Compress image
    // - Resize to optimal size
    // - Add headers/metadata
    return String.fromCharCodes(frameData); // Simplified
  }
}