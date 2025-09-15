import 'package:flutter/material.dart';

class ImageDetectionView extends StatelessWidget {
  const ImageDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YOLOv8 - Image')),
      body: const Center(child: Text('Image detection screen (stub)')),
    );
  }
}
