# Nginx Routing Explained

## 1. Purpose

Nginx is used as a reverse proxy for the Meridian Retail application.

Instead of allowing users to access the application containers directly through their individual ports, Nginx provides a single public entry point through the application's domain.

The traffic flow is:

```text
User
  ↓
DuckDNS Domain
  ↓
HTTPS :443
  ↓
Nginx
  ├── /       → Frontend container
  └── /api/*  → Backend API
```

This provides a cleaner and more secure way to expose the application to the internet.

## 2. Why Nginx Is Used

Before implementing Nginx, application services could be accessed through their individual ports.

For example:

```text
Frontend       → port 80
Auth Service   → port 8000
Catalog API    → port 4000
Orders Service → port 8001
```

Exposing these ports directly to the internet is not ideal.

With Nginx, only the standard web ports are exposed publicly:

```text
HTTP  → 80
HTTPS → 443
```

Nginx receives the incoming request and forwards it internally to the appropriate Docker container.

The backend services therefore do not need to be directly exposed to the public internet.

## 3. Application Traffic Flow

A customer accesses the application using the configured DuckDNS domain.

```text
https://meridian-shop.duckdns.org
```

The request reaches the EC2 instance on HTTPS port 443.

Nginx receives the request and determines where it should be sent.

### Frontend request

```text
https://meridian-shop.duckdns.org/
             ↓
           Nginx
             ↓
       Frontend container
```

### API request

```text
https://meridian-shop.duckdns.org/api/...
             ↓
           Nginx
             ↓
       Backend API container
```

This allows the frontend and backend to be accessed through the same domain.

## 4. HTTP to HTTPS Redirect

The application is configured to use HTTPS.


```text
https://meridian-shop.duckdns.org
```

This ensures that normal web traffic is encrypted using TLS.

Certbot was used to obtain and configure the TLS certificate.

## 5. Frontend Routing

Requests to the root path `/` are routed to the frontend application.

Conceptually:

```nginx
location / {
    proxy_pass http://frontend;
}
```

The frontend container is responsible for serving the customer-facing application.


## 6. API Routing

API requests use the `/api/` path.

For example:

```text
https://your-domain.duckdns.org/api/products
```

Nginx identifies `/api/` as an API request and forwards it to the appropriate backend service.

Conceptually:

```nginx
location /api/ {
    proxy_pass http://backend-service;
}
```

The exact backend routing depends on the services configured in the application.

This allows users to interact with the APIs without knowing the internal Docker container addresses or ports.

## 7. Reverse Proxy Headers

Nginx forwards useful information about the original request to the backend.

Common headers include:

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

These headers allow the backend application to understand information about the original client request.

For example:

- `Host` — the original domain requested by the user
- `X-Real-IP` — the client's IP address
- `X-Forwarded-For` — the forwarding chain of IP addresses
- `X-Forwarded-Proto` — whether the original request used HTTP or HTTPS

## 8. Nginx and Docker

Nginx runs on the EC2 host while the application services run in Docker containers.

The general architecture is:

```text
                    Internet
                       │
                       │ HTTPS :443
                       ▼
                    Nginx
                       │
             Docker network
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
      Frontend                  Backend APIs
                                      │
                         ┌────────────┼────────────┐
                         ▼            ▼            ▼
                       Auth        Catalog       Orders
                                      │
                                      ▼
                                  PostgreSQL
```

Nginx acts as the public gateway to the application.



## 9. Testing the Configuration

The application can then be tested through the public domain.

### HTTP test

```text
http://your-domain.duckdns.org
```

Expected result:

```text
Redirect → HTTPS
```

### HTTPS frontend test

```text
https://your-domain.duckdns.org
```

Expected result:

```text
Frontend application loads
```

### API test

```text
https://your-domain.duckdns.org/api/...
```

Expected result:

```text
Request reaches the appropriate backend service
```

