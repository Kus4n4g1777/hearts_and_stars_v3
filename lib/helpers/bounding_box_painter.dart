import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> detections;
  final Size imageSize; // Pass original frame size

  BoundingBoxPainter(this.detections, {required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (var d in detections) {
      final bbox = d['bbox']; // [x, y, width, height]
      final rect = Rect.fromLTWH(
        bbox[0].toDouble() * scaleX,
        bbox[1].toDouble() * scaleY,
        bbox[2].toDouble() * scaleX,
        bbox[3].toDouble() * scaleY,
      );
      canvas.drawRect(rect, paint);

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: d['label'],
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
