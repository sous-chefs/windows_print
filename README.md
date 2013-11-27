windows_print Cookbook
==============
This cookbook installs Windows Print and Document Services, handles driver, port and printer installation.

Additionally handles the application install of Papercut

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
- Powershell - Official powershell cookbook form opscode - https://github.com/opscode-cookbooks/powershell

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
**Note** Provided until printer_driver support added to Windows cookbook from opscode.

### Actions
- :create: Installs a printer driver
- :delete: Removes a printer driver

### Attribute Parameters
- driver_name: name attribute.  Name of the print driver to install.
- inf_path: Full path to the inf file.
- version: Default "Type 3 - User Mode" Options: "Type 3 - User Mode" or "Type 2 - Kernel Mode"
- environment: Chipset of the driver being installed. Default "x64" Options: "x86", "x64" or "Itanium".

### Examples

    # Install HP LaserJet 9050 PS driver
    windows_print_driver "HP LaserJet 9050 PS" do
      action :create
      inf_path "c:\\9050 x64\\hpc9050v.inf"      
    end

    # Delete HP LaserJet 9050 PS driver
    windows_print_driver "HP LaserJet 9050 PS" do
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