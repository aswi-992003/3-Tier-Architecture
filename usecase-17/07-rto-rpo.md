# Use Case 17 — RTO and RPO

## RTO

Recovery Time Objective is the maximum acceptable time required to
restore data or service after a failure.

For this lab, the observed RTO includes:

- Restore-command duration
- Time required to verify record 1701
- Time required to confirm application access

Observed RTO = restore duration + verification duration.

The restore-duration evidence is stored in:

`evidence/04-restore-duration-seconds.txt`

## RPO

Recovery Point Objective is the maximum acceptable amount of data that
can be lost, expressed as time.

Record 1701 existed when the backup was created. No valid changes were
made between backup creation and the controlled deletion. After the
restore, record 1701 returned successfully.

Therefore, the observed RPO for this controlled test is effectively zero.

In production, RPO depends on backup frequency. For example, hourly
backups may allow up to one hour of data loss.

## Result

The backup was proven usable by performing a successful restore.
Record 1701 was recovered and verified through the database and
application. No valid data was permanently lost.
