# DevForge 🛠️

**One command to build your complete development environment.**

DevForge solves the entire "new machine setup" problem. Instead of hunting down individual installers, managing paths, and running one-off scripts, DevForge gives you a single, interactive command to configure your machine for your exact tech stack (Flutter, React Native, Python, etc.).

Features:
- **Cross-Platform:** Works on macOS, Linux, and Windows.
- **Idempotent Installs:** Smart enough to skip what's already installed.
- **Profile-Based Setups:** Choose between full setups, IDEs only, or SDKs only.
- **Interactive UI:** Simple, menu-driven CLI.

---

## 🚀 Quick Start

To start DevForge, open your terminal and paste the command for your operating system:

### macOS / Linux
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/parthvatalia/developer-environment-setup/main/install.sh)"
```

### Windows (PowerShell)
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/parthvatalia/developer-environment-setup/main/install.ps1" -OutFile "install.ps1"; .\install.ps1
```

---

## 📦 Supported Tech Stacks

Currently, DevForge supports automated setup profiles for:

1. **Flutter**
   - SDK installation
   - Android Studio & VS Code
   - CocoaPods (macOS)
2. **React Native**
   - Node.js & Watchman
   - JDK (Java Development Kit)
   - Android Studio, VS Code, CocoaPods
3. **Python**
   - Python 3 & Pip
   - Poetry
   - VS Code

## 🤝 Contributing

This project is built to easily expand. Want to add a profile for AI/ML, Go, or Backend/Node? Just add a new `setup_mytech()` function in `install.sh` and `install.ps1` and add it to the main menu switch case!
