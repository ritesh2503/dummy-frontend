# Environment Configuration Guide (Frontend)

This document explains how environment variables are managed in this Next.js frontend application.

## Overview

This Next.js project uses **multiple environment files** following Next.js conventions:

```
dummy-frontend/
├── .env.local              ← Your personal local development (gitignored)
├── .env.example            ← Template for all developers (committed)
├── .env.development        ← Shared dev defaults (gitignored)
└── .env.production         ← Production values (NEVER on local machine)
```

## Next.js Environment File Loading Order

Next.js loads environment files in this priority order (highest to lowest):

1. `.env.$(NODE_ENV).local` (e.g., `.env.production.local`, `.env.development.local`)
2. `.env.local` ← **Most commonly used for local dev**
3. `.env.$(NODE_ENV)` (e.g., `.env.production`, `.env.development`)
4. `.env`

**Note:** `.env.local` is always loaded, except when `NODE_ENV=test`

## File Purposes

| File | Committed to Git? | Purpose | When Loaded |
|------|-------------------|---------|-------------|
| `.env.example` | ✅ Yes | Template with placeholder values | Never (documentation only) |
| `.env.development` | ✅ Yes | Shared dev defaults (safe values) | When `NODE_ENV=development` |
| `.env.local` | ❌ No | Your personal local overrides | Always (except test) |
| `.env.production.local` | ❌ No | **Should NEVER exist locally** | When `NODE_ENV=production` |
| `.env.production` | ❌ No | **Should NEVER exist locally** | When `NODE_ENV=production` |

## Setup for Developers

### First Time Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dummy-frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create your local environment file**
   ```bash
   cp .env.example .env.local
   ```

4. **Edit `.env.local`** with your local settings (if needed)
   - Default values in `.env.development` usually work out of the box
   - Only override in `.env.local` if you need different ports, etc.

5. **Start the development server**
   ```bash
   npm run dev
   ```
   Next.js will automatically load `.env.development` and `.env.local`

## Frontend Environment Variables - Important Concepts

### NEXT_PUBLIC_ Prefix

**Critical:** Variables prefixed with `NEXT_PUBLIC_` are exposed to the browser!

```bash
# ✅ EXPOSED to browser (client-side JavaScript can access this)
NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1

# ❌ NOT exposed to browser (only available in server-side code)
SECRET_API_KEY=abc123
```

**Security Implications:**
- ✅ `NEXT_PUBLIC_*` vars are safe for API URLs, feature flags, public config
- ❌ NEVER put secrets, API keys, or credentials in `NEXT_PUBLIC_*` vars
- ❌ Anyone can view `NEXT_PUBLIC_*` vars in browser DevTools

### Where Variables Are Available

| Variable Type | Server Components | Client Components | API Routes | Browser DevTools |
|--------------|-------------------|-------------------|------------|------------------|
| `NEXT_PUBLIC_*` | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Visible |
| Regular (no prefix) | ✅ Yes | ❌ No | ✅ Yes | ❌ Hidden |

## Development Workflow

### Running Locally

```bash
# Development mode (uses .env.development + .env.local)
npm run dev

# Production build locally (for testing)
npm run build
npm run start
```

### Using Different Configurations

```bash
# Use development environment (default)
NODE_ENV=development npm run dev

# Test production build locally (not recommended - use Docker)
NODE_ENV=production npm run build
npm run start
```

## Production Deployment

**⚠️ IMPORTANT: NEVER keep `.env.production` or `.env.production.local` on your local machine**

### Option 1: Docker Build (Recommended)

Production environment variables are passed as **build arguments** during Docker build:

```bash
# Build with production API URL
docker build \
  --build-arg NEXT_PUBLIC_API_URL=https://api.yourproduction.com/api/v1 \
  -t dummy-frontend:latest \
  .
```

The Dockerfile (line 54-57) handles this:
```dockerfile
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
```

### Option 2: Deployment Platforms (Vercel, Netlify, etc.)

Set environment variables in the platform UI:

**Vercel:**
1. Project Settings → Environment Variables
2. Add `NEXT_PUBLIC_API_URL` = `https://api.yourproduction.com/api/v1`
3. Deploy

**Netlify:**
1. Site Settings → Environment variables
2. Add variables
3. Trigger redeploy

### Option 3: CI/CD (GitHub Actions, GitLab CI)

```yaml
# GitHub Actions example
- name: Build Docker image
  run: |
    docker build \
      --build-arg NEXT_PUBLIC_API_URL=${{ secrets.PRODUCTION_API_URL }} \
      -t frontend:latest \
      .
```

## Security Best Practices

### ✅ DO

- ✅ Use `NEXT_PUBLIC_*` only for non-sensitive, client-safe values
- ✅ Keep `.env.local` in `.gitignore`
- ✅ Commit `.env.example` and `.env.development` (safe values only)
- ✅ Set production values via Docker build args or deployment platform
- ✅ Use different API URLs for dev/staging/production
- ✅ Validate environment variables at build time

### ❌ DON'T

- ❌ Never commit `.env.local` or `.env.production` to git
- ❌ Never put secrets/API keys in `NEXT_PUBLIC_*` variables (exposed to browser!)
- ❌ Never keep `.env.production` on your local machine
- ❌ Never hardcode production URLs in source code
- ❌ Never share environment files via Slack/email (use secure channels if needed)

## Frontend vs Backend Environment Differences

| Aspect | Backend (Express/Node) | Frontend (Next.js) |
|--------|----------------------|-------------------|
| Personal dev file | `.env` | `.env.local` |
| Secrets storage | ❌ Never in frontend | ✅ In `.env` (server-only) |
| Public vars | N/A | `NEXT_PUBLIC_*` |
| Prod credentials local | ❌ Never | ❌ Never |
| Build-time vars | docker-compose | Docker build args |

**Key Difference:** Frontend `NEXT_PUBLIC_*` variables are inherently public (sent to browser), so security considerations are different from backend secrets.

## Environment Variables Reference

### Current Variables

#### NEXT_PUBLIC_API_URL
- **Type:** Public (exposed to browser)
- **Purpose:** Backend API base URL
- **Development:** `http://localhost:3005/api/v1`
- **Production:** Set via Docker build arg or deployment platform
- **Example:**
  ```javascript
  // Accessible in client-side code
  const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/users`)
  ```

### Adding New Variables

**For public variables (accessible in browser):**
```bash
# .env.local or .env.development
NEXT_PUBLIC_FEATURE_FLAG=true
NEXT_PUBLIC_ANALYTICS_ID=GA-XXXXX
```

**For server-only variables (API routes, server components):**
```bash
# .env.local (NOT accessible in browser)
DATABASE_URL=postgresql://...
INTERNAL_API_SECRET=secret123
```

## Troubleshooting

### "Environment variable is undefined in browser"

**Problem:** Variable not accessible in client components

**Solutions:**
1. Add `NEXT_PUBLIC_` prefix if it needs to be in the browser
2. If it's a secret, keep it server-only and access via API route
3. Restart dev server after adding new variables (`npm run dev`)

### "Old environment values still being used"

**Problem:** Next.js caches environment variables

**Solution:**
```bash
# Stop dev server (Ctrl+C)
# Delete .next cache
rm -rf .next
# Restart
npm run dev
```

### "Production build fails with missing variables"

**Problem:** Required variables not set during build

**Solution:**
```bash
# Ensure build args are passed
docker build --build-arg NEXT_PUBLIC_API_URL=https://api.example.com .

# Or set in deployment platform's environment variables UI
```

## Who Should Have Access to What

| Role | .env.local | .env.development | .env.production | How to Access Production |
|------|-----------|------------------|-----------------|--------------------------|
| **Junior Developer** | ✅ Yes (local) | ✅ Yes (in repo) | ❌ No | N/A |
| **Senior Developer** | ✅ Yes (local) | ✅ Yes (in repo) | ❌ No | View in deployment platform |
| **Lead Engineer** | ✅ Yes (local) | ✅ Yes (in repo) | ❌ No | Deployment platform admin |
| **DevOps Engineer** | ✅ Yes (local) | ✅ Yes (in repo) | ❌ No | CI/CD secrets, platform admin |
| **CTO / Engineering Manager** | ✅ Yes (local) | ✅ Yes (in repo) | ❌ No | Deployment platform admin |

**Remember:** Production values should only exist:
- ✅ In deployment platform UI (Vercel, Netlify, AWS, etc.)
- ✅ In CI/CD secrets (GitHub Actions, GitLab CI)
- ✅ As Docker build arguments in deployment scripts
- ❌ Never on local laptops

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Frontend

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: |
          docker build \
            --build-arg NEXT_PUBLIC_API_URL=${{ secrets.PRODUCTION_API_URL }} \
            -t dummy-frontend:latest \
            .

      - name: Deploy to production
        run: |
          # Your deployment commands here
```

### Vercel Deployment

Vercel automatically:
1. Detects Next.js projects
2. Loads environment variables from Vercel dashboard
3. Builds with correct `NODE_ENV=production`
4. No need to manage `.env.production` files

## Questions?

If you have questions about environment configuration:
1. Check this documentation
2. Review `.env.example` for required variables
3. Check Next.js docs: https://nextjs.org/docs/app/building-your-application/configuring/environment-variables
4. Ask the team lead

**Remember:**
- Next.js uses `.env.local` (not `.env`) for local development
- `NEXT_PUBLIC_*` variables are exposed to the browser
- Never commit `.env.local` or `.env.production` to git
- Production config via deployment platform, not local files
