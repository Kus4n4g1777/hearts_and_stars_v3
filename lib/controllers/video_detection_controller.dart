import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VideoDetectionController extends GetxController {
  late CameraController cameraController;
  WebSocketChannel? channel;

  var isCameraInitialized = false.obs;
  var detections = <Map<String, dynamic>>[].obs;

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
    _connectWebSocket();
    if (isCameraInitialized.value) {
      _startPeriodicCapture();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      cameraController = CameraController(
        firstCamera,
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

  void _connectWebSocket() {
    try {
      final wsUrl = Platform.isAndroid
          ? 'ws://10.0.2.2:8000/ws/dashboard'
          : 'ws://localhost:8000/ws/dashboard';

      channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      channel!.stream.listen(
            (message) {
          try {
            final data = jsonDecode(message);

            if (data['detections'] != null) {
              detections.value = List<Map<String, dynamic>>.from(
                  data['detections']
              );
              debugPrint("✅ Got ${detections.length} detections");
            }
          } catch (e) {
            debugPrint("❌ Parse error: $e");
          } finally {
            _isProcessing = false;
          }
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          _isProcessing = false;
        },
        onDone: () {
          debugPrint('🔌 WebSocket closed');
          _isProcessing = false;
        },
      );

      debugPrint("✅ WebSocket connected");
    } catch (e) {
      debugPrint("❌ WebSocket failed: $e");
    }
  }

  void _startPeriodicCapture() {
    _captureTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
          (_) => _captureAndSend(),
    );

    debugPrint("✅ Periodic capture started (1 FPS)");
  }

  Future<void> _captureAndSend() async {
    if (_isProcessing || !cameraController.value.isInitialized) {
      return;
    }

    try {
      _isProcessing = true;

      final XFile imageFile = await cameraController.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      if (channel != null) {
        channel!.sink.add(base64Encode(imageBytes));
        debugPrint("📤 Frame sent");
      }
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      _isProcessing = false;
    }
  }

  void _cleanup() {
    debugPrint("🧹 Cleaning up...");

    _captureTimer?.cancel();
    cameraController.dispose();
    channel?.sink.close();

    debugPrint("✅ Cleanup done");
  }
}