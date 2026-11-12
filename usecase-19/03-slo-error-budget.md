# SLO and Error Budget

## User-facing path

Claims backend health endpoint:

`/api/health`

## SLI

The percentage of successful Blackbox Exporter probes during the measurement period.

## SLO target

The `/api/health` endpoint should be available at least 99% of the time over a rolling 30-day period.

## Error budget

Allowed failure percentage:

`100% - 99% = 1%`

A 30-day period contains:

`30 × 24 × 60 = 43,200 minutes`

Allowed unavailable time:

`43,200 × 0.01 = 432 minutes`

Therefore, the 30-day error budget is:

`432 minutes = 7 hours 12 minutes`

## Interpretation

The service may be unavailable for up to 7 hours and 12 minutes within 30 days without violating the 99% SLO.

The alert threshold used in this lab will be stricter and evaluated over a short window so that a controlled failure can be demonstrated safely.
