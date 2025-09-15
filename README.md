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

---

## 📂 Project Structure
```
lib/
 ├── main.dart
 ├── views/
 │   ├── login_view.dart
 │   ├── speed_dial_view.dart
 │   ├── image_detection_view.dart
 │   └── video_detection_view.dart
 ├── controllers/
 │   ├── auth_controller.dart       # WIP: authentication via FastAPI Docker Compose
 │   └── permission_controller.dart # WIP: camera & storage permissions
 ├── models/...                     # WIP
 ├── services/...                   # WIP
 ├── utils/...                      # WIP
 ├── widgets/...                    # WIP
assets/
 └── images/
     └── background.jpg
```

---

## 🔧 Troubleshooting & Notes
- Run `flutter clean` after moving directories or editing `pubspec.yaml`.
- Full restart is needed when adding new assets (hot reload won’t show them).
- Update all PATH environment variables if you move the project folder.
- Android emulators may throw Google Play Services errors (`NetworkCapability 37 out of range`) 
- The previous error can usually be ignored when testing on a real device.
- When adding assets or editing pubspec.yaml, be careful with spaces and indentation.
---

## ✨ Future Work
- Connect `auth_controller.dart` to FastAPI backend via Docker Compose using JWT authentication.
- Implement permission handling in `permission_controller.dart`.
- Add a create user form to allow user registration in the future.
- Add enhanced object detection features and UI improvements.

Happy coding ❤️⭐

