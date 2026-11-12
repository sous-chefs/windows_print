# Windows Print cookbook

Manage Windows Print and Document Services, printer drivers, TCP/IP ports,
print queues and settings backups with Chef custom resources.

Requires Chef Infra or Cinc 18 or later and Windows Server 2016 or later.
Version 3 removes the public recipes; see the [migration guide](migration.md).

## Usage

```ruby
windows_print_install 'print server'

windows_print_printer 'Office' do
  driver_name 'Generic / Text Only'
  ports 'Office TCP' => '192.0.2.10'
  share_name 'Office'
  location 'First floor'
end
```

## Resources

* [windows_print_install](documentation/windows_print_install.md): install or remove the print server, Internet Printing, LPD or legacy Distributed Scan role.
* [windows_print_driver](documentation/windows_print_driver.md): install or remove a printer driver.
* [windows_print_port](documentation/windows_print_port.md): manage a standard TCP/IP printer port and its address.
* [windows_print_printer](documentation/windows_print_printer.md): create, update or remove a print queue.
* [windows_print_printer_settings](documentation/windows_print_printer_settings.md): back up, restore or remove settings files.

Printer deletion retains ports and drivers that may be shared. Backup and restore
run when explicitly invoked; use notifications to control when they execute.

Distributed Scan remains limited to older domain-joined servers and does nothing
on Server 2019 or later. See the migration guide for platform compatibility.

## Testing

The [testing guide](TESTING.md) describes ChefSpec and native Windows Kitchen
tests. Examples live in `test/cookbooks/test/recipes`.

## Authors and licence

Originally written by Derek Groh and Texas A&M. Maintained by Sous Chefs.
See [LICENSE](LICENSE) and the retained source-file notices.
