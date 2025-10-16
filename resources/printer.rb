#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook:: windows_print
# resource:: printers
#
# Copyright:: 2013, Texas A&M
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

unified_mode true

property :printer_name, String, name_property: true
property :driver_name, String, required: true
property :ports, Hash, required: true
property :port_name, String
property :ipv4_address, String
property :share_name, String
property :location, String
property :comment, String

# Required for driver creation
property :version, String, default: 'Type 3 - User Mode'
property :environment, String, default: 'x64'
property :inf_path, String
property :inf_file, String
property :domain_username, String
property :domain_password, String

action :create do
  converge_by("Creating Printer Port #{new_resource.port_name}, #{new_resource.ipv4_address}") do # Does not report correctly
    new_resource.ports.each do |port_name, ipv4_address|
      windows_print_port port_name do
        ipv4_address ipv4_address
      end
    end
  end

  converge_by("Installing Printer Driver #{new_resource.driver_name}") do
    windows_print_driver new_resource.driver_name do
      inf_path new_resource.inf_path
      inf_file new_resource.inf_file
      domain_username new_resource.domain_username if new_resource.domain_password
      domain_password new_resource.domain_password if new_resource.domain_password
    end
  end

  if printer_exists?
    Chef::Log.debug("\"#{new_resource.printer_name}\" printer already created - nothing to do.")
  else
    if new_resource.ports.keys.count > 1
      port_list = new_resource.ports.keys.join(',').to_s
    else
      port_list = new_resource.ports.keys.to_s
      port_list = port_list.delete! '"[]'
    end

    converge_by("Create Printer #{new_resource.printer_name}") do
      cmd = "Add-Printer -Name \"#{new_resource.printer_name}\" -DriverName \"#{new_resource.driver_name}\" -PortName \"#{port_list}\" -Comment \"#{new_resource.comment}\" -Location \"#{new_resource.location}\""

      if new_resource.share_name == ''
        Chef::Log.debug("\"#{new_resource.printer_name}\" printer will not be shared.")
      else
        cmd << " -Shared -ShareName \"#{new_resource.share_name}\""
        Chef::Log.debug("\"#{new_resource.printer_name}\" shared as \"#{new_resource.share_name}\".")
      end

      powershell_out!(cmd).run_command
    end
  end
end

action :delete do
  if printer_exists?
    converge_by("Deleting Printer #{new_resource.printer_name}") do
      powershell_script new_resource.printer_name do
        code "Remove-Printer -Name \"#{new_resource.printer_name}\""
      end
    end
  else
    Chef::Log.debug("\"#{new_resource.printer_name}\" printer not found - unable to delete.")
  end
end

action_class do
  def printer_exists?
    check = powershell_out("Get-wmiobject -Class Win32_Printer -EnableAllPrivileges | where {$_.name -like '#{new_resource.printer_name}'} | fl name").run_command
    check.stdout.include?(new_resource.printer_name)
  end
end
