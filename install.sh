#!/usr/bin/env bash

# DevForge: developer-environment-setup
# One command to build your complete development environment.

set -e

# --- UI Colors & Formatting ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- OS Detection ---
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          echo -e "${RED}Unsupported OS: ${OS}${NC}"; exit 1;;
esac

# --- Dependency Management ---
install_package() {
    local pkg=$1
    local cmd_name=${2:-$pkg}
    local app_name=$3

    if command -v "$cmd_name" &> /dev/null; then
        echo -e "✅ ${GREEN}$pkg${NC} is already installed (found in PATH)."
        return 0
    fi

    if [ "$MACHINE" == "Mac" ] && [ -n "$app_name" ]; then
        if [ -d "/Applications/$app_name" ] || [ -d "$HOME/Applications/$app_name" ]; then
            echo -e "✅ ${GREEN}$pkg${NC} is already installed (found in Applications)."
            return 0
        fi
    fi

    if [ "$MACHINE" == "Mac" ]; then
        if brew list $pkg &>/dev/null || brew list --cask $pkg &>/dev/null; then
            echo -e "✅ ${GREEN}$pkg${NC} is already installed."
        else
            echo -e "Installing ${CYAN}$pkg${NC} via Homebrew..."
            brew install $pkg || brew install --cask $pkg
        fi
    elif [ "$MACHINE" == "Linux" ]; then
        if dpkg -l | grep -q -w $pkg; then
            echo -e "✅ ${GREEN}$pkg${NC} is already installed."
        else
            echo -e "Installing ${CYAN}$pkg${NC} via apt..."
            sudo apt update && sudo apt install -y $pkg
        fi
    fi
}

setup_package_manager() {
    if [ "$MACHINE" == "Mac" ]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo -e "✅ ${GREEN}Homebrew${NC} is installed."
        fi
    fi
}

add_to_path() {
    local path_to_add=$1
    local profile_file="${HOME}/.zshrc"
    if [ -f "${HOME}/.bashrc" ] && [ ! -f "${HOME}/.zshrc" ]; then
        profile_file="${HOME}/.bashrc"
    fi
    
    if ! grep -q "$path_to_add" "$profile_file"; then
        echo "export PATH=\"\$PATH:$path_to_add\"" >> "$profile_file"
        echo -e "✅ Added $path_to_add to $profile_file"
    fi
}

# --- Technology Profiles ---

setup_flutter() {
    echo -e "\n${BLUE}╭── Flutter Setup ──╮${NC}"
    echo -e "  [1] 📦 Full Setup (SDK, Android Studio, VS Code, CocoaPods)"
    echo -e "  [2] 🛠️  Only SDK"
    echo -e "  [3] 💻 Only IDEs (Android Studio & VS Code)"
    echo ""
    read -p "Select option (1-3): " FLUTTER_OPT

    if [[ "$FLUTTER_OPT" == "1" || "$FLUTTER_OPT" == "2" ]]; then
        echo -e "${CYAN}Installing Flutter SDK...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package flutter
        else
            # Linux manual install fallback if snap/apt is not ideal
            install_package snapd
            sudo snap install flutter --classic
        fi
        
        # Post-install config
        echo -e "${CYAN}Configuring Flutter...${NC}"
        flutter config --no-analytics
        flutter precache
    fi

    if [[ "$FLUTTER_OPT" == "1" || "$FLUTTER_OPT" == "3" ]]; then
        echo -e "${CYAN}Installing IDEs and toolchains...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package visual-studio-code code "Visual Studio Code.app"
            install_package android-studio studio "Android Studio.app"
            install_package cocoapods pod
            echo -e "${CYAN}Setting up Android SDK paths...${NC}"
            add_to_path "\$HOME/Library/Android/sdk/platform-tools"
            add_to_path "\$HOME/Library/Android/sdk/cmdline-tools/latest/bin"
            add_to_path "\$HOME/Library/Android/sdk/emulator"
        else
            install_package code
            # Android studio installation via apt/snap on Linux
            sudo snap install android-studio --classic
            echo -e "${CYAN}Setting up Android SDK paths...${NC}"
            add_to_path "\$HOME/Android/Sdk/platform-tools"
            add_to_path "\$HOME/Android/Sdk/cmdline-tools/latest/bin"
            add_to_path "\$HOME/Android/Sdk/emulator"
        fi
    fi
    
    echo -e "\n${YELLOW}Running flutter doctor for verification...${NC}"
    flutter doctor || true
    echo -e "✅ ${GREEN}Flutter setup complete!${NC}"
}

setup_react_native() {
    echo -e "\n${BLUE}╭── React Native Setup ──╮${NC}"
    echo -e "  [1] 📦 Full Setup (Node, Watchman, Ruby, JDK, Android Studio, iOS toolkit)"
    echo -e "  [2] 🛠️  Only SDKs (Node, JDK, Watchman)"
    echo ""
    read -p "Select option (1-2): " RN_OPT

    if [[ "$RN_OPT" == "1" || "$RN_OPT" == "2" ]]; then
        echo -e "${CYAN}Installing core React Native dependencies...${NC}"
        install_package node
        
        if [ "$MACHINE" == "Mac" ]; then
            install_package watchman
            install_package openjdk@17 java
            install_package ruby
        else
            install_package watchman
            install_package openjdk-17-jdk java
        fi
    fi

    if [[ "$RN_OPT" == "1" ]]; then
        echo -e "${CYAN}Installing Mobile Toolchains...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package cocoapods pod
            install_package android-studio studio "Android Studio.app"
            install_package visual-studio-code code "Visual Studio Code.app"
            echo -e "${CYAN}Setting up Android SDK paths...${NC}"
            add_to_path "\$HOME/Library/Android/sdk/platform-tools"
            add_to_path "\$HOME/Library/Android/sdk/cmdline-tools/latest/bin"
            add_to_path "\$HOME/Library/Android/sdk/emulator"
        else
            sudo snap install android-studio --classic
            install_package code
            echo -e "${CYAN}Setting up Android SDK paths...${NC}"
            add_to_path "\$HOME/Android/Sdk/platform-tools"
            add_to_path "\$HOME/Android/Sdk/cmdline-tools/latest/bin"
            add_to_path "\$HOME/Android/Sdk/emulator"
        fi
    fi
    echo -e "✅ ${GREEN}React Native setup complete!${NC} (Use npx react-native init to start)"
}

setup_python() {
    echo -e "\n${BLUE}╭── Python Setup ──╮${NC}"
    echo -e "  [1] 📦 Full Setup (Python, Pipenv/Poetry, VS Code)"
    echo -e "  [2] 🛠️  Only SDK (Python & Pip)"
    echo ""
    read -p "Select option (1-2): " PY_OPT

    if [[ "$PY_OPT" == "1" || "$PY_OPT" == "2" ]]; then
        echo -e "${CYAN}Installing Python...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package python
        else
            install_package python3
            install_package python3-pip pip3
        fi
    fi

    if [[ "$PY_OPT" == "1" ]]; then
        echo -e "${CYAN}Installing Package Managers & IDEs...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package poetry
            install_package visual-studio-code code "Visual Studio Code.app"
        else
            pip3 install poetry --break-system-packages || pip3 install poetry
            install_package code
            add_to_path "\$HOME/.local/bin"
        fi
    fi
    echo -e "✅ ${GREEN}Python setup complete!${NC}"
}


# --- Main Menu ---
echo -e "${BLUE}╭──────────────────────────────────────────╮${NC}"
echo -e "${BLUE}│${NC} ${GREEN}                DevForge                ${NC} ${BLUE}│${NC}"
echo -e "${BLUE}│${NC} ${CYAN}  One command to build your workspace   ${NC} ${BLUE}│${NC}"
echo -e "${BLUE}╰──────────────────────────────────────────╯${NC}"
echo -e "Detected System: ${YELLOW}$MACHINE${NC}\n"

setup_package_manager

while true; do
    echo -e "\n${CYAN}What technology would you like to set up?${NC}"
    echo -e "  [1] 🔵 Flutter"
    echo -e "  [2] ⚛️  React Native"
    echo -e "  [3] 🐍 Python"
    echo -e "  [q] ❌ Quit"
    echo ""
    read -p "Select an option (1-3, q): " TECH_OPT

    case $TECH_OPT in
        1) setup_flutter ;;
        2) setup_react_native ;;
        3) setup_python ;;
        q|Q) echo "Exiting DevForge. Happy coding!"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Try again.${NC}" ;;
    esac
done
