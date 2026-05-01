/// AI Message Panel Widget
///
/// Displays LLM-generated AI responses with typewriter animation,
/// personality-based color theming, and real-time status indicators.
///
/// Architecture: BLoC Pattern — Stateless Presentation Widget
/// - Zero business logic — purely transforms State into UI
/// - Subscribes to VideoDetectionBloc via context.select()
/// - Lives in the widget tree below VideoDetectionView's BlocProvider
///
/// Migration from GetX:
/// - Old: Get.find<VideoDetectionController>() → tight coupling to GetX
///   The widget reached globally into the GetX service locator.
///   Any rename or removal of the controller would silently break this widget.
/// - New: context.select((VideoDetectionBloc b) => b.state.field)
///   The widget declares its exact data dependencies explicitly.
///   The BlocProvider in VideoDetectionView guarantees the BLoC is in scope.
///
/// Rebuild optimization with context.select():
/// This widget reads 5 fields from state. Rather than one BlocBuilder
/// that rebuilds on ANY state change, we use a single select on a derived
/// "render data" record. The widget only rebuilds when one of these
/// 5 specific fields changes — camera initialization and detection updates
/// (which fire every second) don't cause this widget to rebuild at all.
///
/// Features:
/// - Animated appearance/disappearance via AnimatedContainer
/// - Gradient background with runtime-specific personality colors
/// - Typing indicator with spinner (visible during typewriter animation)
/// - Cache hit indicator (⚡ Instant) for Redis LRU cache responses
/// - Blinking cursor synchronized with typewriter reveal
///
/// Visual design:
/// - Gradient from black to personality color for depth
/// - Border color shifts during typing for tactile feedback
/// - Box shadow tinted with personality color for modern glow effect
/// - Each LLM runtime has a distinct color identity (see _getPersonalityColor)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../detection/bloc/video_detection_bloc.dart';

class AIMessagePanel extends StatelessWidget {
  const AIMessagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Subscribe to exactly the 5 fields this widget needs.
    //
    // Using a Record (Dart 3+) as the selected value lets us batch
    // multiple fields into one select() call while still getting
    // granular rebuild control — this widget won't rebuild for
    // detection updates or camera state changes.
    //
    // Alternative: separate context.select() per field, but that
    // creates multiple widget subscriptions. The Record approach
    // is cleaner and performs identically.
    final (
    visibleMessage,
    isTyping,
    cursorVisible,
    runtime,
    isCacheHit,
    ) = context.select((VideoDetectionBloc bloc) => (
    bloc.state.aiMessageVisible,
    bloc.state.isTyping,
    bloc.state.cursorVisible,
    bloc.state.currentRuntime,
    bloc.state.cacheHit,
    ));

    // Don't allocate any widget tree when there's nothing to show.
    // SizedBox.shrink() is the canonical Flutter no-op widget —
    // zero size, zero paint cost.
    if (visibleMessage.isEmpty) return const SizedBox.shrink();

    // Resolve personality color once — used in 4 places below
    final personalityColor = _getPersonalityColor(runtime);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Gradient from neutral black to personality-tinted background
        // Creates visual depth and subtly communicates which LLM is active
        gradient: LinearGradient(
          colors: [
            Colors.black87,
            personalityColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),

        // Border brightens to personality color while typing —
        // gives a "live / active" feel during the animation
        border: Border.all(
          color: isTyping
              ? personalityColor
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),

        // Colored glow shadow — ties the panel visually to the runtime identity
        boxShadow: [
          BoxShadow(
            color: personalityColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Header row: typing indicator (left) + cache badge (right) ──
          Row(
            children: [

              // Typing indicator — only shown during typewriter animation
              // Spinner + label communicates "AI is generating" to the user
              if (isTyping)
                Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(personalityColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI typing...',
                      style: TextStyle(
                        color: personalityColor,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              // Cache hit badge — ⚡ Instant signals a Redis LRU cache hit
              //
              // Context: The LLM Gateway uses an LRU cache for repeated
              // detection patterns. Cache hits respond in ~0.03ms vs ~3000ms
              // for a full LLM call — an 80% hit rate reduces average latency
              // from ~3000ms to ~300ms across all responses.
              // This badge makes that performance visible to the user.
              if (isCacheHit)
                const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.yellow, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Instant',
                      style: TextStyle(color: Colors.yellow, fontSize: 10),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Message body: revealed text + blinking cursor ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              // The visible portion of the AI message
              // Grows character by character via typewriter animation
              // height: 1.4 for comfortable multi-line readability
              Expanded(
                child: Text(
                  visibleMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),

              // Blinking cursor — only rendered while typing
              //
              // Migration note: In the GetX version this was a nested Obx()
              // inside an outer Obx() — two reactive scopes for one widget.
              // Now cursorVisible is a plain bool from the select() above.
              // AnimatedOpacity handles the blink with zero extra subscriptions.
              //
              // The cursor blinks at 500ms intervals (driven by _CursorBlinked
              // events in the BLoC) and snaps to visible when typing completes.
              if (isTyping)
                AnimatedOpacity(
                  opacity: cursorVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    '▌',
                    style: TextStyle(
                      color: personalityColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Resolve personality color from LLM runtime identifier
  ///
  /// Each backend runtime has a distinct color identity.
  /// This creates a subtle but learnable visual language:
  /// users eventually associate colors with response characteristics
  /// (speed, verbosity, tone) of each underlying model.
  ///
  /// Color rationale:
  /// - gemini-2.5-flash → Purple: premium, intelligent, Google AI identity
  /// - dart → Pink: playful, expressive — matches Dart's brand energy
  /// - go → Blue: technical, reliable — Go's systems-language personality
  /// - cache → Green: fast, efficient — "green light" for instant response
  /// - ollama (default) → Green: local inference, same "ready" signal as cache
  Color _getPersonalityColor(String runtime) {
    switch (runtime) {
      case 'gemini-2.5-flash':
        return Colors.purple.shade300;
      case 'dart':
        return Colors.pink.shade300;
      case 'go':
        return Colors.blue.shade300;
      case 'cache':
        return Colors.green.shade300;
      default:
        return Colors.green.shade300; // Ollama local inference fallback
    }
  }
}