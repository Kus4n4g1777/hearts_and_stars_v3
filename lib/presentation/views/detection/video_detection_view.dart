/// Video Detection View
///
/// Renders the real-time camera detection UI backed by VideoDetectionBloc.
///
/// Architecture: BLoC Pattern — Presentation Layer
/// - This is a pure "dumb" view — zero business logic
/// - All state comes from VideoDetectionBloc via context.select()
/// - User interactions (implicit here — camera auto-runs) → Events → BLoC
///
/// Migration from GetX:
/// - Old: Get.put(VideoDetectionController()) + Obx(() => ...) wrappers
///   → One giant reactive rebuild for any .obs change
/// - New: BlocProvider + context.select() for granular subscriptions
///   → Only the widgets that depend on a specific field rebuild
///
/// Performance optimization — context.select() vs BlocBuilder:
/// - BlocBuilder: rebuilds on ANY state change
/// - context.select(): rebuilds ONLY when the selected field changes
///
/// Example: detection labels update every frame (1/sec),
/// but the camera preview never needs to rebuild.
/// context.select() gives us this precision for free.
///
/// Layout: Stack-based overlay system
/// - Layer 1 (bottom): CameraPreview — hardware feed
/// - Layer 2: CustomPaint — YOLO bounding boxes
/// - Layer 3: Detection labels — text overlay (top-left)
/// - Layer 4 (top): AIMessagePanel — LLM response with typewriter effect
///
/// Why Stack?
/// Allows precise z-ordering and Positioned placement of overlays
/// on top of the full-screen camera feed without affecting layout flow.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../detection/bloc/video_detection_bloc.dart';
import '../../widgets/bounding_box_painter.dart';
import '../../widgets/ai_message_panel.dart';

class VideoDetectionView extends StatelessWidget {
  const VideoDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create BLoC and immediately dispatch the start event
      // BlocProvider handles disposal automatically when widget unmounts
      // → calls BLoC.close() → calls _cleanup() → releases all resources
      create: (_) => VideoDetectionBloc()..add(const VideoDetectionStarted()),
      child: const _VideoDetectionBody(),
    );
  }
}

/// Private implementation widget — keeps BlocProvider and body separate
///
/// Why split into two widgets?
/// - BlocProvider must be an ANCESTOR of any widget that reads the BLoC
/// - If VideoDetectionView tried to use context.read() in its own build(),
///   the BLoC wouldn't be in the tree yet
/// - This split is the standard BLoC pattern for self-providing views
class _VideoDetectionBody extends StatelessWidget {
  const _VideoDetectionBody();

  @override
  Widget build(BuildContext context) {
    // Subscribe only to isCameraInitialized — this widget rebuilds
    // exactly once: when the camera transitions from false → true
    final isInitialized = context.select(
          (VideoDetectionBloc bloc) => bloc.state.isCameraInitialized,
    );

    // Show loading state while camera hardware initializes
    // Typically resolves within 500ms on most devices
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Subscribe only to detections — rebuilds at ~1/sec with new YOLO results
    // Camera preview and AI panel are unaffected by this rebuild
    final detections = context.select(
          (VideoDetectionBloc bloc) => bloc.state.detections,
    );

    // Access camera controller directly — not via state, since it's a
    // hardware resource object that CameraPreview needs a reference to
    final cameraController =
        context.read<VideoDetectionBloc>().cameraController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand, // All layers fill the screen
        children: [

          // Layer 1: Full-screen camera feed
          // CameraPreview handles its own rendering pipeline —
          // it does not rebuild with Flutter's widget tree
          CameraPreview(cameraController),

          // Layer 2: YOLO detection bounding boxes
          // CustomPaint redraws whenever detections list changes (~1/sec)
          // BoundingBoxPainter normalizes bbox coordinates [0-1] to screen pixels
          CustomPaint(
            painter: BoundingBoxPainter(
              detections,
              imageSize: const Size(640, 480), // YOLOv8 input resolution
            ),
          ),

          // Layer 3: Detection label readout (top-left corner)
          // Shows 'label - confidence%' for each detected object
          // Rebuilds with detections — same frequency as bounding boxes
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

          // Layer 4: AI Message Panel (bottom overlay)
          // Renders the typewriter-animated LLM response
          // AIMessagePanel subscribes to its own BLoC fields internally
          // (aiMessageVisible, isTyping, cursorVisible, currentRuntime, cacheHit)
          // keeping its rebuild cycle independent from detection updates
          const Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AIMessagePanel(),
          ),
        ],
      ),
    );
  }
}