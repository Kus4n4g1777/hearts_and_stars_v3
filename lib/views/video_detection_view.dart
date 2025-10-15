import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/video_detection_controller.dart';

class VideoDetectionView extends StatelessWidget {
  const VideoDetectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VideoDetectionController controller = Get.put(VideoDetectionController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // Fixed: Get detections once, outside nested Obx
        final currentDetections = controller.detections.toList();

        return Stack(
          fit: StackFit.expand,
          children: [
            // Live camera preview
            CameraPreview(controller.cameraController),

            // Bounding boxes - NO nested Obx!
            CustomPaint(
              painter: BoundingBoxPainter(
                detections: currentDetections,
              ),
            ),

            // Detection count
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Detections: ${currentDetections.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;

  BoundingBoxPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var detection in detections) {
      try {
        // Adjust these keys based on your server response format
        final x = (detection['x'] ?? 0).toDouble();
        final y = (detection['y'] ?? 0).toDouble();
        final width = (detection['width'] ?? 0).toDouble();
        final height = (detection['height'] ?? 0).toDouble();
        final label = detection['label'] ?? 'Object';
        final confidence = detection['confidence'] ?? 0.0;

        final rect = Rect.fromLTWH(
          x * size.width,
          y * size.height,
          width * size.width,
          height * size.height,
        );

        // Draw box
        canvas.drawRect(rect, paint);

        // Draw label
        final labelText = '$label ${(confidence * 100).toStringAsFixed(0)}%';
        textPainter.text = TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();

        final labelRect = Rect.fromLTWH(
          rect.left,
          rect.top - 20,
          textPainter.width + 8,
          20,
        );

        canvas.drawRect(labelRect, Paint()..color = Colors.green);
        textPainter.paint(canvas, Offset(rect.left + 4, rect.top - 18));
      } catch (e) {
        debugPrint('Error drawing detection: $e');
      }
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}