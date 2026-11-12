# windows_print_printer_settings

Backs up or restores a printer's driver settings using Windows PrintUI.
Actions: `:restore` (default), `:create` (backup), `:delete` (remove backup file).

| Property | Default | Purpose |
| --- | --- | --- |
| `printer_name` | resource name | Exact queue name |
| `path` | required | Backup directory |
| `file` | required | Backup filename |

```ruby
windows_print_printer_settings 'Office' do
  path 'C:/printer-backups'
  file 'office.bin'
  action :create
end
```

Backup creates the destination directory when needed and replaces the selected
backup only after a fresh, non-empty export succeeds. Failed exports preserve the
previous backup. Restore requires that both the file and printer exist. Operations store
or restore printer-specific data and global/per-user DEVMODE settings; they do not
rename the printer or migrate its queue/driver installation.

These are operational actions, not persistent configuration declarations. For
change-driven execution, use `action :nothing` and notify `:create` or `:restore`.
Deletion removes the selected file and retains its directory, which may contain
other backups.

The Chef/Cinc execution account must have permission to access the backup path,
including any network share. This resource does not accept separate credentials
or impersonate another account.

Settings export and restore reject printer names containing double quotes before
making changes. PrintUI does not safely parse those names with Windows argument
escaping. Printer creation, update and deletion remain available for these names.
