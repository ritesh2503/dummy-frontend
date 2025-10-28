# Docker Setup for Frontend

This document explains how to use Docker with the Next.js frontend.

## Quick Reference

### Development Workflow (Recommended)

**Option 1: Run frontend locally with backend in Docker**
```bash
# Terminal 1: Start backend services
cd ../dummy-backend
docker-compose up -d

# Terminal 2: Run frontend locally (best for hot reload)
cd dummy-frontend
npm install
npm run dev
```

Frontend will be available at: http://localhost:3000

**Why run frontend locally?**
- ✅ Instant hot reload (faster than Docker)
- ✅ Better developer experience
- ✅ Easier debugging with browser dev tools
- ✅ No container rebuilds needed

---

### Building Docker Image

Build the production-ready Docker image:

```bash
# Basic build
docker build -t dummy-frontend .

# Build with environment variables
docker build \
  --build-arg NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1 \
  -t dummy-frontend .
```

---

### Running Docker Container

Run the production container:

```bash
# Basic run
docker run -p 3000:3000 dummy-frontend

# Run with environment variables
docker run \
  -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1 \
  dummy-frontend

# Run in detached mode (background)
docker run -d -p 3000:3000 --name my-frontend dummy-frontend

# Stop the container
docker stop my-frontend

# Remove the container
docker rm my-frontend
```

---

### Multi-Stage Build Explained

The Dockerfile uses 3 stages for optimization:

1. **deps** - Installs all dependencies
2. **builder** - Builds the Next.js application
3. **runner** - Minimal production runtime

**Benefits:**
- 🚀 Smaller final image (only includes what's needed to run)
- 🔒 More secure (runs as non-root user)
- ⚡ Faster startup (optimized production build)
- 💾 Better caching (separate stages for deps and build)

---

### Environment Variables

**IMPORTANT:** For complete environment configuration and security best practices, see [ENV-SETUP.md](./ENV-SETUP.md)

**Build-time variables (baked into the build):**
```bash
NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1
```

**Set during build:**
```bash
# Development
docker build --build-arg NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1 -t dummy-frontend:dev .

# Production (NEVER build production images locally - use CI/CD)
docker build --build-arg NEXT_PUBLIC_API_URL=https://api.production.com -t dummy-frontend:prod .
```

**Security Notes:**
- ⚠️ `.env` files are **NEVER** copied into Docker images (excluded via `.dockerignore`)
- ⚠️ **NEVER build production images on your local machine** - use CI/CD pipelines
- ⚠️ `NEXT_PUBLIC_*` variables are exposed to the browser - never put secrets in them
- ✅ Use build args (`--build-arg`) for all configuration
- ✅ Production builds should happen in CI/CD with secrets from vault/secrets manager

**Runtime variables (can be changed without rebuild):**
- Must be set in your hosting platform (Vercel, AWS, etc.)
- Not applicable for NEXT_PUBLIC_ variables (those are build-time only)

---

### Deployment Examples

**Deploy to production:**

```bash
# Build for production
docker build \
  --build-arg NEXT_PUBLIC_API_URL=https://api.yourapp.com/api/v1 \
  -t dummy-frontend:production .

# Push to registry (Docker Hub, AWS ECR, etc.)
docker tag dummy-frontend:production yourusername/dummy-frontend:latest
docker push yourusername/dummy-frontend:latest

# Or deploy to cloud platforms:
# - Vercel: vercel deploy (no Docker needed, native Next.js support)
# - AWS ECS: Use the Docker image
# - Google Cloud Run: Use the Docker image
# - Railway: Connect GitHub repo (auto-detects Dockerfile)
```

---

### Troubleshooting

**Build fails - "Cannot copy from stage 'builder'"**
- Make sure Next.js config has `output: 'standalone'` enabled
- Check that next.config.ts is properly configured

**Image is too large**
- Multi-stage build should make it ~150-200MB
- Check .dockerignore is excluding node_modules, .git, etc.

**Hot reload not working in container**
- Don't use Docker for development, use `npm run dev` instead
- Docker is for production builds only

**API calls fail from container**
- Check NEXT_PUBLIC_API_URL is set correctly
- Remember: containers use container networking
- From host → backend: http://localhost:3005
- From container → backend: http://host.docker.internal:3005 (Mac/Windows)

---

## Best Practices

✅ **Development**: Run `npm run dev` locally (not in Docker)
✅ **Production**: Use Docker for deployment
✅ **Environment Variables**: Use build args for NEXT_PUBLIC_ variables
✅ **Security**: Image runs as non-root user (nextjs:1001)
✅ **Optimization**: Multi-stage build keeps image small

---

## File Structure

```
dummy-frontend/
├── Dockerfile              # Multi-stage production build
├── .dockerignore           # Excludes unnecessary files from build
├── next.config.ts          # Enables standalone output mode
├── package.json
├── app/                    # Next.js app directory
└── DOCKER.md              # This file
```

---

## Questions?

- Docker not building? Check that Docker Desktop is running
- Port 3000 in use? Change port: `docker run -p 3001:3000`
- Need help? Check main README.md or Docker documentation
