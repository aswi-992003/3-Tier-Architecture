# Use Case 17 RTO and RPO

## Test scope

A dedicated PostgreSQL table named public.usecase17_backup_test was used.
Only record ID 1701 was deleted and restored.

## Backup evidence

Backup artifact:

usecase-17/backups/usecase17_backup_test.sql

Backup duration:

16 seconds

## Restore evidence

Restore duration:

43 seconds

The recovered record was queried successfully after the restore.

## Observed RTO

The observed restore execution time was approximately 43
seconds. A production RTO would also include detection, approval, restore,
validation, and application recovery time.

## Observed RPO

The backup contained the latest version of test record 1701. No valid updates
occurred between backup and controlled deletion. The observed RPO for this
record was therefore effectively zero.

In production, RPO depends on backup frequency. For example, an hourly backup
schedule may allow up to approximately one hour of data loss.

## Result

PASS: The test record was backed up, deleted, restored, and verified.

## Prevention

- Schedule automated database backups.
- Retain multiple backup versions.
- Encrypt backup artifacts.
- Monitor backup failures.
- Regularly test restore procedures.
- Restrict restore permissions.
- Record RTO and RPO targets for each production service.
