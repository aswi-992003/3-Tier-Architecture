# Use Case 17 Recovery Summary

## Test scope

A single safe lab record with ID 1701 was selected.

## Backup

A backup was created and the backup artifact was confirmed to exist.

## Controlled failure

Record 1701 was intentionally deleted to simulate data loss. No shared
or production data was modified.

## Recovery

The backup was restored using the approved restore command.

## Verification

Record 1701 was present after restoration, and the application could
read the restored data.

## Recovery measurements

- Backup duration: recorded in the evidence directory
- Restore duration: recorded in `04-restore-duration-seconds.txt`
- Observed RTO: restore duration plus verification duration
- Observed RPO: effectively zero

## Conclusion

The test proved successful recovery, not only backup creation.
