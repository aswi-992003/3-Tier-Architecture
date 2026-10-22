# Use Case 10: Jenkins Agent Failure and Recovery

## Summary

A controlled Jenkins agent failure was performed to demonstrate how a CI
infrastructure problem prevents a pipeline from running even when the
application code is healthy.

## Symptom

The `usecase-10-agent-recovery` pipeline remained in the Jenkins Build Queue
and displayed:

- Still waiting to schedule task
- Waiting for next available executor

## First Check

The Jenkins Built-In Node status was checked under:

Manage Jenkins > Nodes > Built-In Node

The node was offline with the reason:

`Use Case 10 controlled agent failure`

## Root Cause

The Jenkins Built-In Node had been deliberately taken offline. Therefore,
Jenkins had no available executor to run the pipeline.

After restoring the node, an additional CI environment issue was found:
the Jenkins agent could not locate the Docker command because the Docker CLI
directory was missing from the agent PATH.

The error was:

`docker: command not found`

## Resolution

1. The Jenkins Built-In Node was brought back online.
2. The Docker CLI directories were added to the Jenkins pipeline PATH.
3. Docker daemon availability was verified.
4. Harbor registry connectivity was verified.
5. Harbor credentials were validated.
6. The same pipeline was rerun without changing application code.

## Validation

Build #1 demonstrated the controlled failure.

Build #2 completed successfully with these stages:

- Agent Check
- Docker Check
- Disk Check
- Harbor Connectivity
- Harbor Credential Check

This confirmed that the problem was caused by CI infrastructure configuration
and not by application code.

## Prevention

- Monitor Jenkins node availability.
- Monitor available executor capacity.
- Keep the Docker CLI directory in the Jenkins agent PATH.
- Verify Docker daemon health before pipeline execution.
- Monitor disk capacity on Jenkins agents.
- Validate Harbor availability and credentials.
- Track credential and token expiration dates.
- Maintain a dedicated CI infrastructure health-check pipeline.

## Interview Explanation

I first determined whether the pipeline failure occurred before the application
build. The job remained queued because the Jenkins Built-In Node was offline.
After restoring the node, the pipeline revealed that Docker was missing from
the Jenkins agent PATH. I corrected the agent environment and reran the same
pipeline without modifying application code. Build #2 succeeded, proving that
the root cause was CI infrastructure configuration.
