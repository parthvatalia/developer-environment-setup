# DevForge: developer-environment-setup
# One command to build your complete development environment. (Windows version)

$ErrorActionPreference = "Stop"

# --- UI Colors & Formatting ---
function Write-Color {
    param(
        [string]$Message,
        [ConsoleColor]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    Write-Color "╭──────────────────────────────────────────╮" "Cyan"
    Write-Color "│                 DevForge                 │" "Green"
    Write-Color "│   One command to build your workspace    │" "Cyan"
    Write-Color "╰──────────────────────────────────────────╯" "Cyan"
    Write-Host ""
}

# --- Dependency Management ---
function Install-Package {
    param(
        [string]$PackageId
    )
    
    # Check if winget is available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Color "Installing $PackageId via winget..." "Cyan"
        winget install --id $PackageId -e --accept-package-agreements --accept-source-agreements
    } 
    # Fallback to chocolatey if available
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Color "Installing $PackageId via Chocolatey..." "Cyan"
        choco install $PackageId -y
    }
    else {
        Write-Color "Package manager (winget/choco) not found. Cannot install $PackageId automatically." "Red"
    }
}

function Setup-PackageManager {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue) -and -not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Color "No package manager found. Installing winget is recommended on Windows 10/11." "Yellow"
        Write-Host "Please install App Installer from the Microsoft Store to get winget."
    } else {
        Write-Color "✅ Package manager detected." "Green"
    }
}

function Add-ToPath {
    param([string]$NewPath)
    $UserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    if ($UserPath -notmatch [regex]::Escape($NewPath)) {
        [Environment]::SetEnvironmentVariable("Path", $UserPath + ";$NewPath", [EnvironmentVariableTarget]::User)
        Write-Color "✅ Added $NewPath to User PATH." "Green"
    }
}

# --- Technology Profiles ---

function Setup-Flutter {
    Write-Color "`n╭── Flutter Setup ──╮" "Cyan"
    Write-Host "  [1] 📦 Full Setup (SDK, Android Studio, VS Code)"
    Write-Host "  [2] 🛠️  Only SDK"
    Write-Host "  [3] 💻 Only IDEs (Android Studio & VS Code)`n"
    
    $FlutterOpt = Read-Host "Select option (1-3)"

    if ($FlutterOpt -eq "1" -or $FlutterOpt -eq "2") {
        Write-Color "Installing Flutter SDK..." "Cyan"
        Install-Package "Google.Flutter"
    }

    if ($FlutterOpt -eq "1" -or $FlutterOpt -eq "3") {
        Write-Color "Installing IDEs and toolchains..." "Cyan"
        Install-Package "Microsoft.VisualStudioCode"
        Install-Package "Google.AndroidStudio"
        
        Write-Color "Setting up Android SDK paths..." "Cyan"
        $LocalAppData = [Environment]::GetFolderPath("LocalApplicationData")
        Add-ToPath "$LocalAppData\Android\Sdk\platform-tools"
        Add-ToPath "$LocalAppData\Android\Sdk\cmdline-tools\latest\bin"
        Add-ToPath "$LocalAppData\Android\Sdk\emulator"
    }
    
    Write-Color "`nFlutter setup complete! Note: You may need to restart your terminal to run 'flutter doctor' or load new PATH variables." "Green"
}

function Setup-ReactNative {
    Write-Color "`n╭── React Native Setup ──╮" "Cyan"
    Write-Host "  [1] 📦 Full Setup (Node, JDK, Android Studio, VS Code)"
    Write-Host "  [2] 🛠️  Only SDKs (Node, JDK)`n"
    
    $RnOpt = Read-Host "Select option (1-2)"

    if ($RnOpt -eq "1" -or $RnOpt -eq "2") {
        Write-Color "Installing core React Native dependencies..." "Cyan"
        Install-Package "OpenJS.NodeJS"
        Install-Package "Microsoft.OpenJDK.17"
    }

    if ($RnOpt -eq "1") {
        Write-Color "Installing Mobile Toolchains..." "Cyan"
        Install-Package "Google.AndroidStudio"
        Install-Package "Microsoft.VisualStudioCode"
        
        Write-Color "Setting up Android SDK paths..." "Cyan"
        $LocalAppData = [Environment]::GetFolderPath("LocalApplicationData")
        Add-ToPath "$LocalAppData\Android\Sdk\platform-tools"
        Add-ToPath "$LocalAppData\Android\Sdk\cmdline-tools\latest\bin"
        Add-ToPath "$LocalAppData\Android\Sdk\emulator"
    }
    
    Write-Color "`nReact Native setup complete! Note: You may need to restart your terminal. (Use npx react-native init to start)" "Green"
}

function Setup-Python {
    Write-Color "`n╭── Python Setup ──╮" "Cyan"
    Write-Host "  [1] 📦 Full Setup (Python, VS Code)"
    Write-Host "  [2] 🛠️  Only SDK (Python)`n"
    
    $PyOpt = Read-Host "Select option (1-2)"

    if ($PyOpt -eq "1" -or $PyOpt -eq "2") {
        Write-Color "Installing Python..." "Cyan"
        Install-Package "Python.Python.3.11"
    }

    if ($PyOpt -eq "1") {
        Write-Color "Installing IDEs..." "Cyan"
        Install-Package "Microsoft.VisualStudioCode"
    }
    
    Write-Color "`nPython setup complete!" "Green"
}

# --- Main Menu ---
Write-Header
Setup-PackageManager

while ($true) {
    Write-Color "`nWhat technology would you like to set up?" "Cyan"
    Write-Host "  [1] 🔵 Flutter"
    Write-Host "  [2] ⚛️  React Native"
    Write-Host "  [3] 🐍 Python"
    Write-Host "  [q] ❌ Quit`n"
    
    $TechOpt = Read-Host "Select an option (1-3, q)"

    switch ($TechOpt) {
        "1" { Setup-Flutter }
        "2" { Setup-ReactNative }
        "3" { Setup-Python }
        "q" { Write-Host "Exiting DevForge. Happy coding!"; exit }
        "Q" { Write-Host "Exiting DevForge. Happy coding!"; exit }
        default { Write-Color "Invalid option. Try again." "Red" }
    }
}
