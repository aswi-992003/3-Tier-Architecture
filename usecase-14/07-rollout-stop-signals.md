# Use Case 14 Rollout-Stop Signals

## Purpose

A new version receives production traffic only while it remains healthy. If a critical signal fails, the rollout must stop and traffic must return to the previous healthy version.

## Signals that stop the rollout

### 1. Readiness failure

Stop when the new Pod does not become Ready within 180 seconds, remains 0/1, or repeatedly fails its readiness probe.

### 2. Missing or unready Service endpoint

Stop when the Service has no endpoint or EndpointSlice reports Ready=false.

### 3. HTTP errors

Stop when the health endpoint does not return HTTP 200 or repeated HTTP 5xx responses occur.

A realistic production threshold is an HTTP 5xx error rate greater than 1%.

### 4. Increased latency

Stop or pause when Green response latency is significantly worse than the Blue baseline.

A possible threshold is Green p95 latency greater than twice the Blue p95 latency.

### 5. Container restarts

Stop when restart counts increase repeatedly or the Pod enters CrashLoopBackOff.

### 6. Application log errors

Stop when logs show repeated exceptions, authentication failures, database failures, permission errors, or dependency timeouts.

### 7. Business-function failures

Stop when important user operations fail even though the Pod is technically Running.

Examples include login failure, claim creation failure, failed database writes, or transaction errors.

## Failure demonstrated in this lab

The controlled bad version used an invalid readiness-probe path.

The bad Pod remained 0/1, its readiness probe returned HTTP 404, and the Service did not receive a ready endpoint.

This was the signal to move the Service selector back to the healthy Green version.

## Traffic-switch method

Traffic is controlled with Kubernetes Service selector patches:

- Blue rollback: usecase-14/traffic/blue-selector-patch.yaml
- Green production: usecase-14/traffic/green-selector-patch.yaml
- Controlled failure: usecase-14/traffic/bad-selector-patch.yaml

## Rollback to Blue

Run:

kubectl patch service usecase14-service -n claims-k8s-lab --type=merge --patch-file usecase-14/traffic/blue-selector-patch.yaml

## Return traffic to Green

Run:

kubectl patch service usecase14-service -n claims-k8s-lab --type=merge --patch-file usecase-14/traffic/green-selector-patch.yaml

## Successful rollout requirements

The rollout is successful only when:

1. The selected Deployment is available.
2. Its Pods are Ready.
3. EndpointSlice reports Ready=true.
4. The application returns HTTP 200.
5. Logs contain no critical errors.
6. The previous version remains available for rollback.
