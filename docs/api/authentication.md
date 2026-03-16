# Authentication

## Login

```http
POST /auth/login
Content-Type: application/json

{
  "username": "operator@acme.com",
  "password": "secret"
}
```

## Response

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "...",
  "expiresIn": 3600
}
```

## Refresh Token

```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "..."
}
```
