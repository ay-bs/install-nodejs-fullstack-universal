#!/bin/bash

# Node.js Fullstack Universal Installer for Linux
# Supports Ubuntu/Debian, CentOS/RHEL/Fedora
# Usage: ./install-linux.sh [--skip-vscode] [--skip-git] [--node-version=18]

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

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
else
    print_error "Cannot detect Linux distribution"
    exit 1
fi

print_info "Detected: $PRETTY_NAME"

# Function to install packages based on distribution
install_package() {
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y "$@"
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "$@"
            else
                sudo yum install -y "$@"
            fi
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Install essential build tools
print_info "Installing essential build tools..."
case $DISTRO in
    ubuntu|debian)
        sudo apt-get update
        install_package curl wget gnupg2 software-properties-common apt-transport-https ca-certificates build-essential
        ;;
    centos|rhel|fedora)
        install_package curl wget gnupg2 gcc gcc-c++ make
        ;;
esac
print_success "Essential build tools installed"

# Install Git (if not skipped)
if [[ "$SKIP_GIT" != true ]]; then
    if ! command -v git &> /dev/null; then
        print_info "Installing Git..."
        install_package git
        print_success "Git installed successfully"
    else
        print_success "Git is already installed"
    fi
fi

# Install Node.js using NodeSource repository
print_info "Installing Node.js..."

# Remove existing Node.js installations
case $DISTRO in
    ubuntu|debian)
        sudo apt-get remove -y nodejs npm &> /dev/null || true
        ;;
    centos|rhel|fedora)
        sudo dnf remove -y nodejs npm &> /dev/null || true
        sudo yum remove -y nodejs npm &> /dev/null || true
        ;;
esac

# Install Node Version Manager (nvm)
if [ ! -d "$HOME/.nvm" ]; then
    print_info "Installing Node Version Manager (nvm)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    print_success "nvm installed successfully"
else
    print_success "nvm is already installed"
fi

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js with nvm
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

# Configure npm for better performance
npm config set fund false
npm config set audit-level moderate

# Install Yarn
if ! command -v yarn &> /dev/null; then
    print_info "Installing Yarn..."
    
    case $DISTRO in
        ubuntu|debian)
            curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
            echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt-get update
            sudo apt-get install -y yarn
            ;;
        centos|rhel|fedora)
            curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
            install_package yarn
            ;;
    esac
    
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
    "http-server"
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
        
        case $DISTRO in
            ubuntu|debian)
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
                sudo apt-get update
                sudo apt-get install -y code
                ;;
            centos|rhel|fedora)
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo
                if command -v dnf &> /dev/null; then
                    sudo dnf check-update
                    sudo dnf install -y code
                else
                    sudo yum check-update
                    sudo yum install -y code
                fi
                ;;
        esac
        
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
            "ms-vscode.vscode-docker"
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
case $DISTRO in
    ubuntu|debian)
        install_package tree htop neofetch jq
        ;;
    centos|rhel|fedora)
        install_package tree htop neofetch jq
        ;;
esac

# Install Docker (optional)
read -p "Would you like to install Docker? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing Docker..."
    
    case $DISTRO in
        ubuntu|debian)
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        centos|rhel|fedora)
            sudo dnf config-manager --add-repo https://download.docker.com/linux/$DISTRO/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
    esac
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    
    print_success "Docker installed successfully"
    print_warning "Please log out and log back in for Docker group membership to take effect"
fi

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
if [[ -f "$HOME/.bashrc" ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ -f "$HOME/.profile" ]]; then
    SHELL_PROFILE="$HOME/.profile"
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
    
    # Add yarn global bin to PATH if not present
    if ! grep -q "yarn global bin" "$SHELL_PROFILE"; then
        echo 'export PATH="$(yarn global bin):$PATH"' >> "$SHELL_PROFILE"
        print_success "Yarn global bin added to PATH"
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
if command -v yarn &> /dev/null; then
    print_info "• Yarn: $(yarn --version)"
fi
print_info "• pnpm: $(pnpm --version)"
if [[ "$SKIP_GIT" != true ]] && command -v git &> /dev/null; then
    print_info "• Git: $(git --version | cut -d' ' -f3)"
fi
if [[ "$SKIP_VSCODE" != true ]] && command -v code &> /dev/null; then
    print_info "• VS Code: Installed"
fi
if command -v docker &> /dev/null; then
    print_info "• Docker: $(docker --version | cut -d' ' -f3 | sed 's/,//')"
fi
echo ""
print_info "Next steps:"
print_info "1. Restart your terminal or run: source ~/.bashrc"
print_info "2. Create a new React project: npx create-react-app my-app"
print_info "3. Or start with Express: npm init -y && npm install express"
print_info "4. Use nvm to switch Node versions: nvm use 18"
if command -v docker &> /dev/null; then
    print_info "5. Log out and log back in for Docker group membership"
fi
echo ""
print_success "Happy coding! 🚀"
