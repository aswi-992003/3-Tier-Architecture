# Use Case 09: Simulate an Incident and Recover

## Objective

Practice a controlled incident response by stopping the Claims backend,
detecting the outage, investigating the available evidence, recovering the
service, and documenting the incident.

## Controlled Failure

The backend Docker container was intentionally stopped in the local lab.

## Tools Used

- Docker Compose
- Prometheus
- Grafana
- Loki
- Grafana Alloy
- GitLab and GitHub

## Incident Process

1. Verified the healthy baseline.
2. Generated normal application traffic.
3. Stopped the backend container.
4. Confirmed the user impact.
5. Checked Prometheus targets and alerts.
6. Reviewed the Grafana dashboard.
7. Investigated backend logs in Loki.
8. Started the backend container.
9. Verified the target and alert recovery.
10. Documented the root cause and prevention action.

## Recovery Command

    docker compose start backend

## Success Criteria

- The failure is controlled and reproducible.
- The backend health endpoint becomes unavailable.
- Prometheus identifies the backend as DOWN.
- ClaimsBackendDown enters the Firing state.
- The backend is recovered successfully.
- Prometheus returns to UP.
- The alert returns to Inactive.
- The incident report, runbook, and evidence are saved.