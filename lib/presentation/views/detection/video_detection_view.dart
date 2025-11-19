import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/video_detection_controller.dart';
import '../../widgets/bounding_box_painter.dart';

class VideoDetectionView extends StatelessWidget {
  const VideoDetectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoDetectionController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final detections = controller.detections;

        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller.cameraController),
            CustomPaint(
              painter: BoundingBoxPainter(
                detections,
                imageSize: const Size(640, 480),
              ),
            ),
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
                    final confidence = ((d['confidence'] ?? 0.0) * 100).toStringAsFixed(1);
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
          ],
        );
      }),
    );
  }
}