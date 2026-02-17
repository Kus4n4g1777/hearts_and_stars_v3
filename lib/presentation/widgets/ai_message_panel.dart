import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/video_detection_controller.dart';

/// AI Message Panel Widget
///
/// Purpose:
/// - Display AI responses with typewriter animation
/// - Show visual indicators (typing, cache hit)
/// - Apply personality-based colors per LLM runtime
///
/// Features:
/// - Animated appearance/disappearance
/// - Gradient background with runtime-specific colors
/// - Typing indicator with spinner
/// - Cache hit indicator (⚡ Instant)
/// - Blinking cursor during typing
///
/// Design decisions:
/// - AnimatedContainer for smooth transitions
/// - Gradient to add depth and personality
/// - Border color changes during typing (visual feedback)
/// - Shadow with personality color for modern look
class AIMessagePanel extends StatelessWidget {
  const AIMessagePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoDetectionController>();

    return Obx(() {
      // Don't render if no message
      if (controller.aiMessageVisible.value.isEmpty) {
        return const SizedBox.shrink();
      }

      // Get personality color based on LLM runtime
      final personalityColor = _getPersonalityColor(
        controller.currentRuntime.value,
      );

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Gradient from black to personality color
          gradient: LinearGradient(
            colors: [
              Colors.black87,
              personalityColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          // Border changes color when typing
          border: Border.all(
            color: controller.isTyping.value
                ? personalityColor
                : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          // Shadow with personality color for depth
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
            // Header with status indicators
            Row(
              children: [
                // Typing indicator (only visible while typing)
                if (controller.isTyping.value)
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

                // Cache hit indicator (⚡ for instant responses)
                if (controller.cacheHit.value)
                  Row(
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: Colors.yellow,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Instant',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Message text with blinking cursor
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    controller.aiMessageVisible.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),

                // Blinking cursor (only visible while typing)
                if (controller.isTyping.value)
                  Obx(() => AnimatedOpacity(
                    opacity: controller.cursorVisible.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      '▌',
                      style: TextStyle(
                        color: personalityColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Get color based on LLM runtime
  ///
  /// Color mapping:
  /// - Gemini 2.5 Flash: Purple (professional, elegant)
  /// - Dart: Pink (romantic, playful)
  /// - Go: Blue (creative, technical)
  /// - Cache/Ollama: Green (fast, reliable)
  ///
  /// Why different colors?
  /// - Visual indicator of which LLM responded
  /// - User can learn which LLM has which personality
  /// - Makes the app feel more dynamic
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
        return Colors.green.shade300; // Ollama fallback
    }
  }
}