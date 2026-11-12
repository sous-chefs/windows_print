# windows_print_driver

Installs a named printer driver or deletes its print-spooler registration.
Actions: `:install` (default), `:delete`.

| Property | Default | Purpose |
| --- | --- | --- |
| `driver_name` | resource name | Exact driver name |
| `inf_path`, `inf_file` | unset | Optional directory and INF filename; supply both to stage a vendor package |
| `environment` | `x64` | `x64`, `x86` or `Itanium`; Windows must support the supplied package |
| `version` | `Type 3 - User Mode` | Driver type; also accepts `Type 2 - Kernel Mode` where Windows supports it |

```ruby
windows_print_driver 'Generic / Text Only'

windows_print_driver 'Vendor driver' do
  inf_path 'C:/drivers/vendor'
  inf_file 'vendor.inf'
end
```

Without INF properties, the driver must already be available in the Windows driver
store. A supplied INF is staged with `pnputil`; errors propagate. An installed
driver of the requested name, environment and type is left unchanged.

Delete requires no INF files. Windows rejects deleting a driver still used by a
queue. The resource retains the shared driver-store package. It does not perform
in-place package upgrades based on an INF checksum or package version.

The Chef/Cinc execution account must have read access to the driver package,
including any network share. Separate username/password properties are not supported.
