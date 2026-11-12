# windows_print_port

Address updates use Windows Script Host, which cannot preserve embedded double
quotes in port-name arguments and consumes names beginning with `//` as host
options. Such updates fail before mutation. Port creation and deletion do not use
Script Host and retain literal-name handling.

Creates, updates or deletes one standard TCP/IP printer port.
Actions: `:create` (default), `:delete`.

| Property | Default | Purpose |
| --- | --- | --- |
| `port_name` | resource name | Exact port name |
| `ipv4_address` | unset | Required for create; the printer's IPv4 address |

```ruby
windows_print_port 'Office TCP' do
  ipv4_address '192.0.2.10'
end
```

An address change updates the existing port through Microsoft's `prnport.vbs`,
retaining printer queues and other port settings. Windows' printing administration
scripts must be installed. The resource rejects an existing non-TCP/IP port with
the same name. Delete does not require an address and Windows rejects removal of
a port still in use by a queue.
