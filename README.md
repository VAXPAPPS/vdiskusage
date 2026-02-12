# vdiskusage 💿

**vdiskusage** is a high-performance, professional disk usage analyzer built for Linux. It combines the raw speed of native C/C++ system calls with the modern, reactive UI of Flutter, wrapped in a stunning glassmorphic design.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-linux.svg)
![Status](https://img.shields.io/badge/status-Stable-green.svg)

## ✨ Key Features

### 🚀 **Ultra-Fast Scanning**
- **Native C++ Engine**: Core scanning logic is written in C and accessed via Dart FFI for maximum performance.
- **Direct Syscalls**: Uses efficient `lstat`, `opendir`, and `readdir` calls to bypass overhead.
- **Isolate-Based Concurrency**: Scanning runs in background isolates, ensuring the UI remains buttery smooth at 60FPS even when processing millions of files.

### 📊 **Interactive Visualization**
- **Squarified Treemap**: Identify large directories instantly with a high-performance, interactive treemap navigation.
- **Deep Zoom**: Double-click to drill down into folders; use breadcrumbs to navigate back.
- **Category Insights**: Files are color-coded by type (Images, Video, Code, etc.) for quick visual identification.

### 🛠 **Pro Tools**
- **Smart Filtering**: Filter by file category, minimal size, or search by name.
- **Context Actions**: Open files, reveal in file manager, copy paths, or delete directly from the app.
- **Disk Dashboard**: View real-time usage stats for all mounted partitions.

### 🎨 **Premium UI/UX**
- **Glassmorphic Design**: Modern, translucent interface that blends beautifully with the Linux desktop.
- **Fluid Animations**: Smooth transitions and micro-interactions throughout.
- **Responsive Sidebar**: Collapsible navigation for maximizing screen real estate.

## 🏗 Architecture

vdiskusage follows a strict **Clean Architecture** pattern to ensure maintainability and scalability:

- **Presentation**: BLoC state management, Flutter widgets, Glassmorphism.
- **Domain**: Pure Dart entities and abstract repository interfaces.
- **Data**: Repository implementations, caching logic.
- **Infrastructure**:
    - `native_scanner.dart`: FFI bindings to the C engine.
    - `ffi/main.cc`: Low-level C scanning implementation.
    - `isolate_scanner_service.dart`: Multithreaded orchestration.

## 🔧 Installation & Build

### Prerequisites
- Linux (tested on Ubuntu/Debian based systems)
- Flutter SDK
- CMake & Ninja build tools
- Clang/GCC

### Build Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/vaxp/vdiskusage.git
   cd vdiskusage
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Build the C library**
   The CMake build process handled automatically by Flutter, but ensure you have build tools:
   ```bash
   sudo apt-get install cmake ninja-build clang pkg-config libgtk-3-dev
   ```

4. **Run or Build**
   ```bash
   # Run in debug mode
   flutter run -d linux

   # Build release executable
   flutter build linux --release
   ```

## ⚙️ Configuration

Customize your experience via the Settings panel:
- **Excluded Paths**: Ignore specific directories (e.g., `/proc`, `/sys`).
- **Max Depth**: Limit scan depth for performance on massive filesystems.
- **Cache**: Manage scan result caching to speed up subsequent views.

## 🤝 Contributing

Contributions are welcome! Please verify that your changes pass the analyzer:

```bash
flutter analyze
```



---
*This project is part of the VAXP organization*
