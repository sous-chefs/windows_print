#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook:: windows_print
# resource:: port
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

property :port_name, String, name_property: true
property :ipv4_address, String, regex: Resolv::IPv4::Regex
property :ports, Hash

action :create do
  if port_exists?
    Chef::Log.debug("#{new_resource.port_name} already created - nothing to do.")
  else
    converge_by "Create Printer Port #{new_resource.port_name}" do
      powershell_script new_resource.port_name do
        code "Add-PrinterPort -Name \"#{new_resource.port_name}\" -PrinterHostAddress \"#{new_resource.ipv4_address}\""
      end
    end

    Chef::Log.debug("#{new_resource.port_name} created.")
  end
end

action :delete do
  if port_exists?
    converge_by "Remove Printer Port #{new_resource.port_name}" do
      powershell_script new_resource.port_name do
        code "Remove-PrinterPort -Name \"#{new_resource.port_name}\""
      end
    end
  else
    Chef::Log.debug("#{new_resource.port_name} not found - unable to delete.")
  end
end

action_class do
  def port_exists?
    check = powershell_out("Get-wmiobject -Class Win32_TCPIPPrinterPort -EnableAllPrivileges | where {$_.name -like '#{new_resource.port_name}'} | fl name").run_command
    check.stdout.include?(new_resource.port_name)
  end
end
