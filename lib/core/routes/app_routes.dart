import 'package:get/get.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/home/speed_dial_view.dart';
import '../../presentation/views/detection/image_detection_view.dart';
import '../../presentation/views/detection/video_detection_view.dart';
import '../../presentation/views/testing/ping_test_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String home = '/speed-dials';
  static const String imageDetection = '/image-detect';
  static const String videoDetection = '/video-detect';
  static const String pingTest = '/ping-test';

  static final routes = [
    GetPage(name: login, page: () => LoginView()),
    GetPage(name: home, page: () => const SpeedDialView()),
    GetPage(name: imageDetection, page: () => const ImageDetectionView()),
    GetPage(name: videoDetection, page: () => VideoDetectionView()),
    GetPage(name: pingTest, page: () => const PingTestView()),
  ];
}