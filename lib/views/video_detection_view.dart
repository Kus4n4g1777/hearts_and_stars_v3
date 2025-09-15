import 'package:flutter/material.dart';

class VideoDetectionView extends StatelessWidget {
  const VideoDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YOLOv8 - Real-time')),
      body: const Center(child: Text('Real-time detection screen (stub)')),
    );
  }
}
