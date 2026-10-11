# SLA Task Tracker

**SLA Task Tracker** is a modern, cross-platform Flutter application designed to help teams track project tasks, monitor SLA (Service Level Agreement) deadlines, and manage team members effectively. This is a student activity based work.

---

## 🌟 Key Features

- 📊 **Interactive Dashboard**
  - Real-time task statistics (`Total Tasks`, `On Track`, `At Risk`, `Overdue`).
  - Visual task completion progress charts and recent activity logs.
  - Auto-refreshing metrics upon navigation.

- 📋 **Task Management & Editing**
  - Create, view, edit, and search tasks seamlessly.
  - Filter tasks by SLA status (`All`, `On Track`, `At Risk`, `Overdue`, `Completed`).
  - Assign tasks to team members with custom deadlines and priority levels (`Low`, `Medium`, `High`).

- 📈 **SLA Visualization & Analytics**
  - Real-time dynamic SLA deadline calculation (`On Track`, `At Risk`, `Overdue`, `Completed`).
  - Status distribution bar charts and upcoming deadline countdowns.

- 👥 **Team Member Management**
  - Add, edit, and remove team members.
  - Form validation for names and roles to maintain data integrity.

- 🎨 **Modern Design & Custom Palette**
  - Material 3 theme styling with a custom color scheme (`Primary`, `Secondary`, `Accent`, `Background`, `Text`).
  - Responsive layouts supporting Mobile, Desktop, and Web.

- 💾 **Cross-Platform Persistence**
  - SQLite local database storage powered by `sqflite`, `sqflite_common_ffi`, and `sqflite_common_ffi_web`.
  - Runs natively on Android, iOS, macOS, Windows, Linux, and Web (Chrome).

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.5.4`)
- **Database**: `sqflite`, `sqflite_common_ffi`, `sqflite_common_ffi_web`
- **UI Design**: Material Design 3
- **State Management**: `StatefulWidget` & Async Futures

---

## 📂 Project Structure
the project structure is based from lib since everything done is in lib/ directory.

```
lib/
.
├── data
│   └── sample_tasks.dart
├── logic
│   └── sla_calculator.dart
├── main.dart
├── models
│   ├── sla_rule.dart
│   ├── sla_settings.dart
│   ├── sla_status.dart
│   ├── task.dart
│   └── user.dart
├── screens
│   ├── appSettings_page.dart
│   ├── create_page.dart
│   ├── dashboard_page.dart
│   ├── editProfile_page.dart
│   ├── profile_page.dart
│   ├── signIn_page.dart
│   ├── taskDetail_page.dart
│   ├── taskList_page.dart
│   ├── taskStatistic_page.dart
│   └── teamMember_page.dart
├── services
│   ├── database_helper.dart
│   ├── settings_storage.dart
│   ├── user_queries.dart
│   └── user_session.dart
├── theme
│   └── app_theme.dart
├── utils
│   ├── app_colors.dart
│   ├── app_routes.dart
│   ├── create_validator.dart
│   ├── date_format.dart
│   ├── initials.dart
│   └── profile_validator.dart
└── widgets
    ├── createTask_form.dart
    ├── deadline_tile.dart
    ├── error_view.dart
    ├── fade_slide_in.dart
    ├── menu_tile.dart
    ├── preferences_card.dart
    ├── profile_card.dart
    ├── sla_badge.dart
    ├── sla_chip.dart
    ├── sla_rule_tile.dart
    ├── status_bar_chart.dart
    ├── taskDetails.dart
    └── user_avatar.dart

9 directories, 42 files
```

---

## 🚀 Getting Started

### Prerequisites

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `3.5.4` or higher).
2. Ensure Android Studio, Xcode (for macOS/iOS), or Chrome is configured.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/sla_task_tracker.git
   cd sla_task_tracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   - On **Chrome (Web)**:
     ```bash
     flutter run -d chrome
     ```
   - On **macOS Desktop**:
     ```bash
     flutter run -d macos
     ```
   - On **Android / iOS Emulator**:
     ```bash
     flutter run
     ```

---

## 🎨 Color Palette

| Token | RGB Color | Hex | Usage |
| :--- | :--- | :--- | :--- |
| **Primary** | `rgb(6, 66, 0)` | `#064200` | AppBars, primary buttons |
| **Secondary** | `rgb(221, 219, 255)` | `#DDDBFF` | Borders, cards, accents |
| **Accent** | `rgb(68, 61, 255)` | `#443DFF` | Highlight buttons, floating actions |
| **Background** | `rgb(251, 251, 254)` | `#FBFBFE` | Scaffold background |
| **Text** | `rgb(4, 3, 22)` | `#040316` | Typography, headings |

---
## contributors
1. [Maxime Lilian Hirwa](https://github.com/HMaxiime)
2. [Lisa Ineza](https://github.com/lisaineza)
3. [Ishami Irené](https://github.com/ishami-i)
4. [Jonathan Ishimwe](https://github.com/IshimweJ-Ona)

## 📝 License

This project is licensed under the MIT License.
