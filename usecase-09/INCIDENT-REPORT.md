# Incident Report: Claims Backend Unavailable

## Summary

A controlled incident was performed by stopping the Claims backend container.
The health endpoint became unavailable, Prometheus marked the backend target
as DOWN, and the ClaimsBackendDown alert entered the Firing state.

## Impact

The Claims API and backend health endpoint were unavailable. The frontend and
database containers continued running.

## Detection

The incident was detected through:

- Failed `/api/health` request
- Missing backend container in `docker compose ps`
- Prometheus backend target showing DOWN
- ClaimsBackendDown alert showing Firing
- Request rate falling to zero
- Grafana dashboard observations
- Backend log investigation in Loki

## Timeline

- Incident started: Replace with the recorded incident start time
- Prometheus target detected as DOWN
- ClaimsBackendDown entered the Firing state
- Investigation completed using Prometheus, Grafana, Loki, and Docker
- Recovery started using `docker compose start backend`
- Service recovered: Replace with the recorded recovery time
- Prometheus target returned to UP
- ClaimsBackendDown returned to Inactive

## Investigation

The frontend and database were running, but the backend was stopped.
Prometheus could not connect to the backend metrics endpoint on port 5001.
The request-rate graph dropped to zero. Loki showed successful health requests
before the backend stopped and no new backend access logs during the outage.

## Root Cause

The Claims backend container was deliberately stopped as part of a controlled
local incident simulation.

## Recovery

The backend was recovered with:

```bash
docker compose start backend