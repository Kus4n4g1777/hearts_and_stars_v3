# Hearts & Stars Detector 💖⭐

Real-time object detection app with Flutter + YOLOv8 + FastAPI + WebSockets + LLM Gateway.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-Pattern-blueviolet)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=flat&logo=spring&logoColor=white)
![Kafka](https://img.shields.io/badge/Apache_Kafka-231F20?style=flat&logo=apache-kafka&logoColor=white)

---

## 🎯 Project Overview

This is a portfolio project showcasing a complete full-stack AI application with:

- **Frontend:** Flutter mobile app with real-time camera detection
- **Backend:** Spring Boot REST API + FastAPI inference service
- **Real-time:** WebSocket communication for live video processing
- **Event Streaming:** Apache Kafka for async event processing
- **AI/ML:** YOLOv8 for object detection (hearts & stars)
- **LLM Gateway:** Multi-runtime AI commentary (Gemini 2.5 Flash / Ollama / Dart / Go) with Redis LRU caching
- **Architecture:** Clean Architecture + BLoC Pattern + Repository Pattern

> **Note on state management:** This project started with GetX and was fully migrated to BLoC.
> That journey — and why it happened — is documented below and in the Dev Journey section.
> Both approaches are preserved in git history for reference.

---

## 🎥 Demo

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

### LLM Gateway Architecture

One of the most interesting pieces of this project is the LLM Gateway — a multi-runtime inference
layer that generates AI commentary on detections in real time.

```
Frame detected
      │
      ▼
┌─────────────┐     cache hit (~0.03ms)    ┌──────────────┐
│  Redis LRU  │ ─────────────────────────► │  Response ⚡  │
│  Cache      │                            └──────────────┘
└──────┬──────┘
       │ cache miss (~3000ms)
       ▼
┌──────────────────────────────────────────┐
│           Runtime Router                  │
├──────────┬──────────┬──────────┬─────────┤
│  Gemini  │   Dart   │    Go    │  Ollama │
│  2.5     │  Runtime │  Runtime │ (local) │
│  Flash   │          │          │         │
└──────────┴──────────┴──────────┴─────────┘
```

**Performance numbers that matter:**
- Cache hit rate: ~80%
- Cache response time: ~0.03ms
- Full LLM call: ~3000ms
- Average latency with caching: ~300ms

The ⚡ Instant badge in the AI panel fires on every cache hit — the user literally sees the
performance difference in real time.

### Flutter App Architecture (BLoC Pattern)

```
presentation/
├── auth/
│   ├── bloc/              # AuthBloc — auth state machine
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   └── pages/
│       └── login_page.dart
│
├── detection/
│   └── bloc/              # VideoDetectionBloc — camera + WS + AI
│       ├── video_detection_bloc.dart
│       ├── video_detection_event.dart
│       └── video_detection_state.dart
│
├── views/
│   ├── home/
│   │   └── speed_dial_view.dart
│   └── detection/
│       ├── video_detection_view.dart
│       └── image_detection_view.dart
│
└── widgets/
    ├── ai_message_panel.dart      # LLM response with typewriter effect
    └── bounding_box_painter.dart  # Custom paint for YOLO boxes

data/
├── models/
└── repositories/

services/
├── api_service.dart
├── websocket_service.dart
└── storage_service.dart

utils/
└── permission_controller.dart     # Camera/storage permissions

core/
├── constants/
└── routes/
```

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.5+
- Dart SDK 3.5+
- Android Studio or Xcode (for emulators)
- Docker (for backend services)
- Java 17+ (for Spring Boot)

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

# Physical device
flutter devices
flutter run -d <device-id>
```

---

## 📱 Features

### ✅ Implemented

- JWT Authentication (Login/Logout with Spring Boot)
- Real-time Video Detection (WebSocket + YOLOv8)
- Bounding Box Visualization (Custom painter with accurate coordinates)
- LLM Gateway with multi-runtime support + Redis caching
- AI Message Panel with typewriter animation and personality colors per runtime
- Auto-reconnect (WebSocket resilience)
- State Management (BLoC — fully migrated from GetX)
- Local Storage (JWT token persistence)
- Platform-specific networking (Android emulator support)

### 🚧 In Progress

- User Registration
- Posts System (Kafka events)
- Image Detection (upload photo)
- Kafka Event Logging (DynamoDB)
- Push Notifications

### 🎯 Planned

- Offline Detection (TFLite on-device)
- Rive Animations
- User Profile
- Social Features

---

## 🛠️ Tech Stack

### Frontend (Flutter)

| Technology | Purpose | Why? |
|-----------|---------|------|
| Flutter 3.5+ | Cross-platform UI | Single codebase for iOS/Android |
| Dart 3.5+ | Programming language | Null-safety, Records (Dart 3) |
| BLoC | State management | Predictable, testable, industry standard |
| Camera Plugin | Camera access | Native camera control |
| WebSocket | Real-time communication | Bidirectional, low latency |
| SharedPreferences | Local storage | Persist JWT tokens |
| HTTP | REST API calls | Standard networking |

### Backend (Spring Boot)

| Technology | Purpose | Why? |
|-----------|---------|------|
| Spring Boot 3.x | REST API | Enterprise-grade framework |
| Spring Security | Authentication | JWT + OAuth2 |
| PostgreSQL | Primary database | ACID compliance |
| Kafka | Event streaming | Async processing, scalability |
| Docker | Containerization | Consistent environments |

### AI/ML (FastAPI)

| Technology | Purpose | Why? |
|-----------|---------|------|
| FastAPI | Inference API | High performance, async |
| YOLOv8 | Object detection | State-of-the-art accuracy |
| Redis | LRU Cache for LLM | 80% cache hit rate, ~0.03ms response |
| Gemini 2.5 Flash | Primary LLM | Fast, high quality commentary |
| Ollama | Local LLM fallback | Offline capable, no API cost |
| WebSockets | Real-time frames | Low latency inference |

---

## 🔧 Configuration

### Android Emulator Networking

Android emulators cannot access localhost. Use special IP `10.0.2.2`:

```dart
static String get baseUrl {
  if (Platform.isAndroid) return "http://10.0.2.2:8000";  // Emulator
  if (Platform.isIOS) return "http://localhost:8000";      // Simulator
  return "http://127.0.0.1:8000";                          // Desktop/Web
}
```

### Environment Variables

```bash
# Backend (.env)
DATABASE_URL=postgresql://user:pass@localhost:5432/hearts_stars
JWT_SECRET=your-secret-key-here
KAFKA_BROKERS=localhost:9092

# Inference Service (.env)
MODEL_PATH=/models/yolov8n.tflite
CONFIDENCE_THRESHOLD=0.9
REDIS_URL=redis://localhost:6379
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

### Why BLoC? (And why we started with GetX)

Honest answer: GetX was the right choice at the beginning.

When this project started, speed mattered most — prototype fast, get things on screen, validate
the idea. GetX delivers that. Minimal boilerplate, reactive `.obs` variables, built-in navigation.
It genuinely felt like magic.

```dart
// GetX — incredibly concise
final isCameraInitialized = false.obs;
isCameraInitialized.value = true;  // UI updates automatically
```

But as the app grew — camera lifecycle, WebSocket streams, typewriter timers, cursor blink timers,
AI response metadata — the controller became a 300-line god object. Everything was coupled to
everything. Testing was basically impossible because GetX's service locator (`Get.find()`) made
mocking a nightmare. Navigation lived inside controllers, mixing business logic with routing.

Then came the migration to BLoC:

```dart
// BLoC — explicit, traceable, testable
class VideoDetectionBloc extends Bloc<VideoDetectionEvent, VideoDetectionState> {
  VideoDetectionBloc() : super(const VideoDetectionState()) {
    on<VideoDetectionStarted>(_onStarted);
    on<_DetectionsUpdated>(_onDetectionsUpdated);
    on<_AIResponseReceived>(_onAIResponseReceived);
  }
}
```

Every state change is now an event → handler pipeline. You can log every transition globally
with `BlocObserver`. You can test handlers in isolation. The UI declares exactly what data it
needs via `context.select()` — no hidden subscriptions, no reactive spaghetti.

The tradeoff is verbosity. BLoC requires more files and more ceremony. But for a portfolio project
that demonstrates production thinking, that ceremony *is* the point.

**TL;DR:** GetX for speed, BLoC for scale. Knowing when to use which — and being able to migrate
between them — is the actual skill.

### Why WebSocket over HTTP for video?

HTTP: Request → Response (one-shot)
- Client asks, server responds, connection closes
- High latency for real-time

WebSocket: Persistent bidirectional connection
- Send frames continuously, receive detections immediately
- Lower latency, no reconnect overhead per frame

```dart
// HTTP (slow for real-time)
final response = await http.post('/detect', body: frame);

// WebSocket (fast)
_wsService.sendFrame(base64Frame);  // fire and forget
_wsService.dataStream.listen((data) => add(_DetectionsUpdated(data)));
```

### Why Redis LRU Cache for the LLM Gateway?

LLM calls are expensive — ~3000ms and API cost per call. The insight: detection patterns repeat.
If the model sees a heart multiple times in a session, it doesn't need a fresh Gemini call every
time. An LRU cache keyed on detection context hits ~80% of the time, dropping average latency
from ~3000ms to ~300ms. The ⚡ badge in the UI makes this visible to the user.

### Why Repository Pattern?

```dart
// ❌ Without: controller knows too much
class VideoDetectionBloc {
  void loadDetections() async {
    final response = await http.get('/detections');  // tight coupling
  }
}

// ✅ With: clean separation
class DetectionRepository {
  Future<List<Detection>> getDetections() async {
    return _apiService.fetchDetections();
  }
}
```

Switch the data source (API → local DB → mock) without touching business logic.
Test the BLoC with a mock repository. Single responsibility at every layer.

---

## 🐛 Troubleshooting

### Build Issues

```bash
flutter clean
flutter pub get
flutter run

# Android build cache
cd android && ./gradlew clean
cd ..
flutter run
```

### WebSocket Connection Failed

- Check backend is running: `docker ps`
- Verify URL in `api_constants.dart`
- Test: `curl http://10.0.2.2:8000/ping`

### Token Expired

Tokens expire after 30 minutes. Re-login or implement refresh token flow.

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
- LinkedIn: [sunny-orukwo](https://www.linkedin.com/in/sunny-orukwo/)

---

## 🙏 Acknowledgments

- Claude AI — Architecture guidance, debugging partner, and occasional therapist
- YOLOv8 / Ultralytics — For the model
- Flutter Community — Amazing ecosystem
- Spring Boot — Robust backend framework

---

## 🚀 The Dev Journey — From Chaos to Clean Architecture (and Back to Clean Again)

*A first-person account of the battles, bugs, breakthroughs, and one very deliberate architectural U-turn*

Hey there, future me (and anyone curious about the real process). 👋

This isn't a "everything worked perfectly" README. This is the raw journey of building a
real-time AI detection system while learning Flutter, Spring Boot, Kafka, WebSockets, and
eventually BLoC — all simultaneously. Buckle up. 😅

---

### 🔥 The Beginning: "How hard can it be?"

Started with a simple goal: detect hearts and stars in real-time using YOLOv8. Clean, right?

First major realization: my code was a mess. Controllers calling APIs directly, hardcoded URLs,
zero separation of concerns. It worked, sure — but like a house of cards.

Cold shower moment 💦: the architecture wasn't interview-ready. Not portfolio-worthy.

---

### ⚡ Enter GetX: The Seduction of Simplicity

With GetX, things clicked fast. Reactive state in one line:

```dart
final isCameraInitialized = false.obs;
// UI rebuilds automatically. No setState. No boilerplate. Pure magic.
```

And it *was* magic. For a while.

The camera initialized, WebSocket connected, YOLO detections came in, UI updated. All wired up
with GetX in a way that felt effortless. Navigation with `Get.toNamed()`. Dependency injection
with `Get.find()`. Everything just... worked.

The `VideoDetectionController` grew. Then it kept growing. Camera lifecycle, WebSocket streams,
typewriter timers, cursor blink timers, AI response metadata — all in one file.
300 lines. Then 400. Every method knew too much about everything else.

And then I tried to write a test. 😭

`Get.find<VideoDetectionController>()` inside `AIMessagePanel` meant the widget was hard-coupled
to GetX's service locator. Testing in isolation? Basically impossible without spinning up the
entire GetX container. Mocking? Painful.

GetX wasn't wrong. It was the right tool for the prototype phase. The problem was staying there
too long.

---

### 🏗️ The Great Migration: GetX → BLoC

The decision to migrate wasn't dramatic. It was just... obvious.

The codebase had outgrown reactive shortcuts. It needed structure that would survive scale —
and more importantly, structure that would demonstrate production thinking to anyone reading it.

The migration was:
- `VideoDetectionController` → `VideoDetectionBloc` (3 files: bloc, event, state)
- `Obx(() => ...)` → `context.select()` with Dart Records
- `Get.find<VideoDetectionController>()` → `context.read<VideoDetectionBloc>()`
- `Get.toNamed(AppRoutes.home)` → `Navigator.pushNamed(context, AppRoutes.home)`
- `GetMaterialApp` → `MaterialApp`
- 7 `.obs` variables → 1 immutable `VideoDetectionState` with `copyWith()`

The nested `Obx()` inside `AIMessagePanel` (a reactive scope inside another reactive scope for
the cursor blink) became a plain `AnimatedOpacity` reading a bool from state. Cleaner. Testable.
No hidden subscriptions.

The typewriter timer dispatching `_TypewriterTicked` events every 50ms was the most interesting
design decision — timers can't call `emit()` directly because they outlive the event handler's
`Emitter` scope. The solution: dispatch internal events via `add()` from the timer callback,
re-entering the BLoC pipeline safely. A subtle but important pattern.

**The payoff:** every state transition is now explicit, logged, and testable. `BlocObserver` can
watch the entire app's state changes globally without touching a single component. That's the
kind of thing that impresses senior engineers in code reviews.

---

### 🧠 The LLM Gateway: The Part I'm Most Proud Of

While migrating state management, the backend was growing its own ambitious piece: the LLM Gateway.

The concept: every 4 frames, the backend doesn't just return YOLO detections — it sends back
an AI-generated commentary about what it sees. But a raw Gemini call on every 4th frame would
be expensive and slow (~3000ms).

The solution: Redis LRU cache keyed on detection context.

```
Detection patterns → Redis lookup → cache hit (0.03ms) ⚡
                                 → cache miss → Gemini/Ollama/Go/Dart runtime (~3000ms)
```

80% cache hit rate. Average latency dropped from ~3000ms to ~300ms across all responses.

The Flutter side shows this in real time: the ⚡ Instant badge fires on cache hits. The
personality colors change based on which runtime responded (purple for Gemini, pink for Dart,
blue for Go, green for cache/Ollama). The typewriter animation paces the response at 2 chars
per 50ms tick — fast enough to feel dynamic, slow enough to be readable.

This whole system is the technical story I'd tell in any senior engineering interview. Redis
caching strategy, multi-runtime routing, real-time WebSocket delivery, animated presentation
layer — it covers backend architecture, systems thinking, and frontend craft in one feature.

---

### 🎯 The Bounding Box Nightmare

This one tested my sanity. Detections worked, WebSocket sent frames, backend responded... but
the bounding boxes floated in space like a Dalí painting. 🎨

The problem: coordinate transformations. YOLO returns normalized coordinates (0-1) but I was
multiplying by image size, then scaling to screen, forgetting letterboxing, camera rotation,
aspect ratios — all at once.

```dart
print('Raw bbox: $bbox');
print('Normalized: x1=$x1_norm, y1=$y1_norm');
print('Screen pixels: left=$left, top=$top');
```

Logs everywhere. Console looked like The Matrix. But it worked — got those boxes aligned
perfectly and understood every coordinate space involved. ✅

---

### 🔌 Android Emulator: "10.0.2.2? What sorcery is this?"

2 hours of 404 errors from a backend that was clearly running. URL correct, ports open,
backend healthy...

The emulator is its own virtual machine. `localhost` is itself. `10.0.2.2` is your machine.

```dart
if (Platform.isAndroid) return "http://10.0.2.2:8000";  // Magic IP
```

Lesson: read the docs before debugging for hours. 📚

---

### 🕸️ WebSocket Reconnection: The Silent Killer

WebSocket would connect, send a few frames, then... silence. No errors. No crashes. Dead air.

Built a proper reconnection system: max 5 attempts, 3-second delay, graceful degradation.

```dart
void _scheduleReconnect() {
  if (_reconnectAttempts >= _maxReconnectAttempts) return;
  _reconnectTimer = Timer(const Duration(seconds: 3), () => connect());
}
```

Drop WiFi? Auto-reconnects when you're back. That's resilience. 🔄

---

### 🧠 Lessons Learned (The Hard Way)

1. **GetX is great — until it isn't.** Prototype with it, migrate when the complexity demands it.
   Knowing *when* to switch is more valuable than dogmatically picking one from the start.

2. **BLoC verbosity is a feature.** The extra files force you to think about the shape of your
   state machine before you write a single handler. That thinking pays off.

3. **Caching is a superpower.** The Redis LRU layer turned a 3000ms bottleneck into a 0.03ms
   response 80% of the time. Always ask: "what repeats here, and can I cache it?"

4. **Platform quirks are real.** Android emulator networking, iOS permission flows, coordinate
   spaces — test on real devices early and often.

5. **Comments are documentation.** Every architectural decision in this codebase is explained
   in-line. Future me (and recruiters) thank past me for this.

6. **AI assistants are game-changers — but you still debug it yourself.** Claude helped me think
   through BLoC migration patterns and Redis caching strategy. The bugs were still mine to fix.

---

### 🎯 What's Next?

- Posts system with Kafka
- Refresh token implementation
- On-device TFLite inference
- Rive animations (because why not make it pretty?)
- BLoC unit tests with `bloc_test` package

---

### 💬 Final Thoughts

This project taught me more than any tutorial could. The GetX phase, the migration to BLoC,
the LRU caching insight, the coordinate math, the WebSocket resilience — none of that came from
a course. It came from building something real and hitting real walls.

If you're reading this as a recruiter: I don't just know Flutter. I know *why* architectural
decisions get made, when to change them, and how to execute that change cleanly. The git history
on this repo shows the full arc from prototype to production-ready.

If you're reading this as a fellow dev: the migration from GetX to BLoC mid-project felt
terrifying before I started and obvious in retrospect. Do it when the codebase tells you to.
It will tell you.

And to future me: remember when you thought GetX was the final form? Look how far you've come.
Keep building. 💪

---

*Built with ❤️, late nights ☕, and a Redis cache that hit 80% of the time 🚀*

*Big thanks to Claude for being my architecture partner, rubber duck, debugger, and the one who
helped me understand why the Emitter scope doesn't survive a Timer callback. That one deserves
its own medal. 🥇*
