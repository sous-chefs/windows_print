# windows_print Cookbook

This cookbook installs Windows Print and Document Services, handles driver, port, and printer installation.

## Requirements

### Platform

* Windows Server 2012+

### Cookbooks

* none

## Usage

### windows_print::default

The `windows_print::default` recipe installs the required roles and features to support a windows print server.

Includes the Print Management snap-in, which is used for managing multiple printers or print servers and migrating printers to and from other Windows print servers.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print]"
  ]
}
```

### windows_print::distributed_scan_server

The `windows_print::distributed_scan_server` recipe installs the required roles and features to install a [distributed scan server](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/jj134196%28v%3dws.11%29).

Provides the service which receives scanned documents from network scanners and routes them to the correct destinations. It also includes the Scan Management snap-in, which you can use to manage network scanners and configure scan processes.

This feature is only available for server 2012r2 and server 2016.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print::distributed_scan_server]"
  ]
}
```

### windows_print::internet_printing

The `windows_print::internet_printing` recipe installs the required roles and features to install internet printing.

Creates a Web site where users can manage print jobs on the server. It also enables users who have Internet Printing Client installed to use a Web browser to connect and print to shared printers on the server by using the Internet Printing Protocol (IPP).

This feature is only available for server 2012r2 and server 2016.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print::internet_printing]"
  ]
}
```

### windows_print::lpd_service

The `windows_print::lpd_service` recipe installs the required roles and features to install LPD Service.

Line Printer Daemon (LPD) Service enables UNIX-based computers or other computers using the Line Printer Remote (LPR) service to print to shared printers on this server.

This feature is only available for server 2012r2 and server 2016.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print::lpd_service]"
  ]
}
```

## Resource/Provider

### driver

Installs printer driver from inf file.

#### Actions

* :install: Installs a printer driver
* :delete: Removes a printer driver

#### Property Parameters

* driver_name: name property.  Name of the print driver.
* inf_path: Full path to the inf file.
* inf_file: Name of the inf file.
* version: Default "Type 3 - User Mode" Options: "Type 3 - User Mode" or "Type 2 - Kernel Mode"
* environment: Chipset of the driver being installed. Default "x64" Options: "x86", "x64" or "Itanium".
* domain_username: Domain username to allow mapping network drive for driver installation.
* domain_password: Password for domain username.

### Examples

```ruby
    # Install HP LaserJet 9050 PS driver
    windows_print_driver 'HP LaserJet 9050 PS' do
      action :install
      inf_path 'c:\\9050 x64'
      inf_file 'hpc9050v.inf'
    end

    # Install HP LaserJet 9050 PS driver from network location
    windows_print_driver 'HP LaserJet 9050 PS' do
      action :install
      inf_path '\\Network Share\\print drivers\\9050 x64'
      inf_file 'hpc9050v.inf'
      domain_username 'Chef'
      domain_password 'Password'
    end

    # Delete HP LaserJet 9050 PS driver
    windows_print_driver 'HP LaserJet 9050 PS' do
      action :delete
    end
```

### 'printer'

Allows creation of printer objects.  Handles port and driver creation if not present.

#### Actions

* :create: Creates a printer
* :delete: Deletes a printer

#### Property Parameters

* printer_name: name property.  Name of the printer. Required
* driver_name: Name of the print driver. Required
* ports: Name of the port and IPv4 address. Required
* share_name: Shared printer object name.
* location: Location field for printer object.
* comment: Comments section for printer object.
* inf_path: Full path to the inf file.
* inf_file: Name of the inf file.
* version: Default "Type 3 - User Mode" Options: "Type 3 - User Mode" or "Type 2 - Kernel Mode"
* environment: Chipset of the driver being installed. Default "x64" Options: "x86", "x64" or "Itanium".
* domain_username: Domain username to allow mapping network drive for driver installation.
* domain_password: Password for domain username.

#### Examples

```ruby
    # Create HP LaserJet
    windows_print_printer 'HP LaserJet' do
      action :create
      driver_name 'HP LaserJet'
      port_name 'HP LaserJet'
    end

    # Create HP LaserJet, create driver, create port
    windows_print_printer 'HP LaserJet' do
      action :create
      driver_name 'HP LaserJet'
      ports ({ "HP LaserJet" => "10.0.0.50" })
      inf_path 'C:\\chef\\cookbooks\\windows_print\\files\\default\\HP Universal Printing PCL 6 (v5.4)\\x64'
      inf_file 'hpcu118u.inf'
      environment 'x64'
    end

    # Create HP LaserJet and share as 'HP Printer'
    windows_print_printer 'HP LaserJet' do
      action :create
      driver_name 'HP LaserJet'
      ports ({ "HP LaserJet" => "10.0.0.50" })
      comment ''
      inf_path 'C:\\chef\\cookbooks\\windows_print\\files\\default\\HP Universal Printing PCL 6 (v5.4)\\x64'
      inf_file 'hpcu118u.inf'
      share_name 'HP Printer'
      environment 'x64'
    end

    # Create HP LaserJet with multiple ports
    windows_print_printer 'HP LaserJet' do
      action :create
      driver_name 'HP LaserJet'
      ports ({ "HP LaserJet" => "10.0.0.50",
               "HP ColorLaserJet" => "10.0.0.51"
             })
      comment ''
      inf_path 'C:\\chef\\cookbooks\\windows_print\\files\\default\\HP Universal Printing PCL 6 (v5.4)\\x64'
      inf_file 'hpcu118u.inf'
      share_name 'HP Printer'
      environment 'x64'
    end

    # Deletes HP LaserJet
    windows_print_port 'HP LaserJet' do
      action :delete
    end
```

### 'printer_settings'

Creates and restores printer settings (Printing Defaults) from binary file.

#### Actions

* :create: Creates a bin file to store settings.
* :restore: Uses previously created bin file to restore settings.

#### Property Parameters

* printer_name: Name of the printer.
* path: Full path to settings file.
* file: File name to store settings to.
* domain_username: Domain username to allow mapping network drive for driver installation.
* domain_password: Password for domain username.

#### Examples

```ruby
    # Create settings file for 'HP LaserJet'
    windows_print_printer_settings 'HP Laserjet' do
      path '\\\\<server>\\<share>'
      file 'HP LaserJet.bin'
      action: create
      domain_username 'Chef'
      domain_password 'Password'
    end

    # Restore settings file for 'HP LaserJet'
    windows_print_printer_settings 'HP Laserjet' do
      path '\\\\<server>\\<share>'
      file 'HP LaserJet.bin'
      action: restore
      domain_username 'Chef'
      domain_password 'Password'
    end
```

### 'port'

Allows creation of ports based on name rather than IP Address.

#### Actions

* :create: Installs a printer port
* :delete: Removes a printer port

#### Property Parameters

* port_name: name property.  Name of the port.
* ipv4_address: IPv4 address of the printer port
* ports: Name of the port and IPv4 address.

#### Examples

```ruby
    # Install PrinterPort1 port @ 10.0.0.50
    windows_print_port 'PrinterPort1' do
      action :create
      ipv4_address '10.0.0.50'
    end

    # Deletes PrinterPort1 port
    windows_print_port 'PrinterPort1' do
      action :delete
    end
```

## Example Recipes

### windows_print::create_printer_settings_data_bag

The `test_windows_print::create_printer_settings_data_bag` will create bin files containing the current printer defaults.  These must be manually changed through Print Management.  Assumes printer data bag item is labelled `printers`.  See `.\test\fixtures\data_bags` for sample data bag example.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[test_windows_print::create_printers_settings_data_bag]"
  ]
}
```

### windows_print::create_printers_data_bag

The `test_windows_print::create_printers_data_bag` will install the driver, create the port, and printer for each data bag item.  Assumes printer data bag item is labelled `printers`.  See `.\test\fixtures\data_bags` for sample data bag example.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[test_windows_print::create_printers_data_bag]"
  ]
}
```

### windows_print::delete_printers_data_bag

The `test_windows_print::delete_printers_data_bag` will remove the port and printer for each data bag item.  The driver is not touched as there is no current method to detect if the driver is still in use.  Assumes printer data bag item is labelled `printers_del`.  See `.\test\fixtures\data_bags` for sample data bag example.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[test_windows_print::delete_printers_data_bag]"
  ]
}
```

### windows_print::restore_printer_settings_data_bag

The `test_windows_print::restore_printer_settings_data_bag` will restore bin files containing the printer defaults.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[test_windows_print::printer_settings_data_bag]"
  ]
}
```

## Example Data Bags

### printer_defaults

Example binary file created from create_printer_settings_data_bag and used to restore settings using restore_printer_settings_data_bag.

### printers/printers_del

Example data bag for using `data_bags` to manage printer objects. `inf_file` will contain the `driver_name` value.

```json
{
  "id": "HP-LaserJet-9050",
  "printer_name": "HP-LaserJet-9050",
  "share_name": "HP-LaserJet-9050",
  "inf_path": "\\\\fileserver\\Print Drivers\\HP Universal Printing PCL 6 (v5.4)\\x64",
  "inf_file": "hpcu118u.inf",
  "comment": "",
  "location": "",
  "driver_name": "HP Universal Printing PCL 6 (v5.4)",
  "ports": { "HP-LaserJet-9050" : "192.168.1.100" },
  "environment": "x64",
  "domain_username": "admin",
  "domain_password": "Password",
  "path": "c:\\chef\\cache\\windows_print\\files\\printer_defaults",
  "file": "HP-LaserJet-9050.bin"
}
```

## Contributing

1. Fork the repository on Github
1. Create a named feature branch (like `add_component_x`)
1. Write you change
1. Write tests for your change (if applicable)
1. Run the tests, ensuring they all pass
1. Submit a Pull Request using Github

## License and Authors

Authors:: Derek Groh (<dgroh@arch.tamu.edu>)
