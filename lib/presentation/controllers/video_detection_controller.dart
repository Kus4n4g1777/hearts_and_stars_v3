import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/websocket_service.dart';

/// Video Detection Controller
///
/// Purpose:
/// - Manage camera lifecycle (init, capture, dispose)
/// - Handle WebSocket connection for real-time detection
/// - Send camera frames to backend periodically
/// - Receive and display detection results
/// - Handle AI message responses with typewriter effect
///
/// Architecture: MVVM (Model-View-ViewModel)
/// - This is the ViewModel layer
/// - Exposes reactive state to View via GetX observables
/// - View automatically rebuilds when state changes
///
/// State management: GetX (.obs for reactive properties)
/// Communication: WebSocket for bidirectional real-time data
class VideoDetectionController extends GetxController {
  // ==================== DEPENDENCIES ====================

  /// Camera controller from camera package
  /// Handles low-level camera operations (capture, preview)
  late CameraController cameraController;

  /// WebSocket service for real-time communication with backend
  final WebSocketService _wsService = WebSocketService();

  // ==================== REACTIVE STATE (DETECTIONS) ====================

  /// Camera initialization state
  ///
  /// Why observable?
  /// - UI shows loading indicator while false
  /// - Automatically rebuilds when camera is ready
  final isCameraInitialized = false.obs;

  /// Current detections from YOLO model
  ///
  /// Format: List of maps for BoundingBoxPainter
  /// [
  ///   {
  ///     'label': 'heart',
  ///     'confidence': 0.95,
  ///     'bbox': [x1, y1, x2, y2] // normalized [0-1]
  ///   }
  /// ]
  final detections = <Map<String, dynamic>>[].obs;

  // ==================== REACTIVE STATE (AI MESSAGES) ====================

  /// AI message visible to user (with typewriter effect)
  ///
  /// Why separate from _fullMessage?
  /// - This grows character by character
  /// - _fullMessage contains complete text from backend
  final aiMessageVisible = ''.obs;

  /// Is AI currently typing a message?
  ///
  /// Used to:
  /// - Show typing indicator in UI
  /// - Prevent message spam (don't show new message while typing)
  /// - Control cursor visibility
  final isTyping = false.obs;

  /// Current LLM runtime that generated response
  ///
  /// Values: 'gemini-2.5-flash', 'dart', 'go', 'cache', 'ollama'
  /// Used for personality-based UI colors
  final currentRuntime = ''.obs;

  /// Was last response from cache?
  ///
  /// true = LRU cache hit (0.03ms response)
  /// false = LLM call (~3000ms response)
  /// Used to show ⚡ instant indicator
  final cacheHit = false.obs;

  /// Cursor visibility for typewriter animation
  ///
  /// Toggles every 500ms while typing
  /// Creates blinking cursor effect
  final cursorVisible = true.obs;

  // ==================== PRIVATE STATE ====================

  /// Timer for periodic frame capture (1 FPS)
  Timer? _captureTimer;

  /// Flag to prevent concurrent frame processing
  ///
  /// Why needed?
  /// - Camera can capture faster than network can send
  /// - Prevents queue buildup and memory leaks
  /// - Unlocked when backend responds
  bool _isProcessing = false;

  // ==================== PRIVATE STATE (AI) ====================

  /// Complete AI message from backend
  ///
  /// aiMessageVisible grows from this via typewriter effect
  String _fullMessage = '';

  /// Timer for typewriter animation (50ms ticks)
  Timer? _typewriterTimer;

  /// Timer for cursor blinking (500ms toggles)
  Timer? _cursorBlinkTimer;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    _initCameraAndWebSocket();
    _startCursorBlink();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize camera and WebSocket connection
  ///
  /// Order matters:
  /// 1. Camera first (need hardware access)
  /// 2. WebSocket second (need network)
  /// 3. Start capture only if camera ready
  Future<void> _initCameraAndWebSocket() async {
    await _initCamera();
    await _connectWebSocket();

    if (isCameraInitialized.value) {
      _startPeriodicCapture();
    }
  }

  /// Initialize camera with optimal settings
  ///
  /// Settings:
  /// - Resolution: medium (balance quality/performance)
  /// - Audio: disabled (we only need video)
  /// - Camera: first available (usually back camera)
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController.initialize();
      isCameraInitialized.value = true;

      debugPrint("✅ Camera ready");
    } catch (e) {
      debugPrint("❌ Camera error: $e");
    }
  }

  /// Connect to WebSocket and set up data stream listener
  ///
  /// Handles two types of data from backend:
  /// 1. detections (every frame) - YOLO results
  /// 2. ai_response (every 4 frames) - LLM message
  Future<void> _connectWebSocket() async {
    await _wsService.connect();

    _wsService.dataStream.listen((data) {
      try {
        // 1. Always update detections (for bounding boxes)
        if (data['detections'] != null) {
          detections.value = (data['detections'] as List).map((d) {
            return {
              'label': d['label'] ?? 'Object',
              'confidence': (d['confidence'] ?? 0.0).toDouble(),
              'bbox': List<double>.from(d['bbox'].map((v) => v.toDouble())),
            };
          }).toList();

          debugPrint("✅ Got ${detections.length} detections");
        }

        // 2. Handle AI response if present (every 4 frames)
        if (data['ai_response'] != null) {
          _handleAIResponse(
            message: data['ai_response'] as String,
            runtime: data['runtime'] as String? ?? 'unknown',
            wasCacheHit: data['cache_hit'] as bool? ?? false,
          );
        }

      } catch (e) {
        debugPrint("❌ Parse error: $e");
      } finally {
        // Unlock frame processing for next capture
        _isProcessing = false;
      }
    });
  }

  // ==================== FRAME CAPTURE ====================

  /// Start periodic frame capture at 1 FPS
  ///
  /// Why 1 FPS instead of 30 FPS?
  /// - YOLO detection: ~50-100ms per frame
  /// - Network latency: ~50-200ms
  /// - 1 FPS provides smooth real-time experience without overload
  void _startPeriodicCapture() {
    _captureTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _captureAndSend(),
    );
    debugPrint("📸 Capture started (1 FPS)");
  }

  /// Capture single frame and send to backend via WebSocket
  ///
  /// Flow:
  /// 1. Check if not already processing (throttling)
  /// 2. Capture image from camera
  /// 3. Convert to base64 (WebSocket text format)
  /// 4. Send via WebSocket
  /// 5. Wait for response (unlocks _isProcessing)
  Future<void> _captureAndSend() async {
    // Skip if still processing previous frame
    if (_isProcessing || !cameraController.value.isInitialized) {
      return;
    }

    try {
      _isProcessing = true;

      final XFile imageFile = await cameraController.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final base64Frame = base64Encode(imageBytes);

      _wsService.sendFrame(base64Frame);

      debugPrint("📤 Frame sent (${imageBytes.length} bytes)");
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      _isProcessing = false;
    }
  }

  // ==================== AI MESSAGE HANDLING ====================

  /// Handle new AI response from backend
  ///
  /// Prevents message spam:
  /// - If already typing, ignore new message
  /// - User needs time to read current message
  ///
  /// Updates:
  /// - currentRuntime (for UI color)
  /// - cacheHit (for ⚡ indicator)
  /// - Triggers typewriter effect
  void _handleAIResponse({
    required String message,
    required String runtime,
    required bool wasCacheHit,
  }) {
    // Don't show new message if still typing previous one
    if (isTyping.value) {
      debugPrint('⏳ AI still typing, ignoring new message');
      return;
    }

    // Update metadata for UI
    currentRuntime.value = runtime;
    cacheHit.value = wasCacheHit;

    // Start typewriter animation
    _startTypewriter(message);
  }

  /// Typewriter effect for AI messages
  ///
  /// Animation:
  /// - Displays 2 characters every 50ms
  /// - Total time = message.length / 2 * 50ms
  /// - Example: 100 chars = 2.5 seconds
  ///
  /// Why typewriter?
  /// - Creates sense of AI "thinking"
  /// - Gives user time to read
  /// - More engaging than instant text dump
  void _startTypewriter(String message) {
    _fullMessage = message;
    aiMessageVisible.value = '';
    isTyping.value = true;

    int charIndex = 0;
    const charsPerTick = 2; // Speed: 2 chars per tick
    const tickDuration = Duration(milliseconds: 50); // Smooth animation

    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(tickDuration, (timer) {
      if (charIndex >= _fullMessage.length) {
        // Finished typing
        timer.cancel();
        isTyping.value = false;
        debugPrint('✅ Typewriter complete');
        return;
      }

      // Add more characters
      final endIndex = (charIndex + charsPerTick).clamp(0, _fullMessage.length);
      aiMessageVisible.value = _fullMessage.substring(0, endIndex);
      charIndex = endIndex;
    });
  }

  /// Blinking cursor animation for typewriter effect
  ///
  /// Creates realistic typing feel:
  /// - Cursor visible/invisible every 500ms
  /// - Only blinks while isTyping is true
  /// - Stays visible when not typing
  void _startCursorBlink() {
    _cursorBlinkTimer = Timer.periodic(
      const Duration(milliseconds: 500),
          (timer) {
        if (isTyping.value) {
          cursorVisible.value = !cursorVisible.value;
        } else {
          cursorVisible.value = true;
        }
      },
    );
  }

  // ==================== CLEANUP ====================

  /// Release all resources
  ///
  /// Critical for:
  /// - Camera: other apps can't use it if not released
  /// - WebSocket: keeps network connection alive
  /// - Timers: run in background, drain battery
  /// - Memory: unreleased resources accumulate
  void _cleanup() {
    debugPrint("🧹 Cleaning up resources...");

    // Stop frame capture
    _captureTimer?.cancel();
    _captureTimer = null;

    // Stop AI animation timers
    _typewriterTimer?.cancel();
    _typewriterTimer = null;

    _cursorBlinkTimer?.cancel();
    _cursorBlinkTimer = null;

    // Release camera
    cameraController.dispose();

    // Close WebSocket
    _wsService.dispose();

    debugPrint("✅ Cleanup complete");
  }
}