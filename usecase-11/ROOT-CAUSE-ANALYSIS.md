# Use Case 11 ImagePullBackOff Recovery

## Summary

A controlled Kubernetes image-pull failure was created by deploying the Claims
frontend with a nonexistent Harbor image tag.

## Symptom

The pod entered ErrImagePull and then ImagePullBackOff.

## First Check

The pod was inspected with kubectl get pods and kubectl describe pod.

## Event Evidence

The Kubernetes event showed that the requested image tag could not be found in
the Harbor registry.

## Root Cause

The Deployment referenced the nonexistent image tag usecase-11-missing.

## Registry and Secret Validation

Harbor was reachable. The harbor-pull-secret existed in the claims-k8s-lab
namespace and had type kubernetes.io/dockerconfigjson.

## Recovery

The Deployment image was changed to the valid usecase-11-good tag.

## Validation

The rollout completed successfully and the replacement pod reached Running and
Ready status.

## Prevention

Validate image tags before deployment, use immutable image digests where
possible, verify imagePullSecrets in the target namespace, and fail the CI
pipeline before deployment when the requested artifact is unavailable.
