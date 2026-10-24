# Use Case 12: Rotate Secrets Without Breaking the App

## Goal

Rotate a lab-only application secret using Vault and Kubernetes while keeping
the backend healthy and preventing secret exposure.

## Environment

- Secret manager: HashiCorp Vault
- Vault path: `secret/midhlab/usecase12`
- Kubernetes namespace: `claims-k8s-lab`
- Kubernetes Secret: `claims-usecase12-secret`
- Kubernetes key: `API_TOKEN`
- Deployment: `claims-backend`
- Health endpoint: `http://localhost:5001/api/health`

## Step 1: Select the secret

A lab-only API token was selected. No production credential was used.

## Step 2: Record the application reference

The backend Deployment reads `API_TOKEN` from the Kubernetes Secret named
`claims-usecase12-secret`. The value itself was not recorded.

## Step 3: Rotate the secret in Vault

A new random token was generated and written to Vault. Vault metadata confirmed
that the secret changed from version 1 to version 2.

## Step 4: Synchronize and restart

Vault version 2 was loaded into a temporary shell variable and synchronized to
the Kubernetes Secret. The variable was removed immediately afterward. The
backend Deployment was restarted and rolled out successfully.

## Step 5: Verify application health

The replacement Pod reached `1/1 Running`. The backend loaded `API_TOKEN`, the
Pod value matched the current Vault value, and the health endpoint returned
HTTP 200.

## Step 6: Check for secret exposure

Repository evidence was checked for both secret versions. No raw secret values
were found. Backend logs contained no authentication errors, and no Vault token
pattern was found in Use Case 12 files.

## Step 7: Controlled failure and recovery

The Kubernetes Secret was deliberately deleted. The replacement Pod entered
`CreateContainerConfigError`, and Kubernetes reported:

    secret "claims-usecase12-secret" not found

The current value was recovered securely from Vault, the Kubernetes Secret was
recreated, and the backend was restarted. The replacement Pod reached
`1/1 Running`, and the health endpoint returned HTTP 200.

## Root cause of controlled failure

The backend Deployment referenced a Kubernetes Secret that did not exist.
The application image and source code were not responsible for the failure.

## Prevention

- Validate required Secrets before restarting a workload.
- Automate approved Vault-to-Kubernetes synchronization.
- Monitor failed rollouts and `CreateContainerConfigError`.
- Retain safe Vault versions for rollback.
- Never print or commit secret values.

## Result

Use Case 12 completed successfully. The secret was rotated, synchronized,
verified, deliberately disrupted, and recovered without changing application
code or exposing secret values.
