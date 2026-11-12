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

Backup creates the destination directory when needed and overwrites the selected
backup. Restore requires that both the file and printer exist. Operations store
or restore printer-specific data and global/per-user DEVMODE settings; they do not
rename the printer or migrate its queue/driver installation.

These are operational actions, not persistent configuration declarations. For
change-driven execution, use `action :nothing` and notify `:create` or `:restore`.
Deletion removes the selected file and retains its directory, which may contain
other backups.
