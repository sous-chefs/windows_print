# Windows Print migration

## Scope and compatibility

* Full custom resource migration authorised for a major release. Remove public recipes and Berkshelf; keep the four print-management capabilities and existing resource names.
* Original PR 50 run 43177104396 completed before prepared fix 506f2af was pushed, as the user required. Keep that release branch separate while developing the major migration. Do not touch the shared Windows VM.
* Retain existing release publishing destinations. The OCI-only restriction applies to the distinct firewalld cookbook.
* Keep Distributed Scan's legacy Server 2012 R2/2016 domain-member behaviour. It was removed in Server 2019; modern Windows CI can verify only its unavailable-platform path.
* The owner chose to remove the ineffective network credential properties. The Chef/Cinc execution account must have access to network shares; do not add implicit impersonation.
* Backup and restore are operational actions. Callers can use notifications with `action :nothing`; they are not configuration-state resources.

## Native Windows behaviour

* Windows Print and Document Services is an operating-system feature; no source build is needed. Printer drivers must match the installed Windows environment and come from the operator's trusted source.
* Use exact object selection and PowerShell single-quoted literals. PrintManagement's name parameters can accept wildcards; mutating a previously selected object avoids unintended matches.
* Query failures must propagate rather than being interpreted as missing objects.
* Printer deletion must retain drivers and ports, which may be shared by other queues. Remove them explicitly after queues no longer use them.
* Preserve native driver-store packages on driver deletion because other drivers/devices may use the same package.
* Local macOS cannot execute PrintManagement. ChefSpec covers resource actions; hosted native Windows Kitchen must verify lifecycle and second-converge idempotence before merge.
* The feature branch has a temporary, exact branch push trigger to obtain native Kitchen evidence before opening a PR. Remove that extra push branch after the first complete native run; retain normal PR and main-branch checks.

## Sources

* [Microsoft PrintManagement](https://learn.microsoft.com/en-us/powershell/module/printmanagement/)
* [Printer driver installation](https://learn.microsoft.com/en-us/powershell/module/printmanagement/add-printerdriver)
* [Printer updates](https://learn.microsoft.com/en-us/powershell/module/printmanagement/set-printer)
* [PrintUI backup and restore](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/rundll32-printui)
* [Removed Windows Server features](https://learn.microsoft.com/en-us/windows-server/get-started/removed-deprecated-features-windows-server-2025)
