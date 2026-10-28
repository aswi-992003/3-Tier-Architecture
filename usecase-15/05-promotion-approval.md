# Stage Promotion Approval

Environment: Stage
Source environment: Dev
Artifact rule: The same approved image digest must be used.
Required checks:

- Dev rollout succeeded
- Dev Pods are Ready
- Dev application responds successfully
- Dev and Stage use the same image digest
- No secret value is included in Git
- Stage values were reviewed

Approval status: APPROVED FOR LAB
Approved by: Lab operator
Rollback method: helm rollback usecase15-stage <REVISION> -n claims-stage
