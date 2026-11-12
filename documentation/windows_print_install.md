# windows_print_install

Installs or removes Windows Print and Document Services roles using Chef's native
`windows_feature` resource. Actions: `:install` (default), `:remove`.

| Property | Default | Purpose |
| --- | --- | --- |
| `role` | `:server` | `:server`, `:internet_printing`, `:lpd_service`, or `:distributed_scan_server` |
| `management_tools` | `true` | Install the Print Management console for the server role on Desktop Experience |
| `source` | unset | Optional Windows feature payload source |
| `timeout` | `1800` | Feature operation timeout in seconds |

```ruby
windows_print_install 'IPP' do
  role :internet_printing
end
```

Removal disables the selected printing role. It retains shared prerequisites,
such as IIS and .NET, which may serve other applications. Removing the main print
server role can affect dependent print services; remove queues deliberately first.
The resource does not automatically reboot the server.

Distributed Scan installs only on an older supported Windows build that is already
joined to a domain. It does not create or join a domain.
