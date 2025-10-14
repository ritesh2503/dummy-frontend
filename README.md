# Frontend Application

A Next.js application with authentication, built with TypeScript and Tailwind CSS.

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
├── components/           # Reusable components
│   ├── Button.tsx
│   ├── Card.tsx
│   ├── Input.tsx
│   └── index.ts
├── lib/                  # Utility functions
│   ├── api.ts           # API client functions
│   └── auth.ts          # Authentication utilities
├── types/               # TypeScript type definitions
│   └── user.ts
├── middleware.ts        # Next.js middleware for route protection
└── .env.local          # Environment variables
```

## Features

- User authentication with JWT
- Protected routes with middleware
- Dashboard with user information
- Reusable UI components
- Type-safe API calls
- Tailwind CSS styling

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
The `.env.local` file should contain:
```bash
NEXT_PUBLIC_API_URL=http://localhost:3005/api/v1
```

3. Start the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

## Available Routes

- `/` - Home page (shows user info if logged in)
- `/login` - Login page
- `/dashboard` - Protected dashboard (requires authentication)

## API Integration

The application connects to the backend API at `http://localhost:3005/api/v1`. Key endpoints:

- `POST /user/login` - User authentication
- `GET /user/:id` - Get user details

## Components

### Button
Reusable button component with variants (primary, secondary, danger)

### Card
Container component with CardHeader and CardBody sub-components

### Input
Form input component with label support

## Utilities

### API Client (`lib/api.ts`)
Centralized API calls for authentication and user management

### Auth Utilities (`lib/auth.ts`)
Helper functions for managing tokens and user data in localStorage

## Route Protection

The middleware protects routes that require authentication. Protected routes:
- `/dashboard/*`

Authenticated users are automatically redirected away from:
- `/login`

## Development

```bash
# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linting
npm run lint
```

## Tech Stack

- Next.js 15
- React 19
- TypeScript
- Tailwind CSS
- JWT Authentication
