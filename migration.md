# Migrating to Windows Print 3

Version 3 provides custom resources and requires Chef Infra or Cinc 18 or later.
The public recipes and Berkshelf configuration have been removed.

| Previous recipe | Replacement |
| --- | --- |
| `windows_print::default` | `windows_print_install 'server'` |
| `windows_print::internet_printing` | `windows_print_install 'ipp'` with `role :internet_printing` |
| `windows_print::lpd_service` | `windows_print_install 'lpd'` with `role :lpd_service` |
| `windows_print::distributed_scan_server` | `windows_print_install 'scan'` with `role :distributed_scan_server` |

Put these resource declarations in your own wrapper cookbook. The examples in
`test/cookbooks/test/recipes` use Policyfile dependency management.

## Printer resources

The `windows_print_driver`, `windows_print_port`, `windows_print_printer` and
`windows_print_printer_settings` names remain available.

* Driver and printer deletion now need only the name and any non-default driver environment/type. Installation-only properties are no longer required to delete an object.
* Existing printers now reconcile their driver, ports, sharing, comment and location. The default empty `share_name` means unshared; empty comment/location values clear those fields.
* Port addresses now reconcile through Windows' printing administration script. An existing non-TCP/IP port with the same name causes a clear failure instead of being silently accepted.
* Printer deletion retains shared ports and drivers. Delete those explicitly when they are no longer used by other queues. Driver deletion retains the shared Windows driver-store package.
* Names are matched literally. Wildcards no longer select additional queues, ports or drivers.
* Driver `version` is the Windows driver type, not a package version. The installed type must match the requested type. Updating a driver package with an unchanged name remains an operator-managed operation.
* The unused `ports` property on `windows_print_port` has been removed. Use one resource per port. The printer resource still accepts a `ports` hash.
* The ineffective `domain_username` and `domain_password` properties have been removed from driver, printer and printer-settings resources. Remove them from resource declarations. Run Chef/Cinc under an account with the required access to network shares used for driver packages or backups; the cookbook does not impersonate another account.

## Settings backup and restore

Both operations run when invoked. Use `action :nothing` and notifications when
they should run only after another resource changes. Restore now requires an
existing backup and printer, and fails clearly if either is missing.
It no longer silently skips a valid backup.
Backup writes a fresh temporary file, validates that it is non-empty, then
replaces the selected backup. A failed export preserves the previous backup.
TCP/IP address updates also reject port names containing double quotes or
beginning with `//`, which Windows Script Host changes or consumes as host
options. Port creation and deletion remain available for those names.

## Platforms

Windows Server 2016 and later remain supported. Automated integration tests run
on native Windows Server 2022 and 2025 runners. Distributed Scan retains the
older domain-member check and does nothing on Server 2019 or later, where the
feature was removed. Its legacy Server 2012 R2 path remains in the implementation,
but Server 2012 R2 is outside the supported platform range.
