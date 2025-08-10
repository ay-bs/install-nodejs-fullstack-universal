# Node.js Fullstack Universal Development Environment
# Multi-stage Docker image for Node.js development with all tools

# Base stage with Node.js LTS
FROM node:18-alpine AS base

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    git \
    openssh-client \
    bash \
    curl \
    wget \
    vim \
    nano \
    tree \
    jq \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Install global Node.js tools
RUN npm install -g \
    yarn \
    pnpm \
    @angular/cli \
    @vue/cli \
    create-react-app \
    @nestjs/cli \
    typescript \
    ts-node \
    nodemon \
    pm2 \
    eslint \
    prettier \
    @storybook/cli \
    serve \
    http-server \
    concurrently \
    cross-env \
    rimraf

# Development stage
FROM base AS development

# Install development tools
RUN apk add --no-cache \
    zsh \
    oh-my-zsh \
    git-flow \
    docker-cli \
    docker-compose

# Configure shell
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set default shell to zsh
SHELL ["/bin/zsh", "-c"]

# Copy configuration files
COPY configs/.npmrc /root/.npmrc
COPY configs/.yarnrc /root/.yarnrc

# Create workspace directories
RUN mkdir -p /workspace/frontend /workspace/backend /workspace/fullstack

# Set workspace as working directory
WORKDIR /workspace

# Expose common development ports
EXPOSE 3000 3001 4200 5000 5173 8080 8000 9000

# Default command
CMD ["zsh"]

# Production stage
FROM base AS production

# Set NODE_ENV to production
ENV NODE_ENV=production

# Copy configuration files
COPY configs/.npmrc /root/.npmrc

# Create app directory
RUN mkdir -p /app

# Set app as working directory
WORKDIR /app

# Default command for production
CMD ["node", "index.js"]

# Testing stage
FROM development AS testing

# Install testing tools
RUN npm install -g \
    jest \
    mocha \
    chai \
    supertest \
    cypress \
    @testing-library/react \
    @testing-library/jest-dom \
    playwright

# Create test directory
RUN mkdir -p /tests

WORKDIR /tests

# Default command for testing
CMD ["npm", "test"]

# CI/CD stage
FROM node:18-slim AS ci

# Install system dependencies for CI
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install global tools for CI
RUN npm install -g \
    yarn \
    pnpm \
    typescript \
    eslint \
    prettier \
    jest \
    nyc \
    semantic-release \
    commitizen \
    cz-conventional-changelog

# Set working directory
WORKDIR /workspace

# Default command for CI
CMD ["npm", "ci"]
