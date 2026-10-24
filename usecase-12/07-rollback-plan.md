# Use Case 12 Rollback Plan

## Protected secret

- Vault path: `secret/midhlab/usecase12`
- Vault key: `api_token`
- Kubernetes namespace: `claims-k8s-lab`
- Kubernetes Secret: `claims-usecase12-secret`
- Kubernetes key: `API_TOKEN`
- Deployment: `claims-backend`

## When to roll back

Rollback should begin if secret rotation causes:

- Authentication failures
- Readiness or startup failures
- `CreateContainerConfigError`
- Application health-check failures
- An unsuccessful Kubernetes rollout

## Rollback procedure

1. Identify the last working Vault secret version.
2. Load it into a temporary shell variable without printing it.
3. Update the Kubernetes Secret.
4. Remove the temporary variable.
5. Restart the backend Deployment.
6. Wait for the rollout to complete.
7. Verify that the Pod is Running.
8. Verify that the health endpoint returns HTTP 200.
9. Save only masked status and metadata as evidence.

## Rollback commands

Set the Vault address:

    export VAULT_ADDR="http://127.0.0.1:8200"

Load the previous version:

    ROLLBACK_TOKEN=$(vault kv get \
      -version=1 \
      -field=api_token \
      secret/midhlab/usecase12)

Apply it to Kubernetes:

    kubectl create secret generic claims-usecase12-secret \
      --from-literal=API_TOKEN="$ROLLBACK_TOKEN" \
      -n claims-k8s-lab \
      --dry-run=client \
      -o yaml \
      | kubectl apply -f -

Remove the shell variable:

    unset ROLLBACK_TOKEN

Restart and verify the Deployment:

    kubectl rollout restart deployment/claims-backend \
      -n claims-k8s-lab

    kubectl rollout status deployment/claims-backend \
      -n claims-k8s-lab \
      --timeout=180s

Verify application health:

    curl -i http://localhost:5001/api/health

## Security rule

Never print, screenshot, save, commit, or send the secret value through chat.
Only Vault metadata, Kubernetes references, rollout status, and health results
should be saved as evidence.
