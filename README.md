# Dummy Frontend

A Next.js application with authentication and email functionality, built with TypeScript and Tailwind CSS.

## Architecture

```
Frontend (Next.js 15 + React 19)
    ↓ (HTTP API calls)
Backend API (Express - Port 3005)
    ↓ (Proxies email requests)
Communication Service (Port 4000)
    ↓
AWS SES (Email delivery)
```

## Project Structure

```
frontend/
├── app/                    # Next.js App Router pages
│   ├── dashboard/         # Dashboard page (protected route)
│   │   └── page.tsx
│   ├── login/            # Login page
│   │   └── page.tsx
│   ├── layout.tsx        # Root layout
│   ├── page.tsx          # Home page
│   └── globals.css       # Global styles
├── lib/                  # Utility functions
│   ├── api.ts           # API client functions
│   └── auth.ts          # Authentication utilities
├── types/               # TypeScript type definitions
│   └── user.ts
├── middleware.ts        # Next.js middleware for route protection
├── Dockerfile           # Docker production build
├── next.config.ts       # Next.js configuration
└── .env.local          # Environment variables
```

## Features

- ✅ User authentication with JWT
- ✅ Protected routes with middleware
- ✅ Dashboard with user information
- ✅ Email sending functionality (via backend proxy)
- ✅ Reusable UI components
- ✅ Type-safe API calls
- ✅ Tailwind CSS v4 styling
- ✅ Docker support for production deployment

## Getting Started

### Prerequisites

- Node.js 18+ installed
- Backend API running at `http://localhost:3005`

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:

Create `.env.local` file:
```bash
NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1
```

3. Start the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

## Docker Deployment

### Build and Run with Docker

```bash
# Build the Docker image
docker build -t dummy-frontend \
  --build-arg NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1 \
  .

# Run the container
docker run -p 3000:3000 dummy-frontend
```

### Environment Variables for Docker Build

```bash
# For local development
docker build -t dummy-frontend \
  --build-arg NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1 \
  .

# For production
docker build -t dummy-frontend \
  --build-arg NEXT_PUBLIC_API_URL=https://api.yourdomain.com/api/v1 \
  .
```

### Docker Compose (with Backend)

If running the entire stack with docker-compose:

```yaml
# Example docker-compose.yml (add to backend repo)
version: '3.8'
services:
  frontend:
    build:
      context: ../dummy-frontend
      dockerfile: Dockerfile
      args:
        NEXT_PUBLIC_API_URL: http://localhost:3005/api/v1
    ports:
      - "3000:3000"
    networks:
      - dummy-network
    depends_on:
      - main-backend
```

## Available Routes

### Public Routes
- `/` - Home page (shows login prompt if not authenticated)
- `/login` - Login page

### Protected Routes
- `/dashboard` - User dashboard (requires authentication)

## API Integration

The application connects to the backend API. Key endpoints used:

### Authentication
- `POST /user/login` - User authentication
  ```typescript
  Request: { email: string, password: string }
  Response: { token: string, user: { id, email, name } }
  ```

### User Management
- `GET /user/:id` - Get user details (requires JWT)
  ```typescript
  Headers: { Authorization: 'Bearer <token>' }
  Response: { id, email, name, createdAt }
  ```

### Email (Future)
- `POST /email/send-custom` - Send custom email (via backend proxy)

## Environment Variables

### Development (`.env.local`)
```bash
# Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1
```

### Production
```bash
# Production backend URL
NEXT_PUBLIC_API_URL=https://api.yourdomain.com/api/v1
```

**Note:** All variables prefixed with `NEXT_PUBLIC_` are exposed to the browser.

## Utilities

### API Client (`lib/api.ts`)
Centralized API calls for authentication and user management:
- `loginUser(email, password)` - Authenticate user
- `getUserById(id, token)` - Fetch user details

### Auth Utilities (`lib/auth.ts`)
Helper functions for managing authentication:
- `saveToken(token)` - Save JWT to localStorage
- `getToken()` - Retrieve JWT from localStorage
- `removeToken()` - Clear JWT from localStorage
- `saveUser(user)` - Save user data to localStorage
- `getUser()` - Retrieve user data
- `removeUser()` - Clear user data
- `isAuthenticated()` - Check if user is logged in

## Route Protection

The `middleware.ts` file protects routes that require authentication:

**Protected Routes:**
- `/dashboard/*` - Requires valid JWT token

**Authenticated Users Redirected Away From:**
- `/login` - Redirected to dashboard if already logged in

## Development

```bash
# Run development server (with hot reload)
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linting
npm run lint
```

## Production Build

### Standalone Output Mode

The application uses Next.js standalone output mode for optimized Docker builds:

```typescript
// next.config.ts
export default {
  output: 'standalone'  // Creates minimal production build
}
```

This creates a self-contained production build in `.next/standalone/` with:
- Only necessary dependencies
- Minimal file size
- Faster cold starts

### Build Process

```bash
# Local production build
npm run build
npm start

# Docker production build
docker build -t dummy-frontend .
docker run -p 3000:3000 dummy-frontend
```

## Connecting to Backend

### CORS Configuration

Ensure backend allows requests from frontend origin:

```javascript
// Backend: main-backend/src/index.js
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
```

### Backend Environment Variable

Add to backend `.env`:
```bash
FRONTEND_URL=http://localhost:3000
```

For production:
```bash
FRONTEND_URL=https://yourdomain.com
```

## Troubleshooting

### API Connection Failed

```bash
# Check if backend is running
curl http://localhost:3005/health

# Verify NEXT_PUBLIC_API_URL in .env.local
echo $NEXT_PUBLIC_API_URL

# Check browser console for errors
# Open DevTools → Console
```

### Authentication Not Working

```bash
# Clear localStorage
# Browser DevTools → Application → Local Storage → Clear All

# Check token in localStorage
localStorage.getItem('token')

# Verify JWT is valid
# Use jwt.io to decode token
```

### Docker Build Fails

```bash
# Check Node version
node -v  # Should be 18+

# Clear Next.js cache
rm -rf .next

# Rebuild
npm run build

# Check Dockerfile
docker build --no-cache -t dummy-frontend .
```

### Port 3000 Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or use different port
PORT=3001 npm run dev
```

## Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage
```

## Code Style

```bash
# Run ESLint
npm run lint

# Auto-fix linting issues
npm run lint -- --fix
```

## Production Deployment

### Environment Variables
- Set `NODE_ENV=production` (automatic with `npm run build`)
- Use production backend URL in `NEXT_PUBLIC_API_URL`
- Enable SSL/TLS for HTTPS

### Deployment Platforms

**Vercel (Recommended for Next.js):**
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variable
vercel env add NEXT_PUBLIC_API_URL
```

**Docker Deployment:**
```bash
# Build production image
docker build -t dummy-frontend \
  --build-arg NEXT_PUBLIC_API_URL=https://api.yourdomain.com/api/v1 \
  .

# Run on server
docker run -d -p 3000:3000 --name frontend dummy-frontend

# With restart policy
docker run -d -p 3000:3000 --restart unless-stopped dummy-frontend
```

**Kubernetes:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: frontend
        image: dummy-frontend:latest
        ports:
        - containerPort: 3000
        env:
        - name: NEXT_PUBLIC_API_URL
          value: "https://api.yourdomain.com/api/v1"
```

### Best Practices
- Use environment variables for all configuration
- Enable HTTPS in production
- Set up CDN for static assets
- Implement proper error boundaries
- Add monitoring and analytics
- Set up CI/CD pipeline
- Use image optimization
- Implement caching strategies

## Tech Stack

- **Framework:** Next.js 15 (App Router)
- **React:** 19.1.0
- **Language:** TypeScript 5
- **Styling:** Tailwind CSS v4
- **Authentication:** JWT
- **HTTP Client:** Fetch API
- **Build:** Docker multi-stage build
- **Deployment:** Vercel / Docker / Kubernetes

## Performance Optimization

- Server-side rendering (SSR) for initial page load
- Automatic code splitting
- Image optimization with Next.js Image component
- Standalone output mode for minimal Docker images
- Static generation for public pages

## Security

- JWT token stored in localStorage (consider httpOnly cookies for enhanced security)
- CORS configuration on backend
- Protected routes via middleware
- Input validation on forms
- HTTPS in production

## Related Repositories

- **Backend Repository:** `dummy-backend` (separate monorepo)
  - Main Backend API (Port 3005)
  - Communication Backend (Port 4000)
  - MongoDB Database

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## License

ISC

## Support

For issues and questions, please open an issue in the repository.
