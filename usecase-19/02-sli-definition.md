# SLI Definition

## Signal

Availability of the claims-backend `/api/health` endpoint.

## Measurement

Blackbox Exporter checks whether the endpoint returns a successful response.

- `probe_success = 1`: successful probe
- `probe_success = 0`: failed probe

## PromQL

```promql
avg_over_time(probe_success{usecase="usecase19"}[5m]) * 100
