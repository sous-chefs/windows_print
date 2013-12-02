#
# Author:: Doug Ireton (<doug.ireton@nordstrom.com>)
# Cookbook Name:: windows
# Provider:: printer_port
#
# Copyright:: 2012, Nordstrom, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

action :create do
  if port_exists?
    Chef::Log.info{"#{new_resource.name} already created - nothing to do."}
    new_resource.updated_by_last_action(false)
  else
    powershell "#{new_resource.name}" do
      code "Add-PrinterPort -Name \"#{new_resource.name}\" -PrinterHostAddress \"#{new_resource.ipv4_address}\""
    end
  Chef::Log.info("#{new_resource.name} created.")
  new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if port_exists?
    powershell "#{new_resrouce.name}" do
      code "Remove_PrinterPort -Name \"#{new_resource.name}\""
    end
    new_resrouce.updated_by_last_action(true)
  else
    Chef::Log.info("#{new_resource.name} not found - unable to delete.")
    new_resource.updated_by_last_action(false)
  end
end

def port_exists?
  check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_TCPIPPrinterPort -EnableAllPrivileges | where {$_.name -like '#{new_resource.name}'} | fl name\"").run_command
  check.stdout.include? new_resource.name
end