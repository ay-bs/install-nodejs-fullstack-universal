# Node.js Fullstack Development Best Practices

This guide outlines best practices for Node.js fullstack development using the tools and configurations provided in this repository.

## Table of Contents

- [Project Structure](#project-structure)
- [Package Management](#package-management)
- [Development Workflow](#development-workflow)
- [Code Quality](#code-quality)
- [Security](#security)
- [Performance](#performance)
- [Testing](#testing)
- [Deployment](#deployment)

## Project Structure

### Recommended Directory Layout

```
my-fullstack-app/
├── packages/                 # Monorepo packages (if applicable)
│   ├── frontend/            # React/Vue/Angular app
│   ├── backend/             # Node.js API
│   └── shared/              # Shared utilities
├── apps/                    # Alternative to packages
│   ├── web/                 # Frontend application
│   ├── api/                 # Backend API
│   └── mobile/              # Mobile app (React Native)
├── libs/                    # Shared libraries
│   ├── ui/                  # UI components
│   ├── utils/               # Utility functions
│   └── types/               # TypeScript definitions
├── tools/                   # Build tools and scripts
├── docs/                    # Documentation
├── docker/                  # Docker configurations
├── .github/                 # GitHub workflows
├── package.json            # Root package.json
├── tsconfig.json           # TypeScript configuration
├── .eslintrc.js           # ESLint configuration
├── .prettierrc            # Prettier configuration
└── README.md              # Project documentation
```

### Environment-Based Configuration

```javascript
// config/index.js
const config = {
  development: {
    port: process.env.PORT || 3000,
    database: {
      url: process.env.DATABASE_URL || 'postgresql://localhost/myapp_dev'
    },
    redis: {
      url: process.env.REDIS_URL || 'redis://localhost:6379'
    }
  },
  production: {
    port: process.env.PORT || 80,
    database: {
      url: process.env.DATABASE_URL
    },
    redis: {
      url: process.env.REDIS_URL
    }
  }
};

module.exports = config[process.env.NODE_ENV || 'development'];
```

## Package Management

### Use Package-lock Files

Always commit lock files to ensure consistent installs:
```bash
# npm
git add package-lock.json

# yarn
git add yarn.lock

# pnpm
git add pnpm-lock.yaml
```

### Semantic Versioning

Use exact versions for critical dependencies:
```json
{
  "dependencies": {
    "express": "4.18.2",        // Exact version
    "lodash": "^4.17.21",       // Compatible version
    "react": "~18.2.0"          // Patch updates only
  }
}
```

### Workspace Management

For monorepos, use workspaces:

**package.json (root):**
```json
{
  "name": "my-fullstack-app",
  "workspaces": [
    "packages/*",
    "apps/*"
  ],
  "scripts": {
    "build": "npm run build --workspaces",
    "test": "npm run test --workspaces",
    "dev": "concurrently \"npm run dev -w frontend\" \"npm run dev -w backend\""
  }
}
```

### Dependency Classification

```json
{
  "dependencies": {
    // Production dependencies
    "express": "^4.18.2",
    "react": "^18.2.0"
  },
  "devDependencies": {
    // Development tools
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "nodemon": "^3.0.0"
  },
  "peerDependencies": {
    // Required by consumers
    "react": ">=16.8.0"
  },
  "optionalDependencies": {
    // Optional enhancements
    "sharp": "^0.32.0"
  }
}
```

## Development Workflow

### Git Workflow

Use conventional commits:
```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve memory leak in websocket handler"
git commit -m "docs: update API documentation"
git commit -m "refactor: optimize database queries"
```

### Branch Strategy

```bash
main                    # Production branch
├── develop            # Development branch
├── feature/auth       # Feature branches
├── hotfix/security    # Hotfix branches
└── release/v1.2.0     # Release branches
```

### Environment Variables

Use `.env` files for different environments:

**.env.development:**
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://localhost/myapp_dev
DEBUG=app:*
LOG_LEVEL=debug
```

**.env.production:**
```env
NODE_ENV=production
DATABASE_URL=postgresql://prod-server/myapp
LOG_LEVEL=info
SENTRY_DSN=https://your-sentry-dsn
```

### Scripts Organization

**package.json:**
```json
{
  "scripts": {
    "dev": "nodemon src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "type-check": "tsc --noEmit",
    "pre-commit": "lint-staged"
  }
}
```

## Code Quality

### TypeScript Configuration

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### ESLint Configuration

**.eslintrc.js:**
```javascript
module.exports = {
  extends: [
    '@typescript-eslint/recommended',
    'prettier'
  ],
  plugins: ['@typescript-eslint'],
  rules: {
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-explicit-any': 'warn',
    'prefer-const': 'error',
    'no-var': 'error'
  }
};
```

### Prettier Configuration

**.prettierrc:**
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

### Pre-commit Hooks

**package.json:**
```json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "git add"
    ],
    "*.{json,md}": [
      "prettier --write",
      "git add"
    ]
  }
}
```

## Security

### Environment Variables

Never commit secrets to version control:
```javascript
// ❌ Bad
const apiKey = 'sk-1234567890abcdef';

// ✅ Good
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error('API_KEY environment variable is required');
}
```

### Input Validation

Use validation libraries:
```javascript
const Joi = require('joi');

const userSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  age: Joi.number().integer().min(0).max(120)
});

app.post('/users', (req, res) => {
  const { error, value } = userSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  // Process validated data
});
```

### Security Headers

```javascript
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

app.use(helmet());
app.use(rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
}));
```

### Database Security

```javascript
// Use parameterized queries
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// ❌ Never use string concatenation
const user = await db.query(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

## Performance

### Database Optimization

```javascript
// Use connection pooling
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Use indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_user_id ON posts(user_id);

// Implement pagination
app.get('/posts', async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;
  
  const posts = await db.query(
    'SELECT * FROM posts ORDER BY created_at DESC LIMIT $1 OFFSET $2',
    [limit, offset]
  );
});
```

### Caching

```javascript
const Redis = require('redis');
const client = Redis.createClient(process.env.REDIS_URL);

// Cache function results
const getCachedUser = async (userId) => {
  const cacheKey = `user:${userId}`;
  
  // Try cache first
  const cached = await client.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // Fetch from database
  const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
  
  // Cache for 1 hour
  await client.setEx(cacheKey, 3600, JSON.stringify(user));
  
  return user;
};
```

### Bundle Optimization

**Frontend (Webpack/Vite):**
```javascript
// Code splitting
const LazyComponent = React.lazy(() => import('./LazyComponent'));

// Tree shaking
import { debounce } from 'lodash-es'; // ✅ Import specific function
import _ from 'lodash'; // ❌ Imports entire library
```

## Testing

### Test Structure

```
src/
├── components/
│   ├── Button.tsx
│   └── Button.test.tsx
├── services/
│   ├── userService.ts
│   └── userService.test.ts
└── __tests__/
    ├── integration/
    └── e2e/
```

### Jest Configuration

**jest.config.js:**
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/*.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.test.ts'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

### Test Patterns

```javascript
// Unit test
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      const userData = { email: 'test@example.com', password: 'password123' };
      const user = await userService.createUser(userData);
      
      expect(user).toHaveProperty('id');
      expect(user.email).toBe(userData.email);
    });
    
    it('should throw error for invalid email', async () => {
      const userData = { email: 'invalid-email', password: 'password123' };
      
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Invalid email format');
    });
  });
});

// Integration test
describe('POST /api/users', () => {
  it('should create user and return 201', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', password: 'password123' })
      .expect(201);
      
    expect(response.body).toHaveProperty('user');
    expect(response.body.user.email).toBe('test@example.com');
  });
});
```

## Deployment

### Docker Best Practices

```dockerfile
# Multi-stage build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS runner
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Environment Management

```yaml
# docker-compose.production.yml
version: '3.8'
services:
  app:
    image: my-app:latest
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
```

### Health Checks

```javascript
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// In Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### Monitoring

```javascript
const client = require('prom-client');

// Create metrics
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequestsTotal.inc({
      method: req.method,
      route: req.route?.path || req.path,
      status: res.statusCode
    });
  });
  next();
});
```

## Additional Resources

- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [React Best Practices](https://react.dev/learn/thinking-in-react)
- [Express.js Security](https://expressjs.com/en/advanced/best-practice-security.html)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
