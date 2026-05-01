/// Video Detection BLoC
///
/// Business logic for real-time camera-based YOLO object detection
/// with LLM-powered AI commentary.
///
/// Architecture: BLoC Pattern (Business Logic Component)
/// - Receives Events (inputs from UI or internal timers)
/// - Processes business logic (camera, WebSocket, animations)
/// - Emits States (immutable snapshots consumed by UI)
///
/// Migration from GetX VideoDetectionController:
/// - Old: GetxController with 7 .obs reactive fields, mutated directly
/// - New: BLoC with single immutable state, updated via explicit event handlers
///
/// Key architectural improvements over the GetX version:
/// 1. Testability — every state transition is an event→handler pair,
///    testable in isolation with bloc_test package
/// 2. Traceability — BlocObserver can log every event and state change
///    globally, without touching this file
/// 3. Predictability — no spaghetti reactivity; clear one-directional flow:
///    UI → Event → Handler → State → UI
/// 4. Encapsulation — private events (_prefixed) hide internal plumbing
///    from the outside world; consumers only dispatch public events
///
/// Subsystems managed:
/// - Camera hardware lifecycle (init, capture loop, dispose)
/// - WebSocket connection to Python/FastAPI backend
/// - YOLO detection result parsing and forwarding
/// - AI response routing from LLM Gateway (Gemini/Ollama/cache)
/// - Typewriter character animation (50ms timer)
/// - Cursor blink animation (500ms timer)
///
/// Timer design note:
/// Timers live as private fields in the BLoC — not in State.
/// They are implementation details, not presentation data.
/// Only their observable effects (visibleText, cursorVisible) go into State.

import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../services/websocket_service.dart';

part 'video_detection_event.dart';
part 'video_detection_state.dart';

class VideoDetectionBloc
    extends Bloc<VideoDetectionEvent, VideoDetectionState> {

  // ==================== DEPENDENCIES ====================

  /// Camera controller from the camera package
  /// Exposed as public field so VideoDetectionView can pass it
  /// directly to CameraPreview widget (which requires the controller object)
  late CameraController cameraController;

  /// WebSocket service for bidirectional real-time communication
  /// Connects to Python/FastAPI backend running YOLOv8 + LLM Gateway
  final WebSocketService _wsService = WebSocketService();

  // ==================== PRIVATE INFRASTRUCTURE ====================
  // These are implementation details — not exposed via State.
  // They manage timing and flow control, not presentation data.

  /// Fires every 1 second to trigger frame capture
  /// 1 FPS chosen to balance real-time feel vs network/CPU load:
  /// YOLO inference (~50-100ms) + network RTT (~50-200ms) = ~300ms/frame max
  Timer? _captureTimer;

  /// Fires every 50ms during typewriter animation
  /// Advances visible text by 2 characters per tick → smooth reveal
  Timer? _typewriterTimer;

  /// Fires every 500ms to toggle cursor visibility
  /// Creates the blinking cursor effect independent of typewriter speed
  Timer? _cursorBlinkTimer;

  /// WebSocket stream subscription — held so we can cancel it on cleanup
  StreamSubscription? _wsSubscription;

  /// Prevents concurrent frame processing
  ///
  /// Camera captures can fire before the previous frame's network
  /// round-trip completes. This flag throttles capture to one in-flight
  /// request at a time, preventing queue buildup and memory pressure.
  /// Unlocked when backend responds (in _onDetectionsUpdated).
  bool _isProcessing = false;

  /// The complete AI message text currently being animated
  ///
  /// aiMessageVisible in State holds only what's revealed so far.
  /// This private buffer holds the full text to animate against.
  String _fullMessage = '';

  /// Current character position in the typewriter animation
  /// Increments by 2 per tick (charsPerTick)
  int _typewriterCharIndex = 0;

  // ==================== CONSTRUCTOR ====================

  VideoDetectionBloc() : super(const VideoDetectionState()) {
    // Register all event → handler mappings
    // BLoC processes events sequentially (no race conditions between handlers)
    on<VideoDetectionStarted>(_onStarted);
    on<_DetectionsUpdated>(_onDetectionsUpdated);
    on<_AIResponseReceived>(_onAIResponseReceived);
    on<_TypewriterTicked>(_onTypewriterTicked);
    on<_CursorBlinked>(_onCursorBlinked);
    on<VideoDetectionStopped>(_onStopped);
  }

  // ==================== EVENT HANDLERS ====================

  /// Handles VideoDetectionStarted — full initialization sequence
  ///
  /// Order matters:
  /// 1. Camera first — hardware must be ready before we stream frames
  /// 2. WebSocket second — backend connection to receive detections
  /// 3. Capture loop only if camera succeeded — safe guard against
  ///    attempting to capture from an uninitialized camera
  /// 4. Cursor blink runs independently of capture state
  Future<void> _onStarted(
      VideoDetectionStarted event,
      Emitter<VideoDetectionState> emit,
      ) async {
    await _initCamera(emit);
    await _connectWebSocket();
    _startCursorBlink();

    if (state.isCameraInitialized) {
      _startPeriodicCapture();
    }
  }

  /// Handles _DetectionsUpdated — refreshes bounding box overlay
  ///
  /// Called every frame (~1/sec) with parsed YOLO results.
  /// Also releases the _isProcessing lock so the next frame can be captured.
  ///
  /// Why emit even for empty detections?
  /// Clearing the overlay when nothing is detected is correct behavior —
  /// old bounding boxes shouldn't linger on screen.
  void _onDetectionsUpdated(
      _DetectionsUpdated event,
      Emitter<VideoDetectionState> emit,
      ) {
    emit(state.copyWith(detections: event.detections));
    _isProcessing = false; // Unlock frame capture for next cycle
  }

  /// Handles _AIResponseReceived — initiates typewriter animation
  ///
  /// Spam prevention: if isTyping is already true, the incoming message
  /// is discarded. This is intentional UX — the user needs time to read
  /// the current AI message before a new one appears.
  ///
  /// Updates runtime and cacheHit metadata first so the UI can reflect
  /// the correct source/color before animation begins.
  void _onAIResponseReceived(
      _AIResponseReceived event,
      Emitter<VideoDetectionState> emit,
      ) {
    if (state.isTyping) {
      debugPrint('⏳ AI still typing, ignoring new message');
      return;
    }

    // Update metadata for personality-based UI (colors, ⚡ indicator)
    emit(state.copyWith(
      currentRuntime: event.runtime,
      cacheHit: event.wasCacheHit,
      aiMessageVisible: '',
      isTyping: true,
    ));

    _startTypewriter(event.message);
  }

  /// Handles _TypewriterTicked — advances the character reveal animation
  ///
  /// On each tick, State gets the newly visible substring.
  /// When isComplete is true, isTyping flips to false:
  /// - Cursor animation shifts to steady-on mode
  /// - New AI messages are now accepted again
  void _onTypewriterTicked(
      _TypewriterTicked event,
      Emitter<VideoDetectionState> emit,
      ) {
    if (event.isComplete) {
      emit(state.copyWith(
        aiMessageVisible: event.visibleText,
        isTyping: false,
      ));
    } else {
      emit(state.copyWith(aiMessageVisible: event.visibleText));
    }
  }

  /// Handles _CursorBlinked — toggles cursor visibility
  ///
  /// While typing: cursor alternates visible/hidden every 500ms
  /// When done typing: cursor snaps back to visible and stays
  ///
  /// The "snap back" guard (if (!state.cursorVisible)) prevents
  /// emitting redundant states when already in the correct position.
  void _onCursorBlinked(
      _CursorBlinked event,
      Emitter<VideoDetectionState> emit,
      ) {
    if (state.isTyping) {
      emit(state.copyWith(cursorVisible: !state.cursorVisible));
    } else {
      if (!state.cursorVisible) emit(state.copyWith(cursorVisible: true));
    }
  }

  /// Handles VideoDetectionStopped — explicit teardown
  ///
  /// Provided as a public API for early cleanup if needed.
  /// BLoC.close() also calls _cleanup() so normal widget disposal
  /// is handled automatically by BlocProvider.
  Future<void> _onStopped(
      VideoDetectionStopped event,
      Emitter<VideoDetectionState> emit,
      ) async {
    _cleanup();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize camera hardware and update state on success
  ///
  /// Uses medium resolution preset — balances detection accuracy
  /// vs processing speed and memory footprint.
  /// Audio disabled — we only stream video frames to the backend.
  ///
  /// Takes emit as parameter because async initialization must
  /// happen inside the event handler's Emitter scope.
  Future<void> _initCamera(Emitter<VideoDetectionState> emit) async {
    try {
      final cameras = await availableCameras();

      cameraController = CameraController(
        cameras.first,         // Default to back camera
        ResolutionPreset.medium, // 640x480 — optimal for YOLOv8 input
        enableAudio: false,
      );

      await cameraController.initialize();
      emit(state.copyWith(isCameraInitialized: true));

      debugPrint('✅ Camera ready');
    } catch (e) {
      // Camera failure is non-fatal — app can still show error state
      // In production: emit an error state and show user-facing message
      debugPrint('❌ Camera error: $e');
    }
  }

  /// Connect to WebSocket and set up the data stream listener
  ///
  /// The backend sends two types of messages per frame cycle:
  /// 1. detections (every frame): YOLO bounding boxes → _DetectionsUpdated
  /// 2. ai_response (every 4 frames): LLM message → _AIResponseReceived
  ///
  /// Why dispatch events from the stream listener instead of calling
  /// emit() directly?
  /// The Emitter<S> from the handler is only valid within that handler's
  /// async scope. Stream listeners outlive the handler scope, so we must
  /// use add() to re-enter the event pipeline safely.
  Future<void> _connectWebSocket() async {
    await _wsService.connect();

    _wsSubscription = _wsService.dataStream.listen((data) {
      try {
        // Parse and dispatch detection results for bounding box overlay
        if (data['detections'] != null) {
          final parsed = (data['detections'] as List).map((d) {
            return {
              'label': d['label'] ?? 'Object',
              'confidence': (d['confidence'] ?? 0.0).toDouble(),
              // Normalize bbox values to doubles for BoundingBoxPainter
              'bbox': List<double>.from(d['bbox'].map((v) => v.toDouble())),
            };
          }).toList();

          add(_DetectionsUpdated(parsed));
        }

        // Dispatch AI response for typewriter animation
        // runtime identifies which backend handled it (cache/Gemini/Ollama/etc.)
        if (data['ai_response'] != null) {
          add(_AIResponseReceived(
            message: data['ai_response'] as String,
            runtime: data['runtime'] as String? ?? 'unknown',
            wasCacheHit: data['cache_hit'] as bool? ?? false,
          ));
        }
      } catch (e) {
        debugPrint('❌ Parse error: $e');
        _isProcessing = false; // Release lock even on parse failure
      }
    });
  }

  // ==================== FRAME CAPTURE ====================

  /// Start the 1 FPS periodic frame capture loop
  ///
  /// Timer fires every second regardless of processing state.
  /// The _isProcessing flag inside _captureAndSend() handles throttling —
  /// frames are skipped if the previous one hasn't been acknowledged yet.
  void _startPeriodicCapture() {
    _captureTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _captureAndSend(),
    );
    debugPrint('📸 Capture started (1 FPS)');
  }

  /// Capture a single camera frame and send it to the backend via WebSocket
  ///
  /// Flow:
  /// 1. Check _isProcessing gate — skip if previous frame still in flight
  /// 2. Take picture → XFile (temp file on disk)
  /// 3. Read bytes → Uint8List
  /// 4. Base64 encode on a separate isolate via compute()
  ///    → Keeps main thread unblocked (avoids jank during encoding)
  /// 5. Send via WebSocket as text frame
  ///
  /// _isProcessing is released in _onDetectionsUpdated when backend responds,
  /// or immediately on capture error to prevent permanent lock.
  Future<void> _captureAndSend() async {
    if (_isProcessing || !cameraController.value.isInitialized) return;

    try {
      _isProcessing = true;

      final XFile imageFile = await cameraController.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // compute() runs _encodeBase64 in a separate Dart isolate
      // Prevents base64 encoding (CPU-heavy for large images) from
      // blocking the UI thread and causing frame drops
      final base64Frame = await compute(_encodeBase64, imageBytes);

      _wsService.sendFrame(base64Frame);
      debugPrint('📤 Frame sent (${imageBytes.length} bytes)');
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      _isProcessing = false; // Release lock on error
    }
  }

  // ==================== TYPEWRITER ANIMATION ====================

  /// Start the typewriter character-reveal animation for an AI message
  ///
  /// Animation mechanics:
  /// - Reveals 2 characters every 50ms
  /// - Total duration ≈ message.length / 2 * 50ms
  ///   Example: 100 chars → ~2.5 seconds
  ///
  /// Why dispatch _TypewriterTicked events instead of calling emit() directly?
  /// Timer callbacks run outside the event handler's Emitter scope.
  /// add() safely re-enters the BLoC's event pipeline from any async context.
  ///
  /// Why typewriter instead of instant display?
  /// - Creates a sense of AI "thinking in real time"
  /// - Paces the content so users can absorb it
  /// - More engaging UX — a design principle proven in chat interfaces
  void _startTypewriter(String message) {
    _fullMessage = message;
    _typewriterCharIndex = 0;

    _typewriterTimer?.cancel(); // Cancel any in-progress animation

    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 50),
          (timer) {
        if (_typewriterCharIndex >= _fullMessage.length) {
          // Animation complete — signal via isComplete flag
          timer.cancel();
          add(_TypewriterTicked(
            visibleText: _fullMessage,
            isComplete: true,
          ));
          return;
        }

        // Reveal next 2 characters, clamped to message bounds
        final endIndex =
        (_typewriterCharIndex + 2).clamp(0, _fullMessage.length);

        add(_TypewriterTicked(
          visibleText: _fullMessage.substring(0, endIndex),
          isComplete: false,
        ));

        _typewriterCharIndex = endIndex;
      },
    );
  }

  /// Start the cursor blink timer
  ///
  /// Runs independently of the typewriter timer — cursor blinks
  /// at its own 500ms rhythm regardless of character reveal speed.
  ///
  /// Handler (_onCursorBlinked) checks isTyping to decide behavior:
  /// - isTyping == true → toggle visibility (blinking effect)
  /// - isTyping == false → snap to visible (steady cursor after completion)
  void _startCursorBlink() {
    _cursorBlinkTimer = Timer.periodic(
      const Duration(milliseconds: 500),
          (_) => add(const _CursorBlinked()),
    );
  }

  // ==================== CLEANUP ====================

  /// Release all managed resources
  ///
  /// Critical to call on disposal — resources that leak:
  /// - Camera: system-wide exclusive lock; other apps can't use it
  /// - WebSocket: keeps backend connection alive, drains server resources
  /// - Timers: run in background indefinitely, drain battery and memory
  /// - StreamSubscription: holds reference to stream, preventing GC
  ///
  /// Called both from _onStopped (explicit) and close() (BlocProvider disposal).
  void _cleanup() {
    debugPrint('🧹 Cleaning up resources...');

    _captureTimer?.cancel();
    _captureTimer = null;

    _typewriterTimer?.cancel();
    _typewriterTimer = null;

    _cursorBlinkTimer?.cancel();
    _cursorBlinkTimer = null;

    _wsSubscription?.cancel();
    _wsSubscription = null;

    cameraController.dispose();
    _wsService.dispose();

    debugPrint('✅ Cleanup complete');
  }

  /// Called by BlocProvider when the widget tree disposes this BLoC
  ///
  /// Overriding close() ensures cleanup always runs even if
  /// VideoDetectionStopped event is never explicitly dispatched.
  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }

  // ==================== STATIC HELPERS ====================

  /// Base64 encoder — static so compute() can serialize it to an isolate
  ///
  /// compute() requires a top-level or static function (can't be a closure).
  /// Running this in an isolate offloads CPU-intensive encoding from the UI thread.
  static String _encodeBase64(Uint8List bytes) => base64Encode(bytes);
}