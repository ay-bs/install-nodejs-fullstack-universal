# Node.js Fullstack Universal Installer for Windows
# Requires PowerShell running as Administrator

param(
    [switch]$SkipVSCode,
    [switch]$SkipGit,
    [string]$NodeVersion = "lts"
)

# Color functions
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    } else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Info { Write-ColorOutput Cyan $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires Administrator privileges. Please run PowerShell as Administrator and try again."
    exit 1
}

Write-Info "====================================="
Write-Info "Node.js Fullstack Universal Installer"
Write-Info "====================================="
Write-Info ""

# Enable execution policy for current user
Write-Info "Setting execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Chocolatey package manager..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    refreshenv
    Write-Success "✓ Chocolatey installed successfully"
} else {
    Write-Success "✓ Chocolatey is already installed"
}

# Install Git (if not skipped)
if (!$SkipGit) {
    Write-Info "Installing Git..."
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        choco install git -y
        refreshenv
        Write-Success "✓ Git installed successfully"
    } else {
        Write-Success "✓ Git is already installed"
    }
}

# Install Node.js using winget
Write-Info "Installing Node.js..."
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    winget install OpenJS.NodeJS
    refreshenv
    Write-Success "✓ Node.js installed successfully"
} else {
    Write-Success "✓ Node.js is already installed"
}

# Verify Node.js installation
Write-Info "Verifying Node.js installation..."
$nodeVersion = node --version
$npmVersion = npm --version
Write-Success "✓ Node.js version: $nodeVersion"
Write-Success "✓ npm version: $npmVersion"

# Install Yarn
Write-Info "Installing Yarn..."
if (!(Get-Command yarn -ErrorAction SilentlyContinue)) {
    npm install -g yarn
    Write-Success "✓ Yarn installed successfully"
} else {
    Write-Success "✓ Yarn is already installed"
}

# Install pnpm
Write-Info "Installing pnpm..."
if (!(Get-Command pnpm -ErrorAction SilentlyContinue)) {
    npm install -g pnpm
    Write-Success "✓ pnpm installed successfully"
} else {
    Write-Success "✓ pnpm is already installed"
}

# Install global development tools
Write-Info "Installing global development tools..."
$globalPackages = @(
    "@angular/cli",
    "@vue/cli", 
    "create-react-app",
    "@nestjs/cli",
    "typescript",
    "nodemon",
    "pm2",
    "eslint",
    "prettier"
)

foreach ($package in $globalPackages) {
    Write-Info "Installing $package..."
    npm install -g $package
}
Write-Success "✓ Global development tools installed"

# Install VS Code (if not skipped)
if (!$SkipVSCode) {
    Write-Info "Installing Visual Studio Code..."
    if (!(Get-Command code -ErrorAction SilentlyContinue)) {
        winget install Microsoft.VisualStudioCode
        refreshenv
        Write-Success "✓ Visual Studio Code installed successfully"
        
        # Install useful VS Code extensions
        Write-Info "Installing VS Code extensions..."
        $extensions = @(
            "ms-vscode.vscode-typescript-next",
            "esbenp.prettier-vscode",
            "ms-vscode.vscode-eslint",
            "bradlc.vscode-tailwindcss",
            "ms-vscode.vscode-json",
            "formulahendry.auto-rename-tag",
            "christian-kohler.path-intellisense",
            "ms-vscode.vscode-npm-script"
        )
        
        foreach ($ext in $extensions) {
            code --install-extension $ext
        }
        Write-Success "✓ VS Code extensions installed"
    } else {
        Write-Success "✓ Visual Studio Code is already installed"
    }
}

# Create project structure
Write-Info "Setting up configuration files..."

# Copy npm configuration
if (Test-Path "../configs/.npmrc") {
    Copy-Item "../configs/.npmrc" "$env:USERPROFILE\.npmrc"
    Write-Success "✓ npm configuration applied"
}

# Copy yarn configuration  
if (Test-Path "../configs/.yarnrc") {
    Copy-Item "../configs/.yarnrc" "$env:USERPROFILE\.yarnrc"
    Write-Success "✓ Yarn configuration applied"
}

Write-Info ""
Write-Success "====================================="
Write-Success "Installation completed successfully! 🎉"
Write-Success "====================================="
Write-Info ""
Write-Info "Installed components:"
Write-Info "• Node.js: $(node --version)"
Write-Info "• npm: $(npm --version)"
Write-Info "• Yarn: $(yarn --version)"
Write-Info "• pnpm: $(pnpm --version)"
if (!$SkipGit -and (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Info "• Git: $(git --version)"
}
if (!$SkipVSCode -and (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Info "• VS Code: Installed"
}
Write-Info ""
Write-Info "Next steps:"
Write-Info "1. Restart your terminal to refresh environment variables"
Write-Info "2. Create a new project: npx create-react-app my-app"
Write-Info "3. Or start with Express: npm init -y && npm install express"
Write-Info ""
Write-Success "Happy coding! 🚀"
