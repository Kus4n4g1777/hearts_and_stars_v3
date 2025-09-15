import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/login_view.dart';
import 'views/speed_dial_view.dart';
import 'views/image_detection_view.dart';
import 'views/video_detection_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hearts & Stars',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginView()),
        GetPage(name: '/speed-dials', page: () => const SpeedDialView()),
        GetPage(name: '/image-detect', page: () => const ImageDetectionView()),
        GetPage(name: '/video-detect', page: () => const VideoDetectionView()),
      ],
    );
  }
}
