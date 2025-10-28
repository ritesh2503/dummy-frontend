# ==================== Frontend Dockerfile for Next.js ====================
# This uses a multi-stage build to create an optimized production image
# Stage 1: Install dependencies
# Stage 2: Build the application
# Stage 3: Run the production server

# ==================== Stage 1: Dependencies ====================
# FROM - Specifies the base image to build from
# node:18-alpine - Official Node.js version 18 image based on Alpine Linux
#   Alpine is a lightweight Linux distribution (~5MB vs ~900MB for full images)
# AS deps - Names this build stage "deps" for reference in later stages
FROM node:18-alpine AS deps

# Install libc6-compat for compatibility with some npm packages
# Alpine Linux uses musl libc, but some packages expect glibc
# libc6-compat provides compatibility layer for better package support
RUN apk add --no-cache libc6-compat

# Set working directory inside the container to /app
# All subsequent commands (COPY, RUN, CMD) will execute from this directory
WORKDIR /app

# Copy package.json and package-lock.json from host to container
# Copying these first (before source code) enables Docker layer caching
# If dependencies don't change, Docker reuses this cached layer
COPY package*.json ./

# Install dependencies
# npm ci - "Clean Install" - faster, more reliable than npm install
#   - Installs exactly what's in package-lock.json (no version resolution)
#   - Removes node_modules first if it exists
#   - Fails if package.json and package-lock.json are out of sync
# This installs ALL dependencies (including devDependencies needed for build)
RUN npm ci

# ==================== Stage 2: Builder ====================
# Build the Next.js application for production
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy node_modules from deps stage (avoids reinstalling)
# --from=deps specifies to copy from the "deps" stage
# This is more efficient than reinstalling dependencies
COPY --from=deps /app/node_modules ./node_modules

# Copy all source code from host to container
# This includes: pages, components, public, styles, next.config.js, etc.
# Note: .env files are excluded via .dockerignore (security best practice)
COPY . .

# ==================== Environment Configuration ====================
# SECURITY: Never copy .env files into Docker images
# Instead, pass environment variables as build arguments
#
# Build arguments - can be passed during docker build
# Example: docker build --build-arg NEXT_PUBLIC_API_URL=https://api.prod.com .
#
# Development: docker build --build-arg NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1 .
# Production:  docker build --build-arg NEXT_PUBLIC_API_URL=https://api.yourproduction.com/api/v1 .
#
# See ENV-SETUP.md for complete documentation
# ===================================================================
ARG NEXT_PUBLIC_API_URL
# Set environment variable from build argument
# Next.js will inline this value during build for NEXT_PUBLIC_ variables
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# Disable Next.js telemetry during build (optional, for privacy)
ENV NEXT_TELEMETRY_DISABLED=1

# Build the Next.js application
# next build creates an optimized production build in .next folder
# - Minifies JavaScript and CSS
# - Optimizes images
# - Creates static pages where possible
# - Generates server-side rendering code
RUN npm run build

# ==================== Stage 3: Production Runner ====================
# Final stage - smallest possible image with only what's needed to run
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Set Node environment to production
# This optimizes Node.js runtime performance and disables dev features
ENV NODE_ENV=production

# Disable Next.js telemetry in production
ENV NEXT_TELEMETRY_DISABLED=1

# Create a non-root user for security
# Running as root in containers is a security risk
# addgroup creates a group, adduser creates a user and adds to group
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files from builder stage
# public folder contains static assets (images, fonts, etc.)
COPY --from=builder /app/public ./public

# Set correct permissions for prerender cache
# Next.js needs to write to .next/cache for ISR (Incremental Static Regeneration)
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Copy the built application from builder stage
# .next folder contains the compiled Next.js application
# --chown sets the owner to nextjs user for security
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
# All subsequent commands and the application will run as this user
USER nextjs

# Expose port 3000
# Next.js production server listens on port 3000 by default
# Note: This is documentation only - actual port mapping happens in docker run
EXPOSE 3000

# Set PORT environment variable (Next.js uses this)
ENV PORT=3000

# Set hostname to 0.0.0.0 to accept connections from outside container
# By default, Next.js binds to localhost which won't accept external connections
ENV HOSTNAME="0.0.0.0"

# Start the Next.js production server
# CMD in exec format (JSON array) - recommended over shell form
# "node server.js" starts the optimized production server
# This is faster and uses less memory than "npm start"
CMD ["node", "server.js"]
