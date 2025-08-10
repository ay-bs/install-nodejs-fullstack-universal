# Install Node.js Fullstack Universal

A comprehensive guide and toolkit for installing and setting up Node.js for full-stack development across different platforms and environments.

## Overview

This repository provides universal installation scripts, guides, and best practices for setting up Node.js development environments for full-stack applications. Whether you're working on Windows, macOS, or Linux, this toolkit will help you get up and running quickly.

## Features

- 🚀 Cross-platform Node.js installation scripts
- 📦 Package manager setup (npm, yarn, pnpm)
- 🔧 Development environment configuration
- 🌐 Frontend and backend tooling setup
- 🐳 Docker containerization support
- 📚 Best practices and troubleshooting guides

## Quick Start

### Prerequisites

- Administrative/sudo access on your system
- Internet connection for downloading packages

### Installation

```bash
# Clone this repository
git clone https://github.com/ay-bs/install-nodejs-fullstack-universal.git
cd install-nodejs-fullstack-universal

# Make scripts executable (Linux/macOS)
chmod +x scripts/*.sh

# Run the installation script for your platform
# Windows (PowerShell as Administrator)
.\scripts\install-windows.ps1

# macOS
./scripts/install-macos.sh

# Linux (Ubuntu/Debian)
./scripts/install-linux.sh
```

## What Gets Installed

- **Node.js** (LTS version)
- **npm** (Node Package Manager)
- **Yarn** (Alternative package manager)
- **pnpm** (Fast, disk space efficient package manager)
- **Git** (Version control)
- **VS Code** (Optional - popular editor)
- **Common development tools and utilities**

## Supported Platforms

- ✅ Windows 10/11
- ✅ macOS (Intel & Apple Silicon)
- ✅ Ubuntu/Debian Linux
- ✅ CentOS/RHEL/Fedora
- ✅ Docker containers

## Directory Structure

```
install-nodejs-fullstack-universal/
├── scripts/                 # Installation scripts
│   ├── install-windows.ps1  # Windows PowerShell script
│   ├── install-macos.sh     # macOS installation script
│   ├── install-linux.sh     # Linux installation script
│   └── common/              # Shared utilities
├── configs/                 # Configuration files
│   ├── .npmrc              # npm configuration
│   ├── .yarnrc             # Yarn configuration
│   └── vscode/             # VS Code settings
├── docker/                 # Docker configurations
│   ├── Dockerfile          # Node.js development image
│   └── docker-compose.yml  # Full-stack development stack
├── docs/                   # Documentation
│   ├── troubleshooting.md  # Common issues and solutions
│   ├── best-practices.md   # Development best practices
│   └── advanced-setup.md   # Advanced configuration options
└── README.md               # This file
```

## Usage Examples

### Frontend Development
```bash
# React application
npx create-react-app my-app
cd my-app
npm start

# Vue.js application
npm create vue@latest my-vue-app
cd my-vue-app
npm install
npm run dev

# Angular application
npm install -g @angular/cli
ng new my-angular-app
cd my-angular-app
ng serve
```

### Backend Development
```bash
# Express.js API
mkdir my-api && cd my-api
npm init -y
npm install express
echo "console.log('Server running on port 3000')" > app.js

# NestJS application
npm i -g @nestjs/cli
nest new my-nest-app
```

### Full-Stack Setup
```bash
# Using the provided Docker configuration
docker-compose up -d
```

## Configuration

### Environment Variables
Create a `.env` file in your project root:
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=your_database_url
API_KEY=your_api_key
```

### Package Manager Configuration
The installation includes optimized configurations for:
- npm (faster installs, security settings)
- Yarn (workspace support, zero-installs)
- pnpm (space-efficient, fast)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

**Permission Errors (Windows)**
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Node Version Issues**
```bash
# Use Node Version Manager
# Windows
nvm install --lts
nvm use --lts

# macOS/Linux
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm use --lts
```

**Package Installation Failures**
```bash
# Clear npm cache
npm cache clean --force

# Reset node_modules
rm -rf node_modules package-lock.json
npm install
```

## Resources

- [Node.js Official Documentation](https://nodejs.org/docs/)
- [npm Documentation](https://docs.npmjs.com/)
- [Yarn Documentation](https://yarnpkg.com/getting-started)
- [pnpm Documentation](https://pnpm.io/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions:

1. Check the [troubleshooting guide](docs/troubleshooting.md)
2. Search existing [issues](https://github.com/ay-bs/install-nodejs-fullstack-universal/issues)
3. Create a new issue with detailed information
4. Join our community discussions

---

**Happy coding! 🚀**

Made with ❤️ for the Node.js community
