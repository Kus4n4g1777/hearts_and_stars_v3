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

