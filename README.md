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

