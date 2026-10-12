# Use Case 07: Automate Operations with Ansible and Vault

## Goal

Automate a repeatable configuration operation with Ansible and handle a
temporary lab secret with HashiCorp Vault without exposing its value.

## Ansible operation

The playbook manages `/tmp/usecase07-managed.conf` on localhost.

- Check mode predicts the change without applying it.
- The first run creates the configuration.
- The second run reports `changed=0`, proving idempotency.

## Vault operation

A local Vault development server stores a temporary application credential.

- The secret value is entered using silent terminal input.
- The password is never written to the repository.
- Saved evidence contains only masked confirmation and metadata.
- Writing a new version demonstrates secret rotation.

## Evidence

The `evidence` directory contains:

1. Inventory output
2. Connectivity test
3. Facts check
4. Check-mode output
5. First Ansible run
6. Second idempotent run
7. Controlled failure
8. Recovery
9. Vault status
10. Masked Vault read
11. Vault rotation
12. Vault version metadata
