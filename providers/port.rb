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
  powershell "#{new_resource.name}" do
    code "Add-PrinterPort -Name \"#{new_resource.name}\" -PrinterHostAddress \"#{new_resource.ipv4_address}\""
  end
end

action :delete do
  powershell "#{new_resrouce.name}" do
    code "Remove_PrinterPort -Name \"#{new_resource.name}\""
  end
end