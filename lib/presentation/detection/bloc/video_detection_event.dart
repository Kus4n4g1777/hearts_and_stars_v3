/// Video Detection Events
///
/// Defines all possible inputs to the VideoDetectionBloc.
///
/// Architecture: BLoC Pattern (Business Logic Component)
/// - Events are the INPUT layer — triggered by UI or internal timers
/// - They are immutable value objects (Equatable)
/// - The BLoC reacts to events and emits new states
///
/// Migration from GetX:
/// - Old: Direct mutation via .obs (e.g., isCameraInitialized.value = true)
/// - New: Dispatching events → BLoC processes → emits new state
///   This makes state transitions explicit, testable, and traceable.
///
/// Event taxonomy:
/// - Public events (PascalCase): triggered by external code (UI, services)
/// - Private events (_prefixed): triggered internally by BLoC timers/streams
///   Keeps internal plumbing encapsulated — consumers only dispatch public events

part of 'video_detection_bloc.dart';

abstract class VideoDetectionEvent extends Equatable {
  const VideoDetectionEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when VideoDetectionView mounts
///
/// Kicks off the full initialization sequence:
/// 1. Camera hardware access
/// 2. WebSocket connection to backend
/// 3. Periodic frame capture loop
/// 4. Cursor blink animation
///
/// Equivalent to GetxController.onInit() in the old architecture
class VideoDetectionStarted extends VideoDetectionEvent {
  const VideoDetectionStarted();
}

/// Triggered when WebSocket receives YOLO detection results
///
/// Private (_prefixed) because only the BLoC's internal WS listener
/// should dispatch this — not the UI layer.
///
/// Carries parsed detection data ready for rendering:
/// [{ 'label': 'heart', 'confidence': 0.97, 'bbox': [x1,y1,x2,y2] }]
///
/// Why not update state directly in the stream listener?
/// BLoC enforces that ALL state changes go through the event→handler pipeline.
/// This makes the data flow debuggable and testable.
class _DetectionsUpdated extends VideoDetectionEvent {
  final List<Map<String, dynamic>> detections;

  const _DetectionsUpdated(this.detections);

  @override
  List<Object?> get props => [detections];
}

/// Triggered when backend sends an LLM-generated AI response
///
/// Private — dispatched by the internal WebSocket stream listener.
/// Only fires every 4 frames (backend throttling), not on every detection.
///
/// Carries the full message and metadata:
/// - [message]: Full text to display via typewriter animation
/// - [runtime]: Which LLM handled it ('gemini-2.5-flash', 'ollama', 'cache', etc.)
/// - [wasCacheHit]: true if response came from Redis LRU cache (~0.03ms vs ~3000ms)
///
/// The runtime and cache metadata drive the personality-based UI color system
/// and the ⚡ instant indicator.
class _AIResponseReceived extends VideoDetectionEvent {
  final String message;
  final String runtime;
  final bool wasCacheHit;

  const _AIResponseReceived({
    required this.message,
    required this.runtime,
    required this.wasCacheHit,
  });

  @override
  List<Object?> get props => [message, runtime, wasCacheHit];
}

/// Triggered every 50ms by the internal typewriter timer
///
/// Private — only the BLoC's _typewriterTimer dispatches this.
///
/// Why emit character-by-character through the event system?
/// Every UI update must go through state — this keeps the typewriter
/// animation observable, testable, and pausable/cancelable via standard
/// BLoC event handling.
///
/// [visibleText]: The substring of the full message revealed so far
/// [isComplete]: When true, signals the typewriter is done and isTyping → false
class _TypewriterTicked extends VideoDetectionEvent {
  final String visibleText;
  final bool isComplete;

  const _TypewriterTicked({
    required this.visibleText,
    required this.isComplete,
  });

  @override
  List<Object?> get props => [visibleText, isComplete];
}

/// Triggered every 500ms by the internal cursor blink timer
///
/// Private — only the BLoC's _cursorBlinkTimer dispatches this.
///
/// Produces the blinking text cursor effect in the AI message panel.
/// The handler only toggles when isTyping == true — cursor stays
/// solid when animation is complete (gives a "done" visual cue).
class _CursorBlinked extends VideoDetectionEvent {
  const _CursorBlinked();
}

/// Triggered when VideoDetectionView unmounts
///
/// Initiates full resource cleanup:
/// - Cancels frame capture timer
/// - Cancels typewriter and cursor timers
/// - Cancels WebSocket stream subscription
/// - Disposes camera hardware
/// - Closes WebSocket connection
///
/// Note: BLoC.close() also calls _cleanup(), so this event is provided
/// as an explicit public API for early teardown if needed.
class VideoDetectionStopped extends VideoDetectionEvent {
  const VideoDetectionStopped();
}