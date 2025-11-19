import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom painter for drawing bounding boxes on camera preview
///
/// What is CustomPainter?
/// - Flutter's low-level drawing API
/// - Like HTML Canvas or Android Canvas
/// - Gives full control over rendering
///
/// Why CustomPainter for bounding boxes?
/// - Widgets are too slow for real-time (60 FPS)
/// - Need precise pixel-level control
/// - Can draw complex shapes efficiently
///
/// How it works:
/// 1. Controller updates detections list
/// 2. UI rebuilds with new detections
/// 3. This painter draws boxes on top of camera
/// 4. shouldRepaint returns true → redraws every frame
///
/// Coordinate spaces (CRITICAL):
/// - Backend: normalized coords (0-1)
/// - Image: pixel coords (640x480)
/// - Screen: pixel coords (device resolution)
/// We must transform: normalized → image → screen
class BoundingBoxPainter extends CustomPainter {
  /// List of detections from YOLO
  /// Format: [{'label': 'heart', 'confidence': 0.95, 'bbox': [x1,y1,x2,y2]}]
  final List<dynamic> detections;

  /// Original camera image size (e.g., 640x480)
  /// Why needed?
  /// - Backend processes image at this size
  /// - Coordinates are relative to this size
  /// - Must scale to screen size for display
  final Size imageSize;

  /// Minimum confidence threshold to display box
  /// Default 0.9 = only show 90%+ confident detections
  /// Why filter?
  /// - Reduces false positives
  /// - Cleaner UI (less clutter)
  /// - User sees only high-quality detections
  final double confidenceThreshold;

  BoundingBoxPainter(
      this.detections, {
        required this.imageSize,
        this.confidenceThreshold = 0.9,
      });

  /// Main drawing method - called every frame
  ///
  /// @param canvas - Drawing surface (like HTML Canvas)
  /// @param size - Screen size (device resolution)
  @override
  void paint(Canvas canvas, Size size) {
    // ==================== PAINT SETUP ====================

    /// Paint for bounding box outline
    final paint = Paint()
      ..color = Colors.red           // Red boxes
      ..strokeWidth = 2              // 2px thick lines
      ..style = PaintingStyle.stroke; // Outline only (not filled)

    /// Paint for debug info background
    final debugBgPaint = Paint()..color = Colors.black87;

    // ==================== DEBUG INFO ====================

    /// Show current screen and image sizes at top
    /// Helps verify coordinate transformations are correct
    final debugText = 'Screen: ${size.width.toInt()}x${size.height.toInt()}\n'
        'Image: ${imageSize.width.toInt()}x${imageSize.height.toInt()}\n'
        'Detections: ${detections.length}';

    final debugTextPainter = TextPainter(
      text: TextSpan(
        text: debugText,
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    debugTextPainter.layout();

    // Draw semi-transparent black background for debug text
    canvas.drawRect(
      Rect.fromLTWH(0, 0, debugTextPainter.width + 10, debugTextPainter.height + 10),
      debugBgPaint,
    );
    debugTextPainter.paint(canvas, const Offset(5, 5));

    // ==================== COORDINATE TRANSFORMATION ====================

    /// Calculate scale factors from image to screen
    ///
    /// Why scale?
    /// - Camera captures at imageSize (e.g., 640x480)
    /// - Screen displays at size (e.g., 1080x1920)
    /// - Boxes must scale proportionally
    ///
    /// Example:
    /// - Image: 640x480
    /// - Screen: 1280x960
    /// - scaleX = 1280/640 = 2x
    /// - scaleY = 960/480 = 2x
    /// - Box at [100,100,200,200] becomes [200,200,400,400]
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // ==================== DRAW EACH DETECTION ====================

    int detectionIndex = 0;
    for (var d in detections) {
      /// Get confidence score (0.0 - 1.0)
      final confidence = (d['confidence'] ?? 0.0).toDouble();

      /// Skip low confidence detections
      /// Reduces noise and false positives
      if (confidence < confidenceThreshold) continue;

      /// Get bounding box coordinates
      /// Format: [x1, y1, x2, y2] normalized (0-1)
      /// - x1, y1: top-left corner
      /// - x2, y2: bottom-right corner
      final bbox = d['bbox'];

      // Debug logging (visible in console, not on screen)
      debugPrint('Detection $detectionIndex: ${d['label']}');
      debugPrint('  Raw bbox: $bbox');
      debugPrint('  Confidence: $confidence');

      // ==================== STEP 1: NORMALIZED → IMAGE ====================

      /// Convert normalized coordinates (0-1) to image pixel coordinates
      ///
      /// Why normalized?
      /// - YOLO outputs coordinates relative to image size
      /// - 0.5 = middle of image (50%)
      /// - Works for any image size
      ///
      /// Example:
      /// - bbox = [0.25, 0.25, 0.75, 0.75] (quarter to three-quarters)
      /// - imageSize = 640x480
      /// - x1 = 0.25 * 640 = 160px
      /// - y1 = 0.25 * 480 = 120px
      /// - x2 = 0.75 * 640 = 480px
      /// - y2 = 0.75 * 480 = 360px
      final x1Norm = bbox[0].toDouble();
      final y1Norm = bbox[1].toDouble();
      final x2Norm = bbox[2].toDouble();
      final y2Norm = bbox[3].toDouble();

      debugPrint('  Normalized: x1=$x1Norm, y1=$y1Norm, x2=$x2Norm, y2=$y2Norm');

      // Convert to image pixel coordinates
      final x1Img = x1Norm * imageSize.width;
      final y1Img = y1Norm * imageSize.height;
      final x2Img = x2Norm * imageSize.width;
      final y2Img = y2Norm * imageSize.height;

      debugPrint('  Image pixels: x1=$x1Img, y1=$y1Img, x2=$x2Img, y2=$y2Img');

      // ==================== STEP 2: IMAGE → SCREEN ====================

      /// Scale image coordinates to screen coordinates
      ///
      /// Why needed?
      /// - Camera preview might not fill entire screen
      /// - Aspect ratios might differ
      /// - Must map image pixels to screen pixels
      final left = x1Img * scaleX;
      final top = y1Img * scaleY;
      final right = x2Img * scaleX;
      final bottom = y2Img * scaleY;

      debugPrint('  Screen pixels: left=$left, top=$top, right=$right, bottom=$bottom');
      debugPrint('  Box size: ${right - left}x${bottom - top}');

      // ==================== DRAW BOUNDING BOX ====================

      /// Create rectangle from screen coordinates
      final rect = Rect.fromLTRB(left, top, right, bottom);

      /// Draw the box outline
      canvas.drawRect(rect, paint);

      // ==================== DRAW CENTER POINT ====================

      /// Draw green dot at box center (for debugging/reference)
      /// Helps verify box is centered on object
      final centerX = (left + right) / 2;
      final centerY = (top + bottom) / 2;
      canvas.drawCircle(
        Offset(centerX, centerY),
        5, // 5px radius
        Paint()..color = Colors.green,
      );

      // ==================== DRAW LABEL ====================

      /// Create label text with object name, confidence, and size
      /// Format: "heart 95.0%\n120x80px"
      final labelText = "${d['label']} ${(confidence * 100).toStringAsFixed(1)}%\n"
          "${(right - left).toInt()}x${(bottom - top).toInt()}px";

      /// TextPainter renders text on canvas
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // ==================== POSITION LABEL ====================

      /// Position label above box (if space available)
      /// Otherwise position below
      /// clamp() ensures text stays on screen
      double textX = left.clamp(0, size.width - textPainter.width);
      double textY = (top - textPainter.height - 4).clamp(0, size.height - textPainter.height);

      final textOffset = Offset(textX, textY);

      // Draw red background for text (for readability)
      canvas.drawRect(
        Rect.fromLTWH(
          textX - 2,
          textY - 2,
          textPainter.width + 4,
          textPainter.height + 4,
        ),
        Paint()..color = Colors.red,
      );

      // Draw the text on top of background
      textPainter.paint(canvas, textOffset);

      detectionIndex++;
    }
  }

  /// Should repaint on every frame?
  ///
  /// Return true = repaint every time detections change
  /// Return false = cache and don't repaint
  ///
  /// We return true because detections update frequently (1 FPS)
  /// and we always want fresh boxes
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}