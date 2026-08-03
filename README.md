# AXYZ

A sophisticated, modern, and interactive Pomodoro timer built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=dart&logoColor=white)

## Overview

axyz is designed to offer a premium and effortless experience for managing your focus sessions. Utilizing device sensors for motion-based controls and an intuitive interface, AXYZ helps you maximize your productivity. The sleek, deep dark mode design ensures minimal distraction while you work.

## Key Features

- **Pomodoro Timer**: Effortlessly track your focus sessions, short breaks, and long breaks.
- **Motion Controls**: Innovative use of device sensors for intuitive, gesture-based interactions.
- **Always Awake**: Keeps your screen awake automatically during active sessions.
- **Audio Cues**: Subtle audio notifications for session transitions.
- **Personalized UI**: Deep, sleek dark mode design with seamless edge-to-edge navigation.
- **Focus First**: A clean, distraction-free environment to get things done.

## Technologies Used

- **Framework**: [Flutter](https://flutter.dev/) (v3.x)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Sensors**: [sensors_plus](https://pub.dev/packages/sensors_plus)
- **Audio**: [audioplayers](https://pub.dev/packages/audioplayers)
- **Wake Lock**: [wakelock_plus](https://pub.dev/packages/wakelock_plus)

## Getting Started

To run this project locally, follow these steps:

1. **Clone the repository**
   ```bash
   git clone https://github.com/KlyrhonMiko/axyz.git
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

- `/lib/core`: Core utilities, theming (e.g., `AppTheme`), and shared components.
- `/lib/features`: Feature-specific modules (e.g., `timer`).
- `/lib/main.dart`: Entry point and global configuration.
