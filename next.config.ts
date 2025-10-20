import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // output: 'standalone' - Enables standalone output mode for Docker deployment
  // This creates a minimal production build in .next/standalone that:
  // - Includes only the files necessary to run the application
  // - Automatically copies required node_modules
  // - Creates a server.js file that can run independently
  // - Reduces Docker image size significantly (only includes what's needed)
  // Required for the Dockerfile to work properly in production
  output: 'standalone',
};

export default nextConfig;
