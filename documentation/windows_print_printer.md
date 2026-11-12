# windows_print_printer

Creates or reconciles a local print queue. Actions: `:create` (default), `:delete`.

| Property | Default | Purpose |
| --- | --- | --- |
| `printer_name` | resource name | Exact queue name |
| `driver_name` | unset | Required for create |
| `ports` | `{}` | Port-name to IPv4-address mapping; use `nil` to reference an existing port |
| `port_name`, `ipv4_address` | unset | Alternative single-port form; do not combine with `ports` |
| `share_name` | `''` | Empty means unshared |
| `location`, `comment` | `''` | Queue metadata; empty clears the field |
| `inf_path`, `inf_file`, `environment`, `version` | driver defaults | Passed to `windows_print_driver` |

```ruby
windows_print_printer 'Office' do
  driver_name 'Generic / Text Only'
  ports 'Office TCP' => '192.0.2.10'
  share_name 'Office'
  location 'First floor'
end
```

The resource creates the requested ports and driver before configuring the queue.
It updates existing queue properties and does nothing when they already match.
Comma-separated port names are reserved for Windows printer pooling and cannot
be used as an individual port name.

Delete requires only the queue name. Shared drivers and ports remain installed;
remove them with their own resources after deleting all queues that use them.

Driver packages on network shares must be accessible to the Chef/Cinc execution
account. The resource does not accept separate network credentials.
