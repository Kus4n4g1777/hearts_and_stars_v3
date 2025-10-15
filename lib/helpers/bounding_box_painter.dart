import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> detections;
  final Size imageSize; // original camera/image size
  final double confidenceThreshold;

  BoundingBoxPainter(
      this.detections, {
        required this.imageSize,
        this.confidenceThreshold = 0.9,
      });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for bounding boxes
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Paint for debug info background
    final debugBgPaint = Paint()..color = Colors.black87;

    // Debug info at top of screen
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

    // Draw debug background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, debugTextPainter.width + 10, debugTextPainter.height + 10),
      debugBgPaint,
    );
    debugTextPainter.paint(canvas, const Offset(5, 5));

    // Calculate scales
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    int detectionIndex = 0;
    for (var d in detections) {
      final confidence = (d['confidence'] ?? 0.0).toDouble();
      if (confidence < confidenceThreshold) continue;

      final bbox = d['bbox']; // should be normalized [x1, y1, x2, y2]

      // Log raw bbox values
      print('Detection $detectionIndex: ${d['label']}');
      print('  Raw bbox: $bbox');
      print('  Confidence: $confidence');

      // Get normalized coordinates
      final x1_norm = bbox[0].toDouble();
      final y1_norm = bbox[1].toDouble();
      final x2_norm = bbox[2].toDouble();
      final y2_norm = bbox[3].toDouble();

      print('  Normalized: x1=$x1_norm, y1=$y1_norm, x2=$x2_norm, y2=$y2_norm');

      // Convert to image pixel coordinates first
      final x1_img = x1_norm * imageSize.width;
      final y1_img = y1_norm * imageSize.height;
      final x2_img = x2_norm * imageSize.width;
      final y2_img = y2_norm * imageSize.height;

      print('  Image pixels: x1=$x1_img, y1=$y1_img, x2=$x2_img, y2=$y2_img');

      // Then scale to screen
      final left = x1_img * scaleX;
      final top = y1_img * scaleY;
      final right = x2_img * scaleX;
      final bottom = y2_img * scaleY;

      print('  Screen pixels: left=$left, top=$top, right=$right, bottom=$bottom');
      print('  Box size: ${right - left}x${bottom - top}');

      // Draw the bounding box
      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(rect, paint);

      // Draw center point for reference
      final centerX = (left + right) / 2;
      final centerY = (top + bottom) / 2;
      canvas.drawCircle(
        Offset(centerX, centerY),
        5,
        Paint()..color = Colors.green,
      );

      // Draw label with background
      final labelText = "${d['label']} ${(confidence * 100).toStringAsFixed(1)}%\n"
          "${(right - left).toInt()}x${(bottom - top).toInt()}px";

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

      // Position label - try to keep it visible
      double textX = left.clamp(0, size.width - textPainter.width);
      double textY = (top - textPainter.height - 4).clamp(0, size.height - textPainter.height);

      final textOffset = Offset(textX, textY);

      // Draw background for text
      canvas.drawRect(
        Rect.fromLTWH(
          textX - 2,
          textY - 2,
          textPainter.width + 4,
          textPainter.height + 4,
        ),
        Paint()..color = Colors.red,
      );

      textPainter.paint(canvas, textOffset);

      detectionIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
