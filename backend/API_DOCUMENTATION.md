# BSLND Backend API Documentation

Complete API reference for all endpoints.

## Base URL

```
http://localhost:3000
```

## Authentication

All protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com"
  }
}
```

### Error Response

```json
{
  "error": "Error message describing what went wrong"
}
```

## Endpoints

### Health Check

#### GET /health

Health check endpoint to verify API and database status.

**Parameters:** None

**Response:**

```json
{
  "status": "ok",
  "message": "BSLND Backend API is running",
  "database": "connected",
  "timestamp": "2024-03-12T10:30:00.000Z"
}
```

---

### Authentication Endpoints

#### POST /api/auth/register

Register a new user account.

**Parameters:**

| Name     | Type   | Required | Description         |
|----------|--------|----------|---------------------|
| email    | string | Yes      | User email address  |
| password | string | Yes      | User password       |
| name     | string | No       | User full name      |
| phone    | string | No       | User phone number   |

**Request:**

```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "name": "John Doe",
  "phone": "+1234567890"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+1234567890"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errors:**

- `400 Bad Request` - Email or password missing
- `409 Conflict` - User already exists

---

#### POST /api/auth/login

Authenticate user and receive JWT token.

**Parameters:**

| Name     | Type   | Required | Description        |
|----------|--------|----------|--------------------|
| email    | string | Yes      | User email address |
| password | string | Yes      | User password      |

**Request:**

```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+1234567890"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errors:**

- `400 Bad Request` - Email or password missing
- `401 Unauthorized` - Invalid credentials

---

#### GET /api/auth/me

Get currently authenticated user information.

**Authentication:** Required

**Parameters:** None

**Response (200 OK):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "created_at": "2024-03-12T08:00:00.000Z"
}
```

**Errors:**

- `401 Unauthorized` - No token provided
- `403 Forbidden` - Invalid or expired token
- `404 Not Found` - User not found

---

## Status Codes

| Code | Meaning                  | Usage                                      |
|------|--------------------------|---------------------------------------------|
| 200  | OK                       | Successful GET/PUT request                 |
| 201  | Created                  | Successful POST request                    |
| 400  | Bad Request              | Invalid parameters or missing required data|
| 401  | Unauthorized             | Missing or invalid authentication token    |
| 403  | Forbidden                | User authenticated but not authorized      |
| 404  | Not Found                | Resource not found                         |
| 409  | Conflict                 | Resource already exists (duplicate)        |
| 500  | Internal Server Error    | Server-side error                          |

## Error Handling

The API returns error responses in the following format:

```json
{
  "error": "Descriptive error message"
}
```

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Email and password are required` | Missing login credentials | Provide both email and password |
| `User already exists` | Email already registered | Use a different email or login |
| `Invalid credentials` | Wrong email/password combination | Check credentials and try again |
| `Access token required` | No token in Authorization header | Include valid token in header |
| `Invalid or expired token` | Token is expired or malformed | Obtain a new token by logging in |
| `User not found` | User doesn't exist | Check user ID and try again |

## Rate Limiting

Currently no rate limiting is implemented. This should be added in production.

## CORS

The API accepts requests from all origins (configurable via `CORS_ORIGIN` env var).

## JWT Token Structure

The JWT token contains:

```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "iat": 1710238800,
  "exp": 1710843600
}
```

- **iat:** Token issued at timestamp
- **exp:** Token expiration timestamp (7 days from issue)

## Example API Calls

### Using cURL

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Get current user
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Using Thunder Client / Postman

1. Import the endpoints into your REST client
2. Set the Authorization header to Bearer token type
3. Test each endpoint

## Versioning

Current API Version: `1.0.0`

Future versions will use `/api/v2/`, `/api/v3/`, etc.

## Future Endpoints (TODO)

The following endpoint groups need to be implemented:

- User Management (`/api/users/`)
- Subscriptions (`/api/subscriptions/`)
- Content Management (`/api/avdhan/`, `/api/samagam/`, `/api/patrika/`)
- Paath Forms (`/api/paath-forms/`)
- Donations (`/api/donations/`)
- Payments Webhook (`/api/payments/webhook`)
- Admin Routes (`/api/admin/`)

See README.md for implementation guidelines.

## Support

For issues or questions:
1. Check this documentation
2. Review the README.md
3. Check CONTRIBUTING.md for development guidelines
4. Create an issue on GitHub

