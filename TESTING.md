# Testing Windows Print

## Unit tests

Use Cinc Workstation:

```text
chef install Policyfile.rb
chef exec rspec
cookstyle
```

ChefSpec steps into each resource and covers exact-name handling, query failures,
installation/deletion, drift reconciliation, no-op convergence and legacy scanner
availability. The test cookbook is local and requires no Supermarket dependencies.

## Native Windows integration

Run Kitchen on a disposable Windows Server with administrator access. The exec
driver manages the machine where it runs; do not use it on a production print
server or the shared development VM without explicit permission.

```powershell
$env:CHEF_LICENSE = 'accept-no-persist'
$env:WINDOWS_PLATFORM = 'windows-2025'
chef install Policyfile.rb
kitchen test default-windows-2025
kitchen test resources-windows-2025 --destroy=never
$env:PRINT_TEST_ACTION = 'update'
kitchen converge resources-windows-2025
kitchen verify resources-windows-2025 --test-base-path test/lifecycle
$env:PRINT_TEST_ACTION = 'delete'
kitchen converge resources-windows-2025
kitchen verify resources-windows-2025 --test-base-path test/lifecycle
```

CI runs the default, Internet Printing, LPD and resources suites on Windows Server
2022 and 2025. Every converge runs twice and requires zero updates on the second
run. Resource tests use the Windows inbox Generic/Text Only driver, a reserved
documentation IP address, and a settings backup/restore roundtrip. Lifecycle tests
update the port and queue, then delete the queue, port, driver and backup.
The queue name includes brackets, embedded quotes, an ampersand and a percent
expression. A similarly named sibling verifies that updates and deletion target
only the selected queue and retain shared dependencies until explicitly removed.

Older supported Windows Server versions can use the same native exec harness by
setting `WINDOWS_PLATFORM` to their instance label. Distributed Scan needs a
domain-joined Server 2016 host and the `distributed_scan_server` named run list;
the cookbook never creates a domain. That legacy path has unit coverage but no
hosted Windows integration runner.

The existing vendor-driver fixture URL returns HTTP 404 and has been retired.
Vendor INF staging is covered by unit tests; a vendor-specific integration needs
an operator-provided, trusted driver compatible with the target Windows version.

CI uploads Kitchen logs, including debug verifier output, and caps jobs at
45 minutes. Passing unit tests on macOS does not prove native Windows behaviour.
