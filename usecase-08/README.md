# Use Case 08: Observe, Alert, and Investigate the Application

## Objective

Implement local observability for the Claims application using Prometheus,
Grafana, Loki, Grafana Alloy, and Prometheus alert rules.

## Service URLs

- Frontend: http://localhost:8081
- Backend: http://localhost:5001
- Health: http://localhost:5001/api/health
- Metrics: http://localhost:5001/metrics
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- Loki: http://localhost:3100/ready
- Alloy: http://localhost:12345

## PromQL Queries

### Request rate

```promql
sum(rate(claims_http_requests_total[5m]))
```

### Server error rate

```promql
sum(rate(claims_http_requests_total{status=~"5.."}[5m])) or vector(0)
```

### Average response time in milliseconds

```promql
(
  sum(rate(claims_http_request_duration_seconds_sum[5m]))
  /
  sum(rate(claims_http_request_duration_seconds_count[5m]))
) * 1000
```

### Backend availability

```promql
up{job="claims-backend"}
```

## LogQL Query

```logql
{service="backend"} |= "GET /api/health"
```

## Alert

`ClaimsBackendDown` fires when Prometheus cannot scrape the backend for more
than 30 seconds.

## Start the Application

```bash
docker compose up -d --build
```

## Start Observability Services

```bash
docker compose \
  -f usecase-08/docker-compose.observability.yml \
  up -d
```

## Verification

```bash
curl -i http://localhost:5001/api/health
curl -s http://localhost:5001/metrics
curl -i http://localhost:3100/ready
curl -s http://localhost:3000/api/health
```

## Incident Investigation

1. Check the backend health endpoint.
2. Confirm the Prometheus target is UP.
3. Review request rate, error rate, and latency.
4. Search backend logs in Loki.
5. Check the alert state.
6. Restore the failed component.
7. Confirm that the alert returns to Inactive.
