# Use Case 16 Management Boundary

## Selected drift scenario

Argo CD-managed Kubernetes Deployment replica drift.

## Tool ownership

- Terraform manages the `claims-drift-lab` namespace.
- GitLab stores the desired Kubernetes and Argo CD configuration.
- Argo CD manages the application resources inside the namespace.
- kubectl will create one controlled replica-count drift.
- Docker Desktop Kubernetes provides visual confirmation.

## Controlled drift

The desired Deployment replica count will be 2.

A safe manual kubectl operation will temporarily change the live replica count
to 3. Argo CD should detect that the live state no longer matches Git.

## Correction decision

The Git configuration is the approved desired state and must win. Argo CD will
restore the Deployment to 2 replicas.

## Safety boundary

Do not modify existing application, shared, production, Argo CD system, or
Kubernetes system resources.
