/// Video Detection State
///
/// Single immutable snapshot of everything the UI needs to render.
///
/// Architecture: BLoC Pattern — Immutable State
/// - State is NEVER mutated directly
/// - Every change produces a new state via copyWith()
/// - Flutter/BLoC diffs old vs new state to decide what to rebuild
///
/// Migration from GetX:
/// - Old: 7 separate .obs observables scattered across the controller
///   (isCameraInitialized.obs, detections.obs, aiMessageVisible.obs, etc.)
/// - New: One cohesive state object — all fields travel together,
///   making it trivial to snapshot, replay, or unit-test the entire UI state
///
/// Why Equatable?
/// - BLoC uses == to check if state changed before emitting
/// - Without Equatable, every emit() would trigger a rebuild even with identical data
/// - Equatable auto-generates == based on props list
///
/// Design note on aiMessageVisible vs _fullMessage:
/// - State only holds what the UI needs RIGHT NOW (visibleText)
/// - The full message buffer lives in the BLoC as private state
/// - Clean separation: State = presentation data, BLoC = logic

part of 'video_detection_bloc.dart';

class VideoDetectionState extends Equatable {
  /// Whether the camera hardware has been initialized and is ready to preview
  ///
  /// false → show loading spinner
  /// true → render camera preview and overlays
  final bool isCameraInitialized;

  /// Current YOLO detection results from the backend
  ///
  /// Format: [{ 'label': String, 'confidence': double, 'bbox': List<double> }]
  /// bbox is normalized [0-1] coordinates: [x1, y1, x2, y2]
  /// Consumed by BoundingBoxPainter for overlay rendering
  final List<Map<String, dynamic>> detections;

  /// The portion of the AI message currently visible to the user
  ///
  /// Grows character by character via typewriter animation.
  /// Starts empty, ends at the full message text.
  /// Separate from _fullMessage (which lives in BLoC) — UI only
  /// cares about what to display right now.
  final String aiMessageVisible;

  /// Whether the typewriter animation is currently running
  ///
  /// true → show blinking cursor, suppress new AI messages
  /// false → animation complete, cursor stays solid
  ///
  /// Also used as a spam-prevention gate: if isTyping is true when a
  /// new AI response arrives, the new message is discarded. The user
  /// needs time to read the current one.
  final bool isTyping;

  /// Which LLM runtime generated the current AI response
  ///
  /// Possible values: 'gemini-2.5-flash', 'dart', 'go', 'cache', 'ollama'
  /// Drives personality-based UI theming (colors, icons per runtime)
  /// Part of the LLM Gateway architecture: multiple runtimes with Redis LRU
  /// caching for ~80% hit rate, reducing latency from ~3000ms to ~300ms
  final String currentRuntime;

  /// Whether the last AI response was served from Redis LRU cache
  ///
  /// true → ⚡ instant indicator (response in ~0.03ms from cache)
  /// false → full LLM call (~3000ms)
  ///
  /// This metric demonstrates the LLM Gateway's caching layer performance
  final bool cacheHit;

  /// Current visibility of the blinking text cursor
  ///
  /// Toggles every 500ms while isTyping is true.
  /// Stays true (visible) when animation completes.
  /// Consumed by AIMessagePanel to render the cursor character.
  final bool cursorVisible;

  const VideoDetectionState({
    this.isCameraInitialized = false,
    this.detections = const [],
    this.aiMessageVisible = '',
    this.isTyping = false,
    this.currentRuntime = '',
    this.cacheHit = false,
    this.cursorVisible = true,
  });

  /// Produces a new state with only the specified fields changed
  ///
  /// Pattern: copyWith() is the standard immutable update pattern in BLoC.
  /// Named parameters with null defaults mean "keep existing value if not provided".
  ///
  /// Example:
  /// ```dart
  /// emit(state.copyWith(isCameraInitialized: true));
  /// // → All other fields preserved, only isCameraInitialized changes
  /// ```
  ///
  /// Why not just mutate?
  /// Immutability enables time-travel debugging, state replay, and
  /// guarantees that past state snapshots are never corrupted.
  VideoDetectionState copyWith({
    bool? isCameraInitialized,
    List<Map<String, dynamic>>? detections,
    String? aiMessageVisible,
    bool? isTyping,
    String? currentRuntime,
    bool? cacheHit,
    bool? cursorVisible,
  }) {
    return VideoDetectionState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      detections: detections ?? this.detections,
      aiMessageVisible: aiMessageVisible ?? this.aiMessageVisible,
      isTyping: isTyping ?? this.isTyping,
      currentRuntime: currentRuntime ?? this.currentRuntime,
      cacheHit: cacheHit ?? this.cacheHit,
      cursorVisible: cursorVisible ?? this.cursorVisible,
    );
  }

  /// Fields BLoC uses for equality comparison before deciding to emit
  ///
  /// All 7 fields are included — any change triggers a UI rebuild.
  /// For performance-sensitive subtrees, use context.select() in the
  /// View to subscribe only to specific fields (see VideoDetectionView).
  @override
  List<Object?> get props => [
    isCameraInitialized,
    detections,
    aiMessageVisible,
    isTyping,
    currentRuntime,
    cacheHit,
    cursorVisible,
  ];
}