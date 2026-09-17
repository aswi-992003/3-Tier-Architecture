# Use Case 03 — Run the App Locally and Prepare Config

## Purpose

Run the Claims application locally using Docker Compose, separate
configuration from code, protect secrets, and prove that the stack can
stop and restart cleanly.

## Services

- Frontend: http://localhost:8081
- Backend: http://localhost:5001
- Backend health: http://localhost:5001/api/health
- Database: PostgreSQL 16 inside the Compose network

The application does not contain a separate worker service.

## Initial setup

Create the private local environment file:

```bash
cp .env.example .env
