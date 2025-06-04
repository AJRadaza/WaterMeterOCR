# WaterMeterOCR
Flutter App for Automated Water Meter Reading

A cross-platform mobile application built with Flutter to automate water meter reading using image processing and Optical Character Recognition (OCR). The app captures meter images, enhances them using image processing techniques, extracts readings via OCR, and updates billing data—minimizing human error and improving efficiency in water utility operations.

## Screenshots:

![image](https://github.com/user-attachments/assets/abb17125-39b7-46a4-af6a-0ed36414fe1e)
![image](https://github.com/user-attachments/assets/e25ac3a2-cb54-4b4c-a38f-8dc84171417f)

## Build Instructions

To run and build this Flutter app locally, follow the steps below.

---

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.x or later recommended)
- Android Studio or VS Code with Flutter & Dart plugins
- Git
- An Android device or emulator

---

### Clone the Repository

```bash
git clone https://github.com/AJRadaza/WaterMeterOCR.git
cd WaterMeterOCR
```

### Install Dependencies

```bash
flutter pub get
```

### Build APK

```bash
flutter build apk --release
```

The APK will be located at:
build/app/outputs/flutter-apk/app-release.apk

### Notes
Make sure you have an emulator running or a device connected.
For iOS, you need a Mac with Xcode installed.