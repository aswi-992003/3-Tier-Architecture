# Use Case 13: Add Policy as Code for Kubernetes Deployments

## Goal

Block an unsafe Kubernetes Deployment before it reaches the cluster and allow
the corrected Deployment.

## Tool used

Conftest with a Rego policy.

## Selected rule

Every container in a Deployment must define:

- CPU request
- Memory request
- CPU limit
- Memory limit

## Workflow

1. Selected a practical resource policy.
2. Created the Rego policy.
3. Created an unsafe Deployment without resources.
4. Confirmed that Conftest blocked the unsafe manifest.
5. Added the required requests and limits.
6. Confirmed that the fixed manifest passed and deployed successfully.
7. Documented the balance between a useful guardrail and a noisy policy.

## Result

- Unsafe manifest: Blocked
- Fixed manifest: Passed
- Deployment rollout: Successful
- Pod status: Running and Ready
- HTTP validation: Successful

## Important boundary

This lab uses local and CI manifest validation. It does not install a
cluster-wide admission policy.
