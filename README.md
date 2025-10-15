# Hearts & Stars 💖⭐

Flutter project for object detection (hearts & stars) with YOLOv8, GetX state management, and custom UI.

---

## 🚀 Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/Kus4n4g1777/hearts_and_stars_v3.git
cd hearts_and_stars_v3
```

### 2. Install Flutter
- Make sure Flutter is installed in `C:\Users\YOUR_USERNAME\dev\flutter`
- Add Flutter to your PATH if not already:
  ```powershell
  $env:Path += ";C:\Users\YOUR_USERNAME\dev\flutter\bin"
  ```

Check version:
```bash
flutter --version
```

### 3. Android SDK
- Ensure the **Android SDK** is inside `C:\Users\YOUR_USERNAME\YOUR_PROJECT_PATH\Android\sdk`
- Update environment variables:
  - `ANDROID_HOME=C:\Users\YOUR_USERNAME\YOUR_PROJECT_PATH\Android\sdk`
  - Add `platform-tools` to PATH:
    ```powershell
    $env:Path += ";C:\Users\YOUR_USERNAME\YOUR_PROJECT_PATH\Android\sdk\platform-tools"
    ```

### 4. Install Dependencies
Run:
```bash
flutter pub get
```

### 5. Assets
- Images live inside `assets/images/`
- Declare them in `pubspec.yaml`:
  ```yaml
  flutter:
    uses-material-design: true
    assets:
      - assets/images/
  ```

### 6. Run the app
Start your emulator or connect a device, then:
```bash
flutter run 🚀
```

---

## 🛠️ Tech Stack
- **Flutter 3.5.x**
- **Dart 3.5.x**
- **GetX** (state management + routing)
- **YOLOv8 TFLite** (object detection)
- **Android SDK** for builds
- **FastAPI** (backend via Docker, JWT-enabled in Docker Compose)
- **Docker** (for local backend testing)

---

## 📂 Project Structure
```
lib/
 ├── main.dart
 ├── views/
 │   ├── login_view.dart
 │   ├── speed_dial_view.dart
 │   ├── image_detection_view.dart
 │   ├── video_detection_view.dart
 │   └── ping-test-view.dart          # Intermediate view to test FastAPI connection
 ├── controllers/
 │   ├── auth_controller.dart         # WIP: authentication via FastAPI Docker Compose
 │   └── permission_controller.dart   # WIP: camera & storage permissions
 ├── models/...                       # WIP
 ├── services/
 │   └── api_service.dart             # Handles FastAPI calls (ping example)
 ├── utils/...                        # WIP
 ├── widgets/...                      # WIP
assets/
 └── images/
     └── background.jpg
```

---

## ⚡ Ping Test (FastAPI)
To test a simple FastAPI connection, the project includes a **Ping Test view** with a button:

### 1. FastAPI Setup (Local Test)
1. Create a virtual environment:
```bash
python -m venv .venv
```
2. Activate it:
```powershell
# Windows
.venv\Scripts\activate
```
3. Install FastAPI and Uvicorn:
```bash
pip install fastapi uvicorn
```
4. Create `main.py` in a folder like `src/`:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/ping")
async def ping():
    return {"message": "pong from FastAPI 🚀"}
```
5. Run FastAPI:
```bash
uvicorn src.main:app --reload --host 127.0.0.1 --port 8000
```

Now the ping button in the app will communicate with the backend at `http://127.0.0.1:8000/ping`.

> ⚠️ Note: For Android emulator, replace `127.0.0.1` with `10.0.2.2` to connect to your host machine.

---

## 🔧 Troubleshooting & Notes
- Run `flutter clean` after moving directories or editing `pubspec.yaml`.
- Full restart is needed when adding new assets (hot reload won’t show them).
- Update all PATH environment variables if you move the project folder.
- Android emulators may throw Google Play Services errors (`NetworkCapability 37 out of range`) — usually safe to ignore on a real device.
- When testing the ping view, ensure the backend FastAPI server is running.
- When adding assets or editing `pubspec.yaml`, be careful with spaces and indentation.

---

## ✨ Future Work
- Connect `auth_controller.dart` to FastAPI backend via Docker Compose using JWT authentication.
- Implement permission handling in `permission_controller.dart`.
- Add a create user form to allow user registration in the future.
- Expand object detection features and UI improvements.
- Repurpose **Ping Test view** for other backend interactions.

---

## 📝 Commit Note (Intermediate)
This commit introduces:
- `ping-test-view.dart` for testing FastAPI connectivity.
- `api_service.dart` with `ping()` method.
- README instructions for setting up a local FastAPI server.
- Keeps the button ready for future backend features ("ping pong" style 😉).

# Flutter Integration & Backend Connection

This document summarizes all the steps, challenges, and solutions we applied to connect our Flutter application with the backend running via Docker Compose since our last commit.

## 1. Setup & API Service

- Created a **dedicated `ApiService`** class in Flutter for authentication and protected routes.
- Handled **platform-specific base URLs**:
  - Android Emulator: `http://10.0.2.2:8000`
  - iOS Simulator / Desktop: `http://127.0.0.1:8000`
- Added functions:
  - `login(username, password)` → sends POST request, stores JWT in `SharedPreferences`.
  - `validateToken()` → checks if the JWT is still valid.
  - `getProtectedData()` → fetches data from protected routes.
  - `ping()` → simple connectivity test for the backend.

**Challenges & Fixes:**
- Initial 404 errors due to wrong base URL. Confirmed via Flutter prints/logs.
- Backend CORS whitelist updated to allow:
  ```
  "http://10.0.2.2:8000"   # Flutter Emulator
  "http://127.0.0.1:8000"  # Flutter Desktop / Android Studio
  ```
- Flutter requests now properly reach the FastAPI backend.

---

## 2. Android Studio & Emulator Adjustments

- Confirmed the **emulator IP resolution**:
  - `10.0.2.2` maps to host `127.0.0.1`.
- Encountered storage issues on emulator:
  - Emulator runs out of disk space when using default drive.
  - Solution: **moved the emulator to another drive** with sufficient space to avoid corruption and I/O errors.
- Added **Flutter prints** to check endpoint URLs and token usage during runtime for debugging.

---

## 3. Docker & Networking Challenges

- Backend runs in **Docker Compose**, ports exposed:
  - `8000` for FastAPI
- Flutter Emulator needed proper networking:
  - Used `10.0.2.2` to reach the host Docker network.
- Adjusted **CORS in FastAPI** to handle requests from emulator, Flutter web, React, and other frontend environments.

**Errors Encountered:**
- 404 on initial requests → resolved by verifying endpoint paths and base URL.
- Token verification failures → ensured JWT was stored correctly in `SharedPreferences` and sent in headers.
- Docker frontend container failing due to **disk I/O / metadata.db errors**:
  - Needed to restart Docker and prune unused volumes/images safely.
  - Android Studio Emulator storage relocated to avoid conflicts.

---

## 4. Development Workflow Notes

- Used `print()` in Flutter for debugging:
  ```dart
  print('Flutter API baseUrl: $baseUrl');
  ```
- Verified connectivity using `ping()` endpoint before full integration.
- Ensured JWT authentication flow works end-to-end:
  1. Login → stores token.
  2. Validate token → succeeds.
  3. Access protected data → works with headers.

---

## 5. Troubleshooting & Recommendations

- **Emulator storage**: Always check disk space; move to larger drives if running into I/O errors.
- **Docker cleanup**: Use safe pruning commands to remove dangling images, networks, and volumes.
- **CORS**: Always ensure FastAPI allows the correct origins for all frontend clients.
- **Debugging in Flutter**: Add temporary print statements for URLs, tokens, and responses to verify connectivity.

---

✅ With these steps, the Flutter app successfully connects to the backend, authenticates, and accesses protected endpoints via Docker Compose without CORS or networking issues.

---

# 🚀 The Crazy Dev Journey — From Chaos to a Smooth Real-Time AI Pipeline

Hey everyone! 👋

This post is part of my dev diary — where **Claude, ChatGPT, and Gemini** all joined forces to help me survive a jungle of bugs, tokens, sockets, and weird bounding boxes that looked like Salvador Dalí paintings. 😂

Let me take you through the ride…

---

## 🧠 The Context

I’ve been building a **real-time AI detection system** with Flutter on the client side, a Python backend doing inference with **YOLOv10 TFLite**, and a **React + Docker + WebSockets** ecosystem handling the rest. Sounds clean, right? Yeah… until it wasn’t. 😅

We had:
- Wrong coordinate scaling (boxes floating outside the screen 😭)
- Android configuration issues (JDK, embedding errors, tflite dependencies)
- WebSockets disconnecting randomly
- JWTs expiring mid-demo (of course, right when I was showing it off)
- Docker containers refusing to build because of missing layers

But we didn’t give up, hermano 💪

---

## 🧩 Fixing the Android Configuration

This one was a nightmare. `MainActivity.kt` was showing unresolved references. The trick?

```kotlin
// android/app/build.gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.ai_detector"
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
}
```

Then, reconfigure JDK:
> File → Settings → Build, Execution, Deployment → Build Tools → Gradle → Gradle JDK → Choose correct JDK (e.g. Temurin 17)

Boom 💥 no more red squiggles.

---

## ⚡ Real-Time Communication with WebSockets

We implemented WebSockets to send **frames and detection results** in real-time without blocking the camera.

### Backend (Python + FastAPI + WebSockets)
```python
from fastapi import FastAPI, WebSocket
import json

app = FastAPI()

@app.websocket("/ws")
async def websocket_endpoint(ws: WebSocket):
    await ws.accept()
    while True:
        data = await ws.receive_text()
        # Process image frame here or trigger inference
        result = {"status": "ok", "detections": []}
        await ws.send_text(json.dumps(result))
```

### Flutter Client
```dart
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse('ws://your-server-ip/ws'),
);

channel.stream.listen((message) {
  print('Server: $message');
});

channel.sink.add('frame_data_here');
```

Simple, but game-changing. Once the communication stabilized, the UX skyrocketed.

---

## 🔄 Refresh Token System (Because JWTs Die Too Soon)

You know the pain — you’re in the middle of an inference, and suddenly *boom*, token expired.

### Backend
```python
@app.post('/refresh')
def refresh_token(refresh_token: str):
    # Verify refresh token
    if is_valid(refresh_token):
        return {"access_token": create_new_jwt()}
    raise HTTPException(status_code=401, detail="Invalid refresh token")
```

### React Client
```javascript
axios.interceptors.response.use(
  response => response,
  async error => {
    if (error.response.status === 401) {
      const refresh = localStorage.getItem('refreshToken');
      const newToken = await refreshAccessToken(refresh);
      axios.defaults.headers.common['Authorization'] = `Bearer ${newToken}`;
      return axios(error.config);
    }
    return Promise.reject(error);
  }
);
```

Boom. Now your app doesn’t freak out every 15 minutes.

---

## 🎯 Bounding Boxes and Coordinate Transformations

We had one big visual bug — the boxes were stretched, misplaced, and even wider than the screen. The fix was understanding **letterboxing and scaling ratios** correctly.

```python
def letterbox(img, new_shape=(640, 640)):
    shape = img.shape[:2]
    r = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
    new_unpad = int(round(shape[1] * r)), int(round(shape[0] * r))
    dw, dh = (new_shape[1] - new_unpad[0]) / 2, (new_shape[0] - new_unpad[1]) / 2
    img = cv2.resize(img, new_unpad, interpolation=cv2.INTER_LINEAR)
    img = cv2.copyMakeBorder(img, int(dh), int(dh), int(dw), int(dw), cv2.BORDER_CONSTANT, value=(114,114,114))
    return img, r, (dw, dh)
```

### And in Flutter:
```dart
final scaleX = size.width / imageSize.width;
final scaleY = size.height / imageSize.height;

final left = x1_img * scaleX;
final top = y1_img * scaleY;
final right = x2_img * scaleX;
final bottom = y2_img * scaleY;

canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
```

Now the rectangles finally stopped acting drunk and aligned perfectly with the objects. 😂

---

## 🐳 Docker and Deployment

We also cleaned up the Docker build:
```dockerfile
FROM python:3.10
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["python", "main.py"]
```
Then in React:
```bash
npm run build
serve -s build -l 3000
```

Everything talking to each other — the sweet sound of distributed harmony.

---

## 🎥 UX Priority — Keep the Camera Running!

This was key. Instead of freezing the camera waiting for inference, we:
- Captured frames continuously.
- Sent **only one every N frames** to the backend.
- Kept the camera live for smooth UX.

```dart
if (frameCount % 10 == 0) {
  sendFrameToServer(frame);
}
frameCount++;
```

Performance doubled, device stayed cool, and users didn’t think the app crashed. 🧊

---

## 💬 Debugging — The Art of Talking to Yourself

We added tons of debug logs everywhere — from Python’s inference:
```python
print(f"[DEBUG] Detection {i}: {label} ({confidence:.2f})")
```
To Flutter’s painter:
```dart
print('  Screen pixels: left=$left, top=$top, right=$right, bottom=$bottom');
```
Every log was like a breadcrumb in a dark forest. 🪶

---

## 💡 Lessons Learned
- Never trust coordinate math the first time.
- Android’s Gradle will betray you if you look away for a second.
- WebSockets are your best friend — until you forget to handle disconnects.
- Refresh tokens save demos.
- Debug logs save sanity.

---

## 🧾 Final Thoughts

We turned chaos into a **real-time, secure, scalable AI pipeline** with smooth UX, resilient backend, and accurate detection. From camera to inference, everything now flows beautifully.

**Claude**, **ChatGPT**, and **Gemini** — you three deserve medals 🥇🥈🥉 for helping me debug my soul.

And to future me reading this post: next time, **start the logs from the beginning**. 😂

