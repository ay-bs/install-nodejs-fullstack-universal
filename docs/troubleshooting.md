# Troubleshooting Guide

This guide covers common issues and solutions when using the Node.js Fullstack Universal installer.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Node.js Issues](#nodejs-issues)
- [Package Manager Issues](#package-manager-issues)
- [VS Code Issues](#vs-code-issues)
- [Docker Issues](#docker-issues)
- [Platform-Specific Issues](#platform-specific-issues)

## Installation Issues

### Permission Denied Errors

**Windows:**
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**macOS/Linux:**
```bash
# Use sudo for system-wide installations
sudo ./install-macos.sh
# Or install to user directory
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### Network Connection Issues

**Problem:** Installation fails due to network timeouts or SSL errors.

**Solution:**
```bash
# Check internet connection
ping google.com

# Clear npm cache
npm cache clean --force

# Configure npm for corporate networks
npm config set registry https://registry.npmjs.org/
npm config set strict-ssl false  # Only for corporate environments
```

### Disk Space Issues

**Problem:** Installation fails due to insufficient disk space.

**Solution:**
```bash
# Check available disk space
df -h  # Linux/macOS
Get-PSDrive C  # Windows PowerShell

# Clean up existing installations
rm -rf node_modules
npm cache clean --force
yarn cache clean
```

## Node.js Issues

### Node Version Conflicts

**Problem:** Multiple Node.js versions causing conflicts.

**Solution using NVM:**
```bash
# List installed versions
nvm list

# Install and use specific version
nvm install 18.17.0
nvm use 18.17.0
nvm alias default 18.17.0

# Uninstall unwanted versions
nvm uninstall 16.14.0
```

### Global Package Permission Issues

**Problem:** Cannot install global packages due to permission errors.

**Solution:**
```bash
# Configure npm to use a different directory
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'

# Add to your shell profile
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Node.js Not Found After Installation

**Problem:** Command `node` not found after installation.

**Solution:**
```bash
# Reload shell environment
source ~/.bashrc  # Linux
source ~/.zshrc   # macOS with zsh

# Or restart terminal

# Check PATH
echo $PATH

# Find Node.js installation
which node
whereis node
```

## Package Manager Issues

### npm Issues

**Problem:** npm install fails with various errors.

**Solutions:**
```bash
# Clear cache and reinstall
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Fix audit issues
npm audit fix --force

# Rebuild native modules
npm rebuild

# Update npm
npm install -g npm@latest
```

### Yarn Issues

**Problem:** Yarn commands fail or behave unexpectedly.

**Solutions:**
```bash
# Clear Yarn cache
yarn cache clean

# Remove lockfile and reinstall
rm yarn.lock
yarn install

# Update Yarn
npm install -g yarn@latest

# Check Yarn version
yarn --version
```

### pnpm Issues

**Problem:** pnpm installation or usage issues.

**Solutions:**
```bash
# Clear pnpm cache
pnpm store prune

# Update pnpm
npm install -g pnpm@latest

# Check pnpm version
pnpm --version

# Install with legacy peer deps
pnpm install --legacy-peer-deps
```

## VS Code Issues

### Extensions Not Installing

**Problem:** VS Code extensions fail to install.

**Solutions:**
```bash
# Install extensions manually
code --install-extension ms-vscode.vscode-typescript-next

# Clear extension cache (Windows)
rm -rf "%USERPROFILE%\.vscode\extensions"

# Clear extension cache (macOS/Linux)
rm -rf ~/.vscode/extensions

# Reinstall VS Code
```

### TypeScript Issues in VS Code

**Problem:** TypeScript errors or IntelliSense not working.

**Solutions:**
1. Restart TypeScript server: `Ctrl+Shift+P` → "TypeScript: Restart TS Server"
2. Check TypeScript version: `Ctrl+Shift+P` → "TypeScript: Select TypeScript Version"
3. Ensure workspace has `tsconfig.json`
4. Install workspace TypeScript: `npm install -D typescript`

### Settings Not Applied

**Problem:** VS Code settings from the installer not applied.

**Solutions:**
```bash
# Copy settings manually
cp configs/vscode/settings.json ~/.vscode/settings.json  # macOS/Linux
copy configs\vscode\settings.json %APPDATA%\Code\User\settings.json  # Windows

# Reset VS Code settings
rm ~/.vscode/settings.json  # Then restart VS Code
```

## Docker Issues

### Docker Not Starting

**Problem:** Docker containers fail to start.

**Solutions:**
```bash
# Check Docker status
docker --version
docker info

# Start Docker daemon (Linux)
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Then logout and login again

# Restart Docker Desktop (Windows/macOS)
```

### Container Build Failures

**Problem:** Docker images fail to build.

**Solutions:**
```bash
# Clean Docker cache
docker system prune -a

# Build with no cache
docker-compose build --no-cache

# Check Docker logs
docker-compose logs nodejs-dev

# Fix permission issues (Linux)
sudo chown -R $USER:$USER .
```

### Port Already in Use

**Problem:** Docker fails to start due to port conflicts.

**Solutions:**
```bash
# Check what's using the port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill process using the port
kill -9 <PID>  # macOS/Linux
taskkill /F /PID <PID>  # Windows

# Use different ports in docker-compose.yml
ports:
  - "3001:3000"  # Map to different host port
```

## Platform-Specific Issues

### Windows Issues

**PowerShell Execution Policy:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

**Long Path Issues:**
```powershell
# Enable long paths in Windows
git config --system core.longpaths true
```

**Windows Defender Issues:**
```powershell
# Exclude Node.js directories from Windows Defender
Add-MpPreference -ExclusionPath "C:\Users\<username>\AppData\Roaming\npm"
Add-MpPreference -ExclusionPath "C:\Program Files\nodejs"
```

### macOS Issues

**Xcode Command Line Tools:**
```bash
# Install if missing
xcode-select --install
```

**Homebrew Issues:**
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/lib/pkgconfig
brew doctor
```

**Apple Silicon (M1/M2) Issues:**
```bash
# Install Rosetta 2 if needed
softwareupdate --install-rosetta

# Use x86 version of Node.js if needed
arch -x86_64 npm install
```

### Linux Issues

**Missing Build Tools:**
```bash
# Ubuntu/Debian
sudo apt-get install build-essential python3-dev

# CentOS/RHEL/Fedora
sudo yum groupinstall "Development Tools"
# or
sudo dnf groupinstall "Development Tools"
```

**Node.js Version Issues:**
```bash
# Remove system Node.js
sudo apt-get remove nodejs npm  # Ubuntu/Debian
sudo yum remove nodejs npm      # CentOS/RHEL

# Use NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## Environment Variables

### PATH Issues

**Problem:** Installed tools not found in PATH.

**Solutions:**
```bash
# Check current PATH
echo $PATH

# Add Node.js to PATH (if installed manually)
export PATH="/usr/local/bin:$PATH"

# Make permanent by adding to shell profile
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### NODE_ENV Issues

**Problem:** Applications behaving incorrectly due to wrong NODE_ENV.

**Solutions:**
```bash
# Check current NODE_ENV
echo $NODE_ENV

# Set NODE_ENV for development
export NODE_ENV=development

# Set NODE_ENV for production
export NODE_ENV=production

# Make permanent
echo 'export NODE_ENV=development' >> ~/.bashrc
```

## Getting Help

If you're still experiencing issues:

1. **Check the logs:** Most tools provide verbose logging options
   ```bash
   npm install --verbose
   yarn install --verbose
   docker-compose logs
   ```

2. **Update everything:** Ensure you're using the latest versions
   ```bash
   npm update -g
   yarn global upgrade
   ```

3. **Search existing issues:** Check the repository's GitHub issues

4. **Create a new issue:** Include:
   - Operating system and version
   - Node.js version (`node --version`)
   - npm version (`npm --version`)
   - Complete error message
   - Steps to reproduce

5. **Community resources:**
   - [Node.js Discord](https://discord.gg/nodejs)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/node.js)
   - [Reddit r/node](https://reddit.com/r/node)

## Useful Commands

### Diagnostic Commands
```bash
# System information
node --version
npm --version
yarn --version
git --version
docker --version

# npm configuration
npm config list
npm config get registry

# Check global packages
npm list -g --depth=0

# Network diagnostics
npm config get proxy
npm config get https-proxy
curl -I https://registry.npmjs.org/

# Docker diagnostics
docker info
docker-compose config
```

### Reset Commands
```bash
# Reset npm
npm cache clean --force
rm -rf ~/.npm

# Reset Yarn
yarn cache clean
rm -rf ~/.cache/yarn

# Reset Docker
docker system prune -a
docker volume prune

# Reset VS Code
rm -rf ~/.vscode/extensions
```

Remember to restart your terminal or IDE after making configuration changes!
