# Connecting Frontend to Backend Services

This guide explains how to connect the `dummy-frontend` to the `dummy-backend` microservices.

## Backend Services Overview

The backend is a separate repository (`dummy-backend`) containing:

| Service | Port | Purpose |
|---------|------|---------|
| **Main Backend** | 3005 | User auth, core API |
| **Communication Backend** | 4000 | Email & notifications |
| **MongoDB** | 27017 | Database |

## Setup Steps

### 1. Start Backend Services

First, ensure the backend services are running:

```bash
# In a separate terminal, navigate to backend repo
cd ../dummy-backend

# Start all backend services
docker-compose up -d

# Verify services are running
docker-compose ps
```

You should see:
- `dummy-main-backend` on port 3005
- `dummy-communication-backend` on port 4000
- `dummy-mongodb` on port 27017

### 2. Configure Frontend Environment

Create `.env.local` in the frontend root:

```bash
# Development (local backend)
NEXT_PUBLIC_BACKEND_URL=http://localhost:3005
NEXT_PUBLIC_COMMUNICATION_URL=http://localhost:4000
```

For production:
```bash
# Production (deployed backend)
NEXT_PUBLIC_BACKEND_URL=https://api.yourdomain.com
NEXT_PUBLIC_COMMUNICATION_URL=https://communication.yourdomain.com
```

### 3. Run Frontend

```bash
npm run dev
```

Your frontend will now connect to the backend APIs at `http://localhost:3005` and `http://localhost:4000`.

## API Usage Examples

### Authentication (Main Backend - Port 3005)

```typescript
// Login
const response = await fetch(`${process.env.NEXT_PUBLIC_BACKEND_URL}/api/users/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
});

// Register
const response = await fetch(`${process.env.NEXT_PUBLIC_BACKEND_URL}/api/users/signup`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ username, email, password })
});
```

### Email Service (Communication Backend - Port 4000)

```typescript
// Send welcome email
const response = await fetch(`${process.env.NEXT_PUBLIC_COMMUNICATION_URL}/api/email/send-welcome`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: 'user@example.com',
    username: 'John Doe'
  })
});

// Send password reset email
const response = await fetch(`${process.env.NEXT_PUBLIC_COMMUNICATION_URL}/api/email/send-reset-password`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: 'user@example.com',
    resetLink: 'https://yourapp.com/reset?token=xyz'
  })
});
```

## API Helper (Recommended)

Create `lib/api.ts` for centralized API calls:

```typescript
const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL;
const COMMUNICATION_URL = process.env.NEXT_PUBLIC_COMMUNICATION_URL;

export const api = {
  // Auth endpoints
  login: (email: string, password: string) =>
    fetch(`${BACKEND_URL}/api/users/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    }),

  signup: (username: string, email: string, password: string) =>
    fetch(`${BACKEND_URL}/api/users/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, email, password })
    }),

  // Email endpoints
  sendWelcomeEmail: (to: string, username: string) =>
    fetch(`${COMMUNICATION_URL}/api/email/send-welcome`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ to, username })
    }),

  sendResetEmail: (to: string, resetLink: string) =>
    fetch(`${COMMUNICATION_URL}/api/email/send-reset-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ to, resetLink })
    })
};
```

## Troubleshooting

### CORS Errors

If you see CORS errors in the browser console:

1. Ensure backend is running: `docker-compose ps` in `dummy-backend`
2. Check backend CORS configuration in `main-backend/src/index.js`:

```javascript
app.use(cors({
  origin: 'http://localhost:3000', // Frontend URL
  credentials: true
}));
```

3. Restart backend after changes:
```bash
cd ../dummy-backend
docker-compose restart main-backend
```

### Connection Refused

If you see "Connection refused" errors:

```bash
# Check if backend services are running
cd ../dummy-backend
docker-compose ps

# If not running, start them
docker-compose up -d

# Check logs for errors
docker-compose logs -f
```

### Wrong API URL

Verify environment variables are loaded:

```typescript
console.log('Backend URL:', process.env.NEXT_PUBLIC_BACKEND_URL);
console.log('Communication URL:', process.env.NEXT_PUBLIC_COMMUNICATION_URL);
```

If undefined:
1. Ensure `.env.local` exists
2. Restart Next.js dev server: `npm run dev`
3. Environment variables must start with `NEXT_PUBLIC_` to be accessible in browser

### 404 Errors

If API endpoints return 404:

1. Check backend API routes exist
2. Verify endpoint paths match backend routes
3. Check backend logs: `docker-compose logs -f main-backend`

## Development Workflow

### Typical Development Flow

```bash
# Terminal 1: Start backend
cd ../dummy-backend
docker-compose up

# Terminal 2: Start frontend
cd ../dummy-frontend
npm run dev
```

### Testing API Endpoints

Use curl to test backend directly:

```bash
# Test main backend
curl http://localhost:3005/health

# Test communication backend
curl http://localhost:4000/health

# Test email sending
curl -X POST http://localhost:4000/api/email/send \
  -H "Content-Type: application/json" \
  -d '{"to":"test@example.com","subject":"Test","text":"Hello"}'
```

## Repository Structure

```
/testRepos/
├── dummy-backend/              # Backend monorepo (separate git repo)
│   ├── main-backend/           # Port 3005
│   ├── communication-backend/  # Port 4000
│   └── docker-compose.yml
│
└── dummy-frontend/             # Frontend repo (this repo)
    ├── .env.local              # Local environment config
    └── lib/api.ts              # API helper functions
```

## Environment Variables Summary

### Development (.env.local)
```env
NEXT_PUBLIC_BACKEND_URL=http://localhost:3005
NEXT_PUBLIC_COMMUNICATION_URL=http://localhost:4000
```

### Staging (.env.staging)
```env
NEXT_PUBLIC_BACKEND_URL=https://api-staging.yourdomain.com
NEXT_PUBLIC_COMMUNICATION_URL=https://communication-staging.yourdomain.com
```

### Production (.env.production)
```env
NEXT_PUBLIC_BACKEND_URL=https://api.yourdomain.com
NEXT_PUBLIC_COMMUNICATION_URL=https://communication.yourdomain.com
```

## Additional Resources

- Backend Repository: `dummy-backend`
- Backend README: `../dummy-backend/README.md`
- API Documentation: See backend service READMEs
  - Main Backend: `../dummy-backend/main-backend/README.md`
  - Communication Backend: `../dummy-backend/communication-backend/README.md`

## Quick Reference

| Action | Command |
|--------|---------|
| Start backend | `cd ../dummy-backend && docker-compose up -d` |
| Stop backend | `cd ../dummy-backend && docker-compose down` |
| View backend logs | `cd ../dummy-backend && docker-compose logs -f` |
| Restart service | `cd ../dummy-backend && docker-compose restart main-backend` |
| Check backend health | `curl http://localhost:3005/health` |
| Start frontend | `npm run dev` |
