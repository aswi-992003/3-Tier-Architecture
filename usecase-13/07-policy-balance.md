# Use Case 13: Policy Balance

## Policy objective

The policy requires every container in a Kubernetes Deployment to define:

- CPU request
- Memory request
- CPU limit
- Memory limit

## Risk prevented

Containers without requests make Kubernetes scheduling less predictable.

Containers without limits can consume excessive resources and affect other
applications running in the cluster.

## Why this is a useful guardrail

The rule checks an important production requirement before a manifest reaches
the Kubernetes cluster.

The failure messages identify the container and the exact missing field, so a
developer can correct the manifest without guessing.

## Why this policy is not unnecessarily strict

The policy does not require one fixed CPU or memory value.

Each application team can select suitable values for its workload.

The policy only requires the four resource fields to exist.

The policy currently checks Kubernetes Deployments used in this lab. It is not
installed as a cluster-wide admission rule.

## Controlled failure

An unsafe Deployment without resource requests and limits was created.

Conftest rejected it with four understandable failure messages.

The unsafe Deployment was not applied to Kubernetes.

## Recovery

A corrected manifest was created with CPU and memory requests and limits.

The same Conftest policy accepted the corrected manifest.

The corrected Deployment was applied successfully, and its Pod reached the
Running and Ready state.

## Final result

Unsafe manifest: Blocked

Fixed manifest: Allowed

Fixed workload: Successfully deployed

Application test: HTTP 200 OK

## Prevention

Run Conftest in the CI pipeline before kubectl apply.

Only manifests that pass the policy check should be allowed to reach the
deployment stage.
