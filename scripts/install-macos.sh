#!/bin/bash

# Node.js Fullstack Universal Installer for macOS
# Usage: ./install-macos.sh [--skip-vscode] [--skip-git] [--node-version=18]

set -e

# Color output functions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${CYAN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

# Parse command line arguments
SKIP_VSCODE=false
SKIP_GIT=false
NODE_VERSION="lts"

for arg in "$@"; do
    case $arg in
        --skip-vscode)
            SKIP_VSCODE=true
            shift
            ;;
        --skip-git)
            SKIP_GIT=true
            shift
            ;;
        --node-version=*)
            NODE_VERSION="${arg#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--skip-vscode] [--skip-git] [--node-version=18]"
            exit 1
            ;;
    esac
done

print_info "====================================="
print_info "Node.js Fullstack Universal Installer"
print_info "====================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    print_success "Homebrew installed successfully"
else
    print_success "Homebrew is already installed"
    brew update
fi

# Install Git (if not skipped)
if [[ "$SKIP_GIT" != true ]]; then
    if ! command -v git &> /dev/null; then
        print_info "Installing Git..."
        brew install git
        print_success "Git installed successfully"
    else
        print_success "Git is already installed"
    fi
fi

# Install Node.js using Node Version Manager (nvm)
if ! command -v nvm &> /dev/null; then
    print_info "Installing Node Version Manager (nvm)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    print_success "nvm installed successfully"
fi

# Load nvm in case it's already installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js
print_info "Installing Node.js ($NODE_VERSION)..."
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION

print_success "Node.js installed successfully"

# Verify installation
NODE_VER=$(node --version)
NPM_VER=$(npm --version)
print_success "Node.js version: $NODE_VER"
print_success "npm version: $NPM_VER"

# Install Yarn
if ! command -v yarn &> /dev/null; then
    print_info "Installing Yarn..."
    npm install -g yarn
    print_success "Yarn installed successfully"
else
    print_success "Yarn is already installed"
fi

# Install pnpm
if ! command -v pnpm &> /dev/null; then
    print_info "Installing pnpm..."
    npm install -g pnpm
    print_success "pnpm installed successfully"
else
    print_success "pnpm is already installed"
fi

# Install global development tools
print_info "Installing global development tools..."
GLOBAL_PACKAGES=(
    "@angular/cli"
    "@vue/cli"
    "create-react-app"
    "@nestjs/cli"
    "typescript"
    "nodemon"
    "pm2"
    "eslint"
    "prettier"
    "@storybook/cli"
    "serve"
)

for package in "${GLOBAL_PACKAGES[@]}"; do
    print_info "Installing $package..."
    npm install -g "$package"
done

print_success "Global development tools installed"

# Install VS Code (if not skipped)
if [[ "$SKIP_VSCODE" != true ]]; then
    if ! command -v code &> /dev/null; then
        print_info "Installing Visual Studio Code..."
        brew install --cask visual-studio-code
        print_success "Visual Studio Code installed successfully"
        
        # Install useful VS Code extensions
        print_info "Installing VS Code extensions..."
        EXTENSIONS=(
            "ms-vscode.vscode-typescript-next"
            "esbenp.prettier-vscode"
            "ms-vscode.vscode-eslint"
            "bradlc.vscode-tailwindcss"
            "ms-vscode.vscode-json"
            "formulahendry.auto-rename-tag"
            "christian-kohler.path-intellisense"
            "ms-vscode.vscode-npm-script"
            "ms-vscode.vscode-node-debug2"
            "ms-vscode.vscode-emmet"
        )
        
        for extension in "${EXTENSIONS[@]}"; do
            code --install-extension "$extension"
        done
        
        print_success "VS Code extensions installed"
    else
        print_success "Visual Studio Code is already installed"
    fi
fi

# Install additional development tools
print_info "Installing additional development tools..."
brew install tree wget curl jq

# Setup configuration files
print_info "Setting up configuration files..."

# Copy npm configuration
if [[ -f "../configs/.npmrc" ]]; then
    cp "../configs/.npmrc" "$HOME/.npmrc"
    print_success "npm configuration applied"
fi

# Copy yarn configuration
if [[ -f "../configs/.yarnrc" ]]; then
    cp "../configs/.yarnrc" "$HOME/.yarnrc"
    print_success "Yarn configuration applied"
fi

# Setup shell profile
SHELL_PROFILE=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_PROFILE="$HOME/.bash_profile"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [[ -n "$SHELL_PROFILE" ]]; then
    # Add nvm to shell profile if not already present
    if ! grep -q "NVM_DIR" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Node Version Manager" >> "$SHELL_PROFILE"
        echo 'export NVM_DIR="$HOME/.nvm"' >> "$SHELL_PROFILE"
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$SHELL_PROFILE"
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$SHELL_PROFILE"
        print_success "nvm added to shell profile"
    fi
fi

echo ""
print_success "====================================="
print_success "Installation completed successfully! 🎉"
print_success "====================================="
echo ""
print_info "Installed components:"
print_info "• Node.js: $(node --version)"
print_info "• npm: $(npm --version)"
print_info "• Yarn: $(yarn --version 2>/dev/null || echo 'Not available')"
print_info "• pnpm: $(pnpm --version)"
if [[ "$SKIP_GIT" != true ]] && command -v git &> /dev/null; then
    print_info "• Git: $(git --version | cut -d' ' -f3)"
fi
if [[ "$SKIP_VSCODE" != true ]] && command -v code &> /dev/null; then
    print_info "• VS Code: Installed"
fi
echo ""
print_info "Next steps:"
print_info "1. Restart your terminal or run: source ~/.zshrc"
print_info "2. Create a new React project: npx create-react-app my-app"
print_info "3. Or start with Express: npm init -y && npm install express"
print_info "4. Use nvm to switch Node versions: nvm use 18"
echo ""
print_success "Happy coding! 🚀"
