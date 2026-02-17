import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/video_detection_controller.dart';
import '../../widgets/bounding_box_painter.dart';
import '../../widgets/ai_message_panel.dart'; // NEW IMPORT

/// Video Detection View
///
/// Purpose:
/// - Display real-time camera preview
/// - Show YOLO detection bounding boxes
/// - Display AI messages with typewriter effect
///
/// Layout:
/// - Camera preview (full screen)
/// - Bounding boxes overlay (CustomPaint)
/// - Detection labels (top-left)
/// - AI message panel (bottom, animated) - NEW
///
/// Why Stack?
/// - Allows layering widgets on top of camera
/// - Camera at bottom, overlays on top
/// - Positioned widgets for precise placement
class VideoDetectionView extends StatelessWidget {
  const VideoDetectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoDetectionController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Show loading indicator while camera initializes
        if (!controller.isCameraInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final detections = controller.detections;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Camera preview (bottom layer)
            CameraPreview(controller.cameraController),

            // Layer 2: Bounding boxes overlay
            CustomPaint(
              painter: BoundingBoxPainter(
                detections,
                imageSize: const Size(640, 480),
              ),
            ),

            // Layer 3: Detection labels (top-left corner)
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: detections.map((d) {
                    final label = d['label'] ?? 'Object';
                    final confidence =
                    ((d['confidence'] ?? 0.0) * 100).toStringAsFixed(1);
                    return Text(
                      '$label - $confidence%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Layer 4: AI message panel (bottom, animated) - NEW
            // This is where AI responses appear with typewriter effect
            const Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AIMessagePanel(),
            ),
          ],
        );
      }),
    );
  }
}