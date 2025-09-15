import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SpeedDialView extends StatelessWidget {
  const SpeedDialView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // background (same as login)
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color.fromRGBO(0, 0, 0, 0.35)),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome, ${auth.username.value.isEmpty ? 'Guest' : auth.username.value}',
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Choose one of the detection modes using the menu button.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.black87,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.image),
            label: 'YOLOv8 Image Detection',
            onTap: () => Get.toNamed('/image-detect'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.videocam),
            label: 'YOLOv8 Real-time Detection',
            onTap: () => Get.toNamed('/video-detect'),
          ),
        ],
      ),
    );
  }
}
