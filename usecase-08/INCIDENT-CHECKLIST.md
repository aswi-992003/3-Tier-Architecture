# Claims Application Incident Checklist

## First three checks

1. Check application health:
   curl -i http://localhost:5001/api/health

2. Check Prometheus target status:
   Open http://localhost:9090/targets
   Confirm the claims-backend target is UP.

3. Check application metrics and logs:
   - Request rate
   - HTTP 5xx error rate
   - Average response time
   - Backend logs in Grafana Loki

## Investigation process

1. Confirm the reported user impact.
2. Check the backend health endpoint.
3. Check whether the Prometheus target is UP.
4. Review request rate, error rate, and latency.
5. Search Loki logs for the affected service and endpoint.
6. Check recent application or configuration changes.
7. Restart or roll back the affected component when required.
8. Verify that health, metrics, logs, and alerts recover.
9. Record the incident timeline and corrective action.

## Alert tested

- Alert: ClaimsBackendDown
- Condition: up{job="claims-backend"} == 0 for 30 seconds
- Test: Backend container stopped intentionally
- Result: Alert changed from Inactive to Firing
- Recovery: Backend container started again
- Final result: Alert returned to Inactive
