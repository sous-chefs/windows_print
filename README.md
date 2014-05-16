windows_print Cookbook
==============
This cookbook installs Windows Print and Document Services, handles driver, port, and printer installation.

Requirements
------------

Platform
--------

* Windows Server 2008 R2
* Windows Server 2012
* Windows Server 2012 R2

Cookbooks
---------

- Windows - Official windows cookbook from opscode - https://github.com/opscode-cookbooks/windows.git

Usage
-----
#### windows_print::default
The windows_print::default recipe installs the required roles and features to support a windows print server.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print]"
  ]
}
```

#### windows_print::distributed_scan_server
The windows_print::distributed_scan_server recipe installs the required role to support a windows distributed scan server.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print::distributed_scan_server]"
  ]
}
```

#### windows_print::internet_printing
The windows_print::internet_printing recipe installs the required roles and features to support a windows print server internet printing including IIS.  This action will install all require features from windows_print::default.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print::internet_printing]"
  ]
}
```

#### windows_print::lpd_service
The windows_print::lpd_service recipe installs the required role to install a line printer daemon service.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_print::lpd_service]"
  ]
}
```

Resource/Provider
=================

'driver'
--------
Installs printer driver from inf file.

### Actions
- :install: Installs a printer driver
- :delete: Removes a printer driver

### Attribute Parameters
- driver_name: name attribute.  Name of the print driver.
- inf_path: Full path to the inf file.
- inf_file: Name of the inf file.
- version: Default "Type 3 - User Mode" Options: "Type 3 - User Mode" or "Type 2 - Kernel Mode"
- environment: Chipset of the driver being installed. Default "x64" Options: "x86", "x64" or "Itanium".
- domain_username: Domain username to allow mapping network drive for driver installation.
- domain_password: Password for domain username.

### Examples

    # Install HP LaserJet 9050 PS driver
    windows_print_driver "HP LaserJet 9050 PS" do
      action :install
      inf_path "c:\\9050 x64"      
      inf_file "hpc9050v.inf"
    end

    # Install HP LaserJet 9050 PS driver from network location
    windows_print_driver "HP LaserJet 9050 PS" do
      action :install
      inf_path "\\Netshare\\print drivers\\9050 x64"      
      inf_file "hpc9050v.inf"
      domain_username "Chef"
      domain_password "Password"
    end

    # Delete HP LaserJet 9050 PS driver
    windows_print_driver "HP LaserJet 9050 PS" do
      action :delete
    end

'printer'
--------
Allows creation of printer objects.  Handles port and driver creation if not present.

### Actions
- :create: Creates a printer
- :delete: Deletes a printer

### Attribute Parameters
- printer_name: name attribute.  Name of the printer. Required
- driver_name: Name of the print driver. Required
- ports: Name of the port and IPv4 address. Required
- share_name: Shared printer object name.
- location: Location field for printer object.
- comment: Comments section for printer object.
- inf_path: Full path to the inf file.
- inf_file: Name of the inf file.
- version: Default "Type 3 - User Mode" Options: "Type 3 - User Mode" or "Type 2 - Kernel Mode"
- environment: Chipset of the driver being installed. Default "x64" Options: "x86", "x64" or "Itanium".
- domain_username: Domain username to allow mapping network drive for driver installation.
- domain_password: Password for domain username.

### Examples

    # Create HP LaserJet
    windows_print_printer "HP LaserJet" do
      action :create
      driver_name "HP LaserJet"
      port_name "HP LaserJet"
    end

    # Create HP LaserJet, create driver, create port
    windows_print_printer "HP LaserJet" do
      action :create
      driver_name "HP LaserJet"
      ports ({ "HP LaserJet" => "10.0.0.50" })
      inf_path "C:\\chef\\cookbooks\\windows_print\\files\\default\\HP Universal Printing PCL 6 (v5.4)\\x64"
      inf_file "hpcu118u.inf"
      environment "x64"
    end

    # Create HP LaserJet and share as "HP Printer"
    windows_print_printer "HP LaserJet" do
      action :create
      driver_name "HP LaserJet"
      ports ({ "HP LaserJet" => "10.0.0.50" })
      comment ""
      inf_path "C:\\chef\\cookbooks\\windows_print\\files\\default\\HP Universal Printing PCL 6 (v5.4)\\x64"
      inf_file "hpcu118u.inf"
      share_name "HP Printer"
      environment "x64"
    end
    
    # Create HP LaserJet with multiple ports
    windows_print_printer "HP LaserJet" do
      action :create
      driver_name "HP LaserJet"
      ports ({ "HP LaserJet" => "10.0.0.50",
               "HP ColorLaserJet" => "10.0.0.51"
             })
      comment ""
      inf_path "C:\\chef\\cookbooks\\windows_print\\files\\default\\HP Universal Printing PCL 6 (v5.4)\\x64"
      inf_file "hpcu118u.inf"
      share_name "HP Printer"
      environment "x64"
    end
    
    # Deletes HP LaserJet
    windows_print_port "HP LaserJet" do
      action :delete
    end

'printer_settings'
------------------
Creates and restores all printer settings (Printing Defaults)

### Actions
- :create: Creates a bin file to store settings.
- :restore: Uses previously created bin file to restore settings.

### Attribute Parameters
- printer_name: Name of the printer.
- path: Full path to settings file.
- file: File name to store settings to.
- domain_username: Domain username to allow mapping network drive for driver installation.
- domain_password: Password for domain username.

### Examples

    # Create settings file for "HP LaserJet"
    windows_print_printer_settings "HP Laserjet" do
      path "\\\\<server>\\<share>"
      file "HP LaserJet.bin"
      action: create
      domain_username "<domain>\\<username>"
      domain_password "<Password>"
    end

    # Retore settings file for "HP LaserJet"
    windows_print_printer_settings "HP Laserjet" do
      path "\\\\<server>\\<share>"
      file "HP LaserJet.bin"
      action: restore
      domain_username "<domain>\\<username>"
      domain_password "<Password>"
    end

'port'
--------
Allows creation of ports based on name rather than IP Address.

### Actions
- :create: Installs a printer port
- :delete: Removes a printer port

### Attribute Parameters
- port_name: name attribute.  Name of the port.
- ipv4_address: IPv4 address of the printer port

### Examples

    # Install PrinterPort1 port @ 10.0.0.50
    windows_print_port "PrinterPort1" do
      action :create
      ipv4_address "10.0.0.50"
    end

    # Deletes PrinterPort1 port
    windows_print_port "PrinterPort1" do
      action :delete
    end

Contributing
============

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
===================

Authors:: Derek Groh (<dgroh@arch.tamu.edu>)
