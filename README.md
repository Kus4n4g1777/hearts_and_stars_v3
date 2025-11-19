# Hearts & Stars Detector 💖⭐

Real-time object detection app with Flutter + YOLOv8 + Spring Boot + Kafka + WebSockets.

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![GetX](https://img.shields.io/badge/GetX-State%20Management-9C27B0)](https://pub.dev/packages/get)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?logo=springboot)](https://spring.io/projects/spring-boot)
[![Kafka](https://img.shields.io/badge/Apache%20Kafka-Event%20Streaming-231F20?logo=apachekafka)](https://kafka.apache.org/)

---

## 🎯 Project Overview

This is a **portfolio project** showcasing a complete **full-stack AI application** with:

- **Frontend**: Flutter mobile app with real-time camera detection
- **Backend**: Spring Boot REST API + FastAPI inference service
- **Real-time**: WebSocket communication for live video processing
- **Event Streaming**: Apache Kafka for async event processing
- **AI/ML**: YOLOv8 TFLite for object detection (hearts & stars)
- **Architecture**: Clean Architecture + MVVM + Repository Pattern

### 🎥 Demo
*(Add screenshots/GIFs here)*

---

## 🏗️ Architecture

### High-Level System Design

```
┌─────────────────┐     WebSocket      ┌──────────────────┐
│                 │ ◄─────────────────► │                  │
│  Flutter App    │     (frames +       │  FastAPI         │
│  (Mobile)       │      detections)    │  (Inference)     │
│                 │                     │                  │
└────────┬────────┘                     └────────┬─────────┘
         │                                       │
         │ REST API                              │
         │ (JWT Auth)                            │
         ▼                                       ▼
┌─────────────────┐                     ┌──────────────────┐
│                 │                     │                  │
│  Spring Boot    │────────────────────►│  Apache Kafka    │
│  (Backend)      │   Publish Events    │  (Event Stream)  │
│                 │                     │                  │
└────────┬────────┘                     └────────┬─────────┘
         │                                       │
         │                                       │ Consume
         ▼                                       ▼
┌─────────────────┐                     ┌──────────────────┐
│                 │                     │                  │
│  PostgreSQL     │                     │  AWS DynamoDB    │
│  (Primary DB)   │                     │  (Logs)          │
│                 │                     │                  │
└─────────────────┘                     └──────────────────┘
```

### Flutter App Architecture (Clean Architecture)

```
presentation/          # UI Layer (Views + Controllers)
├── controllers/       # MVVM ViewModels (GetX)
├── views/            # UI Widgets
└── widgets/          # Reusable components

data/                 # Data Layer
├── models/           # Data models (User, Detection, Post)
└── repositories/     # Data sources abstraction

services/             # External services
├── api_service.dart        # HTTP client
├── websocket_service.dart  # Real-time communication
└── storage_service.dart    # Local persistence

core/                 # Configuration & utilities
├── constants/        # API URLs, keys
└── routes/          # Navigation config
```

---

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** 3.5+ ([Install](https://flutter.dev/docs/get-started/install))
- **Dart SDK** 3.5+
- **Android Studio** or **Xcode** (for emulators)
- **Docker** (for backend services)
- **Java 17+** (for Spring Boot)

### 1. Clone Repository

```bash
git clone https://github.com/Kus4n4g1777/hearts_and_stars_v3.git
cd hearts_and_stars_v3
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Start Backend Services

```bash
# Start Spring Boot + PostgreSQL + Kafka
cd backend
docker-compose up -d

# Start FastAPI inference service
cd inference-service
docker-compose up -d
```

### 4. Run Flutter App

```bash
# Android Emulator
flutter run

# iOS Simulator
flutter run -d ios

# Physical device
flutter devices  # List devices
flutter run -d <device-id>
```

---

## 📱 Features

### ✅ Implemented

- [x] **JWT Authentication** (Login/Logout with Spring Boot)
- [x] **Real-time Video Detection** (WebSocket + YOLOv8)
- [x] **Bounding Box Visualization** (Custom painter with accurate coordinates)
- [x] **Auto-reconnect** (WebSocket resilience)
- [x] **State Management** (GetX reactive programming)
- [x] **Local Storage** (JWT token persistence)
- [x] **Platform-specific networking** (Android emulator support)

### 🚧 In Progress

- [ ] **User Registration** (Create new accounts)
- [ ] **Posts System** (Create/view posts with Kafka events)
- [ ] **Image Detection** (Upload photo for detection)
- [ ] **Kafka Event Logging** (Track detections in DynamoDB)
- [ ] **Push Notifications** (Detection alerts)

### 🎯 Planned

- [ ] **Offline Detection** (TFLite on-device)
- [ ] **Rive Animations** (Heart/star animations on detection)
- [ ] **User Profile** (Settings, history)
- [ ] **Social Features** (Share detections)

---

## 🛠️ Tech Stack

### Frontend (Flutter)

| Technology | Purpose | Why? |
|------------|---------|------|
| **Flutter 3.5+** | Cross-platform UI | Single codebase for iOS/Android |
| **Dart 3.5+** | Programming language | Null-safety, strong typing |
| **GetX** | State management | Reactive, minimal boilerplate |
| **Camera Plugin** | Camera access | Native camera control |
| **WebSocket** | Real-time communication | Bidirectional, low latency |
| **SharedPreferences** | Local storage | Persist JWT tokens |
| **HTTP** | REST API calls | Standard networking |

### Backend (Spring Boot)

| Technology | Purpose | Why? |
|------------|---------|------|
| **Spring Boot 3.x** | REST API | Enterprise-grade framework |
| **Spring Security** | Authentication | JWT + OAuth2 |
| **PostgreSQL** | Primary database | ACID compliance |
| **Kafka** | Event streaming | Async processing, scalability |
| **Docker** | Containerization | Consistent environments |

### AI/ML (FastAPI)

| Technology | Purpose | Why? |
|------------|---------|------|
| **FastAPI** | Inference API | High performance, async |
| **YOLOv8** | Object detection | State-of-the-art accuracy |
| **TFLite** | Model format | Optimized for mobile/edge |
| **OpenCV** | Image processing | Industry standard |
| **WebSockets** | Real-time frames | Low latency inference |

### Infrastructure

| Technology | Purpose | Why? |
|------------|---------|------|
| **Kafka** | Event streaming | Decouple services |
| **PostgreSQL** | Primary DB | Relational data |
| **DynamoDB** | Logs storage | Fast NoSQL for events |
| **Docker** | Containers | Reproducible builds |

---

## 📂 Project Structure

```
hearts_and_stars_v3/
├── lib/                              # Flutter source code
│   ├── core/                         # Configuration & constants
│   │   ├── constants/
│   │   │   └── api_constants.dart    # API URLs, endpoints, headers
│   │   └── routes/
│   │       └── app_routes.dart       # Navigation configuration
│   │
│   ├── data/                         # Data layer
│   │   └── models/
│   │       ├── user_model.dart       # User, LoginCredentials
│   │       └── detection_model.dart  # Detection, BoundingBox (WIP)
│   │
│   ├── presentation/                 # UI layer
│   │   ├── controllers/
│   │   │   ├── auth_controller.dart           # Login/logout logic
│   │   │   ├── video_detection_controller.dart # Real-time detection
│   │   │   └── permission_controller.dart     # Camera/storage permissions
│   │   │
│   │   ├── views/
│   │   │   ├── auth/
│   │   │   │   └── login_view.dart            # Login screen
│   │   │   ├── home/
│   │   │   │   └── speed_dial_view.dart       # Main menu
│   │   │   ├── detection/
│   │   │   │   ├── video_detection_view.dart  # Real-time camera
│   │   │   │   └── image_detection_view.dart  # Upload image (stub)
│   │   │   └── testing/
│   │   │       └── ping_test_view.dart        # API connectivity test
│   │   │
│   │   └── widgets/
│   │       └── bounding_box_painter.dart      # Custom drawing for boxes
│   │
│   ├── services/                     # External services
│   │   ├── api_service.dart          # REST API client
│   │   ├── websocket_service.dart    # WebSocket manager
│   │   └── storage_service.dart      # SharedPreferences wrapper
│   │
│   └── main.dart                     # App entry point
│
├── assets/                           # Static resources
│   ├── images/
│   │   └── background.jpg            # Login/home background
│   ├── models/
│   │   └── yolov8n_float16.tflite   # YOLO model (for future on-device)
│   └── animations/
│       └── hearts_stars.riv          # Rive animations (planned)
│
├── android/                          # Android-specific code
├── ios/                              # iOS-specific code
├── pubspec.yaml                      # Flutter dependencies
└── README.md                         # This file
```

---

## 🔧 Configuration

### Android Emulator Networking

Android emulators cannot access `localhost`. Use special IP `10.0.2.2`:

```dart
// lib/core/constants/api_constants.dart
static String get baseUrl {
  if (Platform.isAndroid) return "http://10.0.2.2:8000";  // Emulator
  if (Platform.isIOS) return "http://localhost:8000";      // Simulator
  return "http://127.0.0.1:8000";                          // Desktop/Web
}
```

### Environment Variables

Create `.env` files (not committed to Git):

```bash
# Backend (.env)
DATABASE_URL=postgresql://user:pass@localhost:5432/hearts_stars
JWT_SECRET=your-secret-key-here
KAFKA_BROKERS=localhost:9092

# Inference Service (.env)
MODEL_PATH=/models/yolov8n.tflite
CONFIDENCE_THRESHOLD=0.9
```

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Test specific file
flutter test test/services/api_service_test.dart
```

---

## 📚 Key Concepts Explained

### Why GetX?

**GetX** is a lightweight state management solution for Flutter:

- **Reactive**: UI automatically updates when state changes
- **Minimal boilerplate**: No need for `setState()`, `notifyListeners()`
- **Dependency injection**: Easy service management
- **Navigation**: Simple routing without context

```dart
// Without GetX (verbose)
class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;
  
  void increment() {
    setState(() { count++; });
  }
}

// With GetX (concise)
class CounterController extends GetxController {
  var count = 0.obs;  // Observable
  void increment() => count++;  // Auto-updates UI
}
```

### Why WebSocket over HTTP for video?

**HTTP**: Request → Response (one-shot)
- Client asks, server responds, connection closes
- High latency for real-time (need to reconnect each time)

**WebSocket**: Persistent connection
- Client sends frames continuously
- Server pushes detections immediately
- Lower latency, better for video

```dart
// HTTP (slow for real-time)
Future<void> detectFrame() async {
  final response = await http.post('/detect', body: frame);
  // Wait for response... reconnect... send next frame...
}

// WebSocket (fast)
channel.sink.add(frame);  // Send frame
channel.stream.listen((detections) {  // Receive detections immediately
  updateUI(detections);
});
```

### Why Repository Pattern?

**Problem**: Controllers directly calling API
```dart
class PostController {
  void loadPosts() async {
    final response = await http.get('/posts');  // ❌ Tight coupling
  }
}
```

**Solution**: Repository abstracts data source
```dart
class PostRepository {
  Future<List<Post>> getPosts() async {
    // Could be API, local DB, cache, etc.
    final response = await http.get('/posts');
    return parse(response);
  }
}

class PostController {
  final PostRepository repo;
  void loadPosts() async {
    final posts = await repo.getPosts();  // ✅ Clean separation
  }
}
```

**Benefits**:
- Easy to switch data sources (API → local DB)
- Easy to test (mock repository)
- Single responsibility (controller doesn't know about HTTP)

---

## 🐛 Troubleshooting

### Build Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter run

# Android build cache
cd android && ./gradlew clean
cd ..
flutter run
```

### Emulator Storage Full

Android emulators fill up quickly. Move to larger drive:

```bash
# Windows
# Android Studio → AVD Manager → Edit → Advanced Settings → Change AVD location
```

### WebSocket Connection Failed

1. Check backend is running: `docker ps`
2. Verify URL in `api_constants.dart`
3. Check firewall/antivirus blocking port 8000
4. Test with `curl`:
   ```bash
   curl http://10.0.2.2:8000/ping
   ```

### Token Expired

Tokens expire after 30 minutes. Re-login or implement refresh token.

---

## 🤝 Contributing

This is a portfolio project, but suggestions are welcome!

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📝 License

This project is for educational/portfolio purposes.

---

## 👨‍💻 Author

**Kus4n4g1777**

- GitHub: [@Kus4n4g1777](https://github.com/Kus4n4g1777)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

---

## 🙏 Acknowledgments

- **Claude AI** - Architecture guidance and debugging
- **YOLOv8** - Ultralytics for the model
- **Flutter Community** - Amazing ecosystem
- **Spring Boot** - Robust backend framework

---

## 📖 Documentation

For detailed documentation on specific components:

- [API Documentation](docs/API.md) *(coming soon)*
- [Architecture Deep Dive](docs/ARCHITECTURE.md) *(coming soon)*
- [Deployment Guide](docs/DEPLOYMENT.md) *(coming soon)*

---

## 🚀 The Dev Journey — From Chaos to Clean Architecture

*A first-person account of the battles, bugs, and breakthroughs*

Hey there, future me (and anyone curious about the real process behind this project). 👋

This isn't your typical "everything worked perfectly" README. This is the **raw, unfiltered journey** of building a real-time AI detection system while learning Flutter, Spring Boot, Kafka, and WebSockets—all at the same time. Buckle up. 😅

---

### 🔥 **The Beginning: "How hard can it be?"**

Started with a simple goal: detect hearts and stars in real-time using YOLOv8. Sounds clean, right? Yeah... until I dove into the actual implementation.

**First major roadblock:** My code was a mess. Controllers calling APIs directly, hardcoded URLs everywhere, no separation of concerns. It worked, sure, but it was like a house of cards—touch one thing, and everything falls apart.

Then came the **cold shower moment** 💦 — I realized I was still far from a professional structure. My file organization looked like this:

```
lib/
├── main.dart
├── controllers/
├── views/
└── services/
```

Simple, but not scalable. Not interview-ready. Not portfolio-worthy.

---

### 💡 **The Refactor: Learning Clean Architecture the Hard Way**

With help from Claude (shoutout to my AI debugging buddy 🤖), I decided to **completely refactor** the project. This meant:

1. **Creating a proper folder structure:**
   - `core/` for constants and config
   - `data/` for models and repositories
   - `presentation/` for controllers and views
   - `services/` for external communication

2. **Implementing MVVM pattern:**
   - Separating business logic from UI
   - Making controllers reactive with GetX
   - Creating reusable models

3. **Adding proper abstraction:**
   - Storage service (no more raw SharedPreferences calls)
   - WebSocket service (with auto-reconnect!)
   - API service (centralized HTTP client)

**The pain:** Moving 20+ files, updating imports, fixing broken references. I thought my app would never run again. 😭

**The reward:** When it finally compiled and ran—smooth as butter—I felt like a god. ⚡

---

### 🎯 **The Bounding Box Nightmare**

Oh boy, this one tested my sanity. The detections were working, WebSocket was sending frames, backend was responding... but the bounding boxes? They were **floating in space** like Salvador Dalí paintings. 🎨

**The problem:** Coordinate transformations. YOLO returns normalized coordinates (0-1), but I was:
- Multiplying by image size
- Then scaling to screen size
- But forgetting about letterboxing
- And camera rotation
- And aspect ratios

**The debugging process:**
```dart
print('Detection: $label');
print('  Raw bbox: $bbox');
print('  Normalized: x1=$x1_norm, y1=$y1_norm');
print('  Image pixels: x1=$x1_img, y1=$y1_img');
print('  Screen pixels: left=$left, top=$top');
print('  Box size: ${right - left}x${bottom - top}');
```

I added debug logs **everywhere**. The console looked like a Matrix screen. But it worked—finally understood the coordinate spaces and got those boxes aligned perfectly. ✅

---

### 🔌 **Android Emulator: "10.0.2.2? What sorcery is this?"**

Spent 2 hours getting 404 errors from my backend. The URL was correct, backend was running, ports were open... what the hell?

Then I learned: **Android emulator can't access `localhost`**. 🤦‍♂️

The emulator is its own virtual machine. When you say `localhost` or `127.0.0.1`, it's talking to **itself**, not your host machine.

The solution? Android's special IP: `10.0.2.2` maps to your computer's localhost.

```dart
static String get baseUrl {
  if (Platform.isAndroid) return "http://10.0.2.2:8000";  // Magic IP
  if (Platform.isIOS) return "http://localhost:8000";      // iOS is normal
  return "http://127.0.0.1:8000";
}
```

Lesson learned: **Read the docs before debugging for hours**. 📚

---

### 🕸️ **WebSocket Reconnection: The Silent Killer**

WebSocket would connect fine, send a few frames, then... silence. No errors, no crashes, just dead air.

**The issue:** Network isn't perfect. WiFi drops, mobile data switches, backend restarts. If you don't handle reconnection, your app becomes a brick.

**The fix:** Built a proper reconnection system:
- Max 5 attempts
- 3-second delay between attempts
- Graceful degradation
- User-friendly error messages

```dart
void _scheduleReconnect() {
  if (_reconnectAttempts >= _maxReconnectAttempts) {
    debugPrint('❌ Max attempts reached');
    return;
  }
  _reconnectTimer = Timer(Duration(seconds: 3), () => connect());
}
```

Now the app is resilient. Drop WiFi? No problem—auto-reconnects when you're back online. 🔄

---

### 🗄️ **JWT Tokens: The Expiring Time Bomb**

Everything worked great... for 15 minutes. Then suddenly, all API calls failed with 401 Unauthorized.

**Why?** JWT tokens expire. That's literally their job—security through expiration.

**The problem:** No refresh token system. When token died, user had to re-login manually.

**The solution (planned):** Implement refresh tokens:
- Access token: short-lived (15 min)
- Refresh token: long-lived (7 days)
- When access expires, use refresh to get new access
- Only re-login when refresh expires

Still on the TODO list, but at least I understand **why** it's needed now. 📝

---

### 🐳 **Docker Shenanigans**

Backend in Docker, frontend in emulator—should be simple, right?

**Plot twist:** Docker containers have their own network. Backend running on `localhost:8000` inside Docker isn't accessible from emulator's `10.0.2.2:8000`.

**The fix:** Expose ports properly in `docker-compose.yml`:
```yaml
ports:
  - "8000:8000"  # Host:Container
```

And configure CORS to accept requests from emulator IP. Backend finally talked to frontend. 🎉

---

### 📱 **Emulator Storage: The Hidden Enemy**

App working perfectly on my machine. Deploy to emulator... **instant crash**.

**Why?** Emulator ran out of disk space. Those AVDs eat storage like crazy.

**The solution:** Move emulator to another drive with more space:
```
Android Studio → AVD Manager → Edit → Advanced Settings → Change AVD location
```

Also learned: `flutter clean` is your friend. Regularly clean build cache to avoid weird issues. 🧹

---

### 🎨 **The Beauty of Reactive Programming**

One of the best discoveries: **GetX reactive state management**.

**Before GetX:**
```dart
class _MyWidgetState extends State<MyWidget> {
  int count = 0;
  
  void increment() {
    setState(() {
      count++;
    });
  }
}
```

**After GetX:**
```dart
class MyController extends GetxController {
  var count = 0.obs;
  void increment() => count++;
}

// In UI
Obx(() => Text('Count: ${controller.count}'))
```

No more `setState()`, no more boilerplate. UI updates automatically when data changes. Magic. ✨

---

### 🧠 **Lessons Learned (The Hard Way)**

1. **Architecture matters from day one**
   - Refactoring later is painful
   - Clean code saves time in the long run

2. **Platform-specific quirks are real**
   - Android emulator networking is different
   - iOS and Android handle permissions differently
   - Test on real devices early

3. **Debugging is an art**
   - Add logs everywhere when stuck
   - Print intermediate values
   - Trust the process

4. **AI assistants are game-changers**
   - Claude helped me understand concepts faster
   - ChatGPT gave alternative perspectives
   - But I still had to implement and debug myself

5. **Documentation is love**
   - Comments help future me
   - Recruiters love seeing thought process
   - Writing solidifies understanding

---

### 🎯 **What's Next?**

Now that the foundation is solid:
- ✅ Clean architecture implemented
- ✅ Real-time detection working
- ✅ WebSocket resilient
- ✅ Code well-documented

**Next steps:**
- [ ] Posts system with Kafka
- [ ] Repository pattern for better testing
- [ ] Refresh token implementation
- [ ] On-device TFLite inference
- [ ] Rive animations (because why not make it pretty?)

---

### 💬 **Final Thoughts**

This project taught me more than any tutorial could. The struggles, the late nights debugging coordinate math, the satisfaction of seeing boxes align perfectly—**this is real learning**.

If you're reading this as a recruiter: Yes, I can build production-ready apps. But more importantly, I can **learn, adapt, and solve problems** when things go wrong (and they always do).

If you're reading this as a fellow dev: Keep pushing. The chaos becomes clarity. The bugs become features. The frustration becomes mastery.

And to future me: Remember when you thought this was impossible? Look how far you've come. Keep building. 💪

---

**Built with ❤️, late nights ☕, and a lot of Stack Overflow 🔍**

*P.S. - Big thanks to Claude, ChatGPT, and Gemini for being my rubber ducks, debuggers, and occasional therapists. You three deserve medals. 🥇*
