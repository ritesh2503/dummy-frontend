export interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  orgId: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface LoginRequest {
  email: string;
  password: string;
}
