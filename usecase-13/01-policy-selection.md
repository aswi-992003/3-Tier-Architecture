# Use Case 13 Policy Selection

## Selected rule

Every container in a Kubernetes Deployment must define:

- CPU request
- Memory request
- CPU limit
- Memory limit

## Why this rule is needed

Resource requests help Kubernetes schedule Pods correctly.

Resource limits prevent a container from consuming excessive CPU or memory
and affecting other workloads.

## Validation method

The Kubernetes manifests will be checked with Conftest before deployment.

## Enforcement boundary

This is a local and CI validation policy for the lab.

It will not be installed as a cluster-wide admission policy.

## Expected behavior

1. An unsafe Deployment without resources will fail the policy check.
2. The policy output will clearly explain the missing configuration.
3. A corrected Deployment with requests and limits will pass.
4. Only the corrected Deployment will be applied to Kubernetes.
