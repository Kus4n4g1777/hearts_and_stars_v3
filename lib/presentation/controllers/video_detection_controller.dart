import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/websocket_service.dart';

/// Video Detection Controller
///
/// Responsibilities:
/// 1. Manage camera lifecycle (init, capture, dispose)
/// 2. Connect to WebSocket for real-time detection
/// 3. Send camera frames to backend periodically
/// 4. Receive and store detection results
/// 5. Update UI reactively via GetX observables
///
/// Architecture pattern: MVVM (Model-View-ViewModel)
/// - This controller is the ViewModel
/// - It exposes reactive state to the View
/// - View observes state changes and rebuilds automatically
class VideoDetectionController extends GetxController {
  // ==================== DEPENDENCIES ====================

  /// Camera controller from camera package
  /// Handles low-level camera operations
  late CameraController cameraController;

  /// WebSocket service for real-time communication
  final WebSocketService _wsService = WebSocketService();

  // ==================== REACTIVE STATE ====================

  /// Is camera initialized and ready to use?
  ///
  /// Why observable (.obs)?
  /// - GetX automatically rebuilds widgets when value changes
  /// - No need for setState() or notifyListeners()
  ///
  /// UI usage:
  /// ```dart
  /// Obx(() => controller.isCameraInitialized.value
  ///   ? CameraPreview()
  ///   : LoadingIndicator()
  /// )
  /// ```
  final isCameraInitialized = false.obs;

  /// List of current detections from YOLO
  ///
  /// Format: List of maps matching BoundingBoxPainter expectations
  /// [
  ///   {
  ///     'label': 'heart',
  ///     'confidence': 0.95,
  ///     'bbox': [x1, y1, x2, y2] // normalized coordinates
  ///   }
  /// ]
  final detections = <Map<String, dynamic>>[].obs;

  // ==================== PRIVATE STATE ====================

  /// Timer for periodic frame capture
  /// Why Timer?
  /// - We don't want to send every frame (too much bandwidth)
  /// - 1 FPS is enough for real-time detection
  Timer? _captureTimer;

  /// Flag to prevent sending frames while previous frame is still processing
  /// Why needed?
  /// - Camera can capture faster than network can send
  /// - Prevents queue buildup and memory leaks
  bool _isProcessing = false;

  // ==================== LIFECYCLE ====================

  /// Called when controller is created
  ///
  /// GetX lifecycle:
  /// 1. onInit - called once when controller is first created
  /// 2. onReady - called after widget is rendered
  /// 3. onClose - called when controller is removed from memory
  @override
  void onInit() {
    super.onInit();
    _initCameraAndWebSocket();
  }

  /// Called when controller is disposed
  ///
  /// Critical for:
  /// - Releasing camera (other apps can use it)
  /// - Closing WebSocket (free network resources)
  /// - Canceling timers (prevent background tasks)
  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize both camera and WebSocket
  ///
  /// Why async?
  /// - Camera initialization requires platform channel calls
  /// - WebSocket connection is network I/O
  Future<void> _initCameraAndWebSocket() async {
    // Initialize in order
    await _initCamera();
    await _connectWebSocket();

    // Only start capturing if camera is ready
    if (isCameraInitialized.value) {
      _startPeriodicCapture();
    }
  }

  /// Initialize camera with optimal settings
  ///
  /// Camera setup flow:
  /// 1. Get list of available cameras
  /// 2. Choose first camera (usually back camera)
  /// 3. Create controller with resolution preset
  /// 4. Initialize controller (allocates resources)
  Future<void> _initCamera() async {
    try {
      // Get available cameras (front, back, external)
      final cameras = await availableCameras();

      // Create camera controller
      // ResolutionPreset.medium = balance between quality and performance
      // enableAudio: false = we only need video, not sound
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      // Initialize camera (async platform call)
      await cameraController.initialize();

      // Update reactive state - UI will rebuild automatically
      isCameraInitialized.value = true;

      debugPrint("✅ Camera ready");
    } catch (e) {
      // Common errors:
      // - Permission denied
      // - Camera in use by another app
      // - Invalid camera ID
      debugPrint("❌ Camera error: $e");
    }
  }

  /// Connect to WebSocket and listen for detections
  ///
  /// Why separate from _initCamera?
  /// - Single Responsibility Principle
  /// - Easier to retry connection independently
  /// - Can connect/disconnect without touching camera
  Future<void> _connectWebSocket() async {
    // Initiate connection
    await _wsService.connect();

    // Subscribe to detection stream
    // This is reactive programming:
    // - We don't poll for data
    // - Backend pushes data when available
    // - We react to each new detection
    _wsService.dataStream.listen((data) {
      try {
        // Check if data contains detections
        if (data['detections'] != null) {
          // Convert to format expected by BoundingBoxPainter
          // Why convert?
          // - Backend might send different format
          // - This normalizes data structure
          // - Ensures type safety (double instead of dynamic)
          detections.value = (data['detections'] as List).map((d) {
            return {
              'label': d['label'] ?? 'Object',
              'confidence': (d['confidence'] ?? 0.0).toDouble(),
              'bbox': List<double>.from(d['bbox'].map((v) => v.toDouble())),
            };
          }).toList();

          debugPrint("✅ Got ${detections.length} detections");
        }
      } catch (e) {
        debugPrint("❌ Parse error: $e");
      } finally {
        // Always unlock processing flag
        // Even if parsing fails, we should be ready for next frame
        _isProcessing = false;
      }
    });
  }

  // ==================== FRAME CAPTURE ====================

  /// Start periodic frame capture at 1 FPS
  ///
  /// Why 1 FPS and not 30 FPS?
  /// - YOLO detection takes ~50-100ms
  /// - Network latency adds ~50-200ms
  /// - Sending 30 FPS would queue up frames
  /// - 1 FPS gives smooth real-time experience
  void _startPeriodicCapture() {
    _captureTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _captureAndSend(),
    );
    debugPrint("📸 Capture started (1 FPS)");
  }

  /// Capture single frame and send to backend
  ///
  /// Process:
  /// 1. Check if not already processing (prevent queue)
  /// 2. Capture image from camera
  /// 3. Read image bytes
  /// 4. Convert to base64
  /// 5. Send via WebSocket
  Future<void> _captureAndSend() async {
    // Skip if still processing previous frame
    if (_isProcessing || !cameraController.value.isInitialized) {
      return;
    }

    try {
      // Lock to prevent concurrent captures
      _isProcessing = true;

      // Capture image
      // takePicture() returns XFile (cross-platform file)
      final XFile imageFile = await cameraController.takePicture();

      // Read image as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Convert to base64 for WebSocket transmission
      // Why base64?
      // - WebSocket text frames are simpler than binary
      // - Easy to decode on backend
      // - Works across all platforms
      final base64Frame = base64Encode(imageBytes);

      // Send to backend
      _wsService.sendFrame(base64Frame);

      debugPrint("📤 Frame sent (${imageBytes.length} bytes)");
    } catch (e) {
      // Common errors:
      // - Camera disconnected
      // - Out of memory
      // - File system error
      debugPrint("❌ Capture error: $e");

      // Unlock immediately on error
      _isProcessing = false;
    }
    // Note: _isProcessing is unlocked in WebSocket listener when response arrives
  }

  // ==================== CLEANUP ====================

  /// Release all resources
  ///
  /// Why critical?
  /// - Camera: other apps can't use it if we don't release
  /// - WebSocket: keeps network connection alive
  /// - Timer: runs in background, drains battery
  /// - Memory leaks: unreleased resources accumulate
  void _cleanup() {
    debugPrint("🧹 Cleaning up resources...");

    // Stop frame capture
    _captureTimer?.cancel();
    _captureTimer = null;

    // Release camera
    cameraController.dispose();

    // Close WebSocket
    _wsService.dispose();

    debugPrint("✅ Cleanup complete");
  }
}