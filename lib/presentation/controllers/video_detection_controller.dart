import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/websocket_service.dart';

class VideoDetectionController extends GetxController {
  late CameraController cameraController;
  final WebSocketService _wsService = WebSocketService();

  final isCameraInitialized = false.obs;
  final detections = <Map<String, dynamic>>[].obs;

  Timer? _captureTimer;
  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    _initCameraAndWebSocket();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  Future<void> _initCameraAndWebSocket() async {
    await _initCamera();
    await _connectWebSocket();
    if (isCameraInitialized.value) {
      _startPeriodicCapture();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController.initialize();
      isCameraInitialized.value = true;
      debugPrint("✅ Camera ready");
    } catch (e) {
      debugPrint("❌ Camera error: $e");
    }
  }

  Future<void> _connectWebSocket() async {
    await _wsService.connect();
    _wsService.dataStream.listen((data) {
      try {
        if (data['detections'] != null) {
          detections.value = (data['detections'] as List).map((d) {
            return {
              'label': d['label'] ?? 'Object',
              'confidence': (d['confidence'] ?? 0.0).toDouble(),
              'bbox': List<double>.from(d['bbox'].map((v) => v.toDouble())),
            };
          }).toList();
          debugPrint("✅ Got ${detections.length} detections");
        }
      } catch (e) {
        debugPrint("❌ Parse error: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  void _startPeriodicCapture() {
    _captureTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _captureAndSend(),
    );
    debugPrint("📸 Capture started (1 FPS)");
  }

  Future<void> _captureAndSend() async {
    if (_isProcessing || !cameraController.value.isInitialized) return;

    try {
      _isProcessing = true;
      final XFile imageFile = await cameraController.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();
      _wsService.sendFrame(base64Encode(imageBytes));
      debugPrint("📤 Frame sent");
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      _isProcessing = false;
    }
  }

  void _cleanup() {
    _captureTimer?.cancel();
    cameraController.dispose();
    _wsService.dispose();
    debugPrint("✅ Cleanup done");
  }
}