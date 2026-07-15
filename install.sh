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
    echo -e "\n${BLUE}--- Flutter Setup ---${NC}"
    echo "1) Full Setup (SDK, Android Studio, VS Code, CocoaPods)"
    echo "2) Only SDK"
    echo "3) Only IDEs (Android Studio & VS Code)"
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
            install_package visual-studio-code
            install_package android-studio
            install_package cocoapods
        else
            install_package code
            # Android studio installation via apt/snap on Linux
            sudo snap install android-studio --classic
        fi
    fi
    
    echo -e "\n${YELLOW}Running flutter doctor for verification...${NC}"
    flutter doctor || true
    echo -e "✅ ${GREEN}Flutter setup complete!${NC}"
}

setup_react_native() {
    echo -e "\n${BLUE}--- React Native Setup ---${NC}"
    echo "1) Full Setup (Node, Watchman, Ruby, JDK, Android Studio, iOS toolkit)"
    echo "2) Only SDKs (Node, JDK, Watchman)"
    read -p "Select option (1-2): " RN_OPT

    if [[ "$RN_OPT" == "1" || "$RN_OPT" == "2" ]]; then
        echo -e "${CYAN}Installing core React Native dependencies...${NC}"
        install_package node
        
        if [ "$MACHINE" == "Mac" ]; then
            install_package watchman
            install_package openjdk@17
            install_package ruby
        else
            install_package watchman
            install_package openjdk-17-jdk
        fi
    fi

    if [[ "$RN_OPT" == "1" ]]; then
        echo -e "${CYAN}Installing Mobile Toolchains...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package cocoapods
            install_package android-studio
            install_package visual-studio-code
        else
            sudo snap install android-studio --classic
            install_package code
        fi
    fi
    echo -e "✅ ${GREEN}React Native setup complete!${NC} (Use npx react-native init to start)"
}

setup_python() {
    echo -e "\n${BLUE}--- Python Setup ---${NC}"
    echo "1) Full Setup (Python, Pipenv/Poetry, VS Code)"
    echo "2) Only SDK (Python & Pip)"
    read -p "Select option (1-2): " PY_OPT

    if [[ "$PY_OPT" == "1" || "$PY_OPT" == "2" ]]; then
        echo -e "${CYAN}Installing Python...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package python
        else
            install_package python3
            install_package python3-pip
        fi
    fi

    if [[ "$PY_OPT" == "1" ]]; then
        echo -e "${CYAN}Installing Package Managers & IDEs...${NC}"
        if [ "$MACHINE" == "Mac" ]; then
            install_package poetry
            install_package visual-studio-code
        else
            pip3 install poetry --break-system-packages || pip3 install poetry
            install_package code
        fi
    fi
    echo -e "✅ ${GREEN}Python setup complete!${NC}"
}


# --- Main Menu ---
echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}             DevForge                  ${NC}"
echo -e "${CYAN} One command to build your workspace   ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "Detected System: ${YELLOW}$MACHINE${NC}"
echo ""

setup_package_manager

while true; do
    echo -e "\n${CYAN}What technology would you like to set up?${NC}"
    echo "1) Flutter"
    echo "2) React Native"
    echo "3) Python"
    echo "q) Quit"
    read -p "Select an option (1-3, q): " TECH_OPT

    case $TECH_OPT in
        1) setup_flutter ;;
        2) setup_react_native ;;
        3) setup_python ;;
        q|Q) echo "Exiting DevForge. Happy coding!"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Try again.${NC}" ;;
    esac
done
