# Claims Backend Recovery Runbook

## Purpose

Use this runbook when the Claims backend health endpoint is unavailable or the
ClaimsBackendDown alert is firing.

## Investigation

1. Check the health endpoint:

   curl -i --max-time 5 http://localhost:5001/api/health

2. Check the application containers:

   docker compose ps

3. Open Prometheus Targets:

   http://localhost:9090/targets

4. Check the ClaimsBackendDown alert:

   http://localhost:9090/alerts

5. Review the Grafana dashboard:

   http://localhost:3000

6. Search backend logs in Loki:

   {service="backend"} |= "GET /api/health"

7. Review recent Git changes:

   git log --oneline -5

## Recovery

Start the backend:

    docker compose start backend

Wait for the health endpoint:

    for i in {1..30}; do
      if curl -fsS http://localhost:5001/api/health; then
        echo "Backend recovered successfully"
        break
      fi
      sleep 2
    done

## Recovery Verification

1. Confirm `/api/health` returns HTTP 200.
2. Confirm the backend container is healthy.
3. Confirm the Prometheus target returns to UP.
4. Confirm ClaimsBackendDown returns to Inactive.
5. Review Grafana metrics after recovery.
6. Confirm new backend logs appear in Loki.
7. Update the incident report with the verified timeline and root cause.