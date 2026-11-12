# frozen_string_literal: true

#
# Cookbook:: windows_print
# Resource:: driver
#
# Copyright:: 2013, Texas A&M
#

unified_mode true
provides :windows_print_driver

property :driver_name, String, name_property: true
property :inf_path, String
property :inf_file, String
property :version, String, default: 'Type 3 - User Mode', equal_to: ['Type 3 - User Mode', 'Type 2 - Kernel Mode']
property :environment, String, default: 'x64', equal_to: %w(x64 x86 Itanium)
property :domain_username, String
property :domain_password, String, sensitive: true

action :install do
  environment = printer_environment(new_resource.environment)
  current = print_state(:driver, new_resource.driver_name, environment)
  validate_driver_type!(current) if current
  unless current
    if new_resource.inf_path || new_resource.inf_file
      raise ArgumentError, 'inf_path and inf_file must be provided together' unless new_resource.inf_path && new_resource.inf_file

      inf = "#{new_resource.inf_path}\\#{new_resource.inf_file}"
      powershell_script "Stage printer driver #{new_resource.driver_name}" do
        code <<~POWERSHELL
          $ErrorActionPreference = 'Stop'
          & pnputil.exe /add-driver #{ps_literal(inf)}
          if ($LASTEXITCODE -notin @(0, 3010)) { throw "pnputil failed with exit code $LASTEXITCODE" }
        POWERSHELL
      end
    end

    expected_type = driver_type
    selection = print_selection(:driver, new_resource.driver_name, environment)
    powershell_script "Install printer driver #{new_resource.driver_name}" do
      code <<~POWERSHELL
        $ErrorActionPreference = 'Stop'
        Add-PrinterDriver -Name #{ps_literal(new_resource.driver_name)} -PrinterEnvironment #{ps_literal(environment)} -ErrorAction Stop
        $driver = #{selection}
        if ($null -eq $driver -or $driver.MajorVersion -ne #{expected_type}) { throw 'Installed printer driver does not match the requested driver type' }
      POWERSHELL
    end
  end
end

action :delete do
  environment = printer_environment(new_resource.environment)
  current = print_state(:driver, new_resource.driver_name, environment)
  if current
    validate_driver_type!(current)
    powershell_script "Delete printer driver #{new_resource.driver_name}" do
      code mutate_print_object(:driver, new_resource.driver_name, 'Remove-PrinterDriver', environment)
    end
  end
end

action_class do
  include WindowsPrintCookbook::Helpers

  def driver_type
    new_resource.version == 'Type 2 - Kernel Mode' ? 2 : 3
  end

  def validate_driver_type!(current)
    return if current['MajorVersion'].to_i == driver_type

    raise "Driver #{new_resource.driver_name} has type #{current['MajorVersion']}; requested #{new_resource.version}"
  end
end
