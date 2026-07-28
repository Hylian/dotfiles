# Diagnosed Wedged Zellij Server Hang ٩(◕‿◕｡)۶

*Date: 2026-07-28*

## Symptom

Executing `zellij` or `zellij list-sessions` hung indefinitely without output.

## Diagnosis

1. An orphaned background `zellij --server` instance (`vitreous-orange`) was spinning at high CPU (~42.5%) logging infinite error messages:
   `Client sent over 1000 consecutive unknown messages, this is probably an infinite loop, logging client out`
2. Dozens of `zellij pipe zjstatus::rerun::git_branch` subshells from prompt hooks accumulated, blocking on the wedged IPC socket under `/run/user/<uid>/zellij/contract_version_1/vitreous-orange`.
3. Because all Zellij CLI calls attempt to query running server sockets in that directory, incoming commands hung waiting for a response from the wedged server thread.

## Resolution

- Terminated the orphaned server process and hung IPC clients (`pkill -9 -f zellij`).
- Verified `/run/user/<uid>/zellij/contract_version_1/` socket directory cleared.
- Tested `zellij list-sessions` and `zellij setup --check` — both return instantly with zero latency.
