# frozen_string_literal: true

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
provides :windows_print_printer

property :printer_name, String, name_property: true
property :driver_name, String
property :ports, Hash, default: {}
property :port_name, String
property :ipv4_address, String
property :share_name, String, default: ''
property :location, String, default: ''
property :comment, String, default: ''
property :version, String, default: 'Type 3 - User Mode'
property :environment, String, default: 'x64'
property :inf_path, String
property :inf_file, String
property :domain_username, String
property :domain_password, String, sensitive: true

action :create do
  raise ArgumentError, 'driver_name is required to create a printer' unless new_resource.driver_name

  ports = new_resource.ports.dup
  if new_resource.port_name
    raise ArgumentError, 'Use ports or port_name, not both' unless ports.empty?
    ports[new_resource.port_name] = new_resource.ipv4_address
  end
  raise ArgumentError, 'At least one printer port is required' if ports.empty?
  raise ArgumentError, 'Port names cannot contain commas' if ports.keys.any? { |name| name.to_s.include?(',') }

  ports.each do |name, address|
    next unless address

    windows_print_port name do
      ipv4_address address
    end
  end

  windows_print_driver new_resource.driver_name do
    inf_path new_resource.inf_path if new_resource.inf_path
    inf_file new_resource.inf_file if new_resource.inf_file
    environment new_resource.environment
    version new_resource.version
  end

  current = print_state(:printer, new_resource.printer_name)
  desired = {
    'DriverName' => new_resource.driver_name,
    'PortName' => ports.keys.join(','),
    'Comment' => new_resource.comment,
    'Location' => new_resource.location,
    'Shared' => !new_resource.share_name.empty?,
  }
  desired['ShareName'] = new_resource.share_name unless new_resource.share_name.empty?
  changed = !current || desired.any? do |key, value|
    if key == 'PortName'
      current[key].to_s.downcase.split(',').sort != value.downcase.split(',').sort
    elsif key == 'DriverName'
      !current[key].to_s.casecmp?(value)
    else
      current[key] != value && !(value == '' && current[key].nil?)
    end
  end

  if changed
    args = desired.reject { |key, _| key == 'Shared' }.map { |key, value| "-#{key} #{ps_literal(value)}" }.join(' ')
    code = if current
             mutate_print_object(:printer, new_resource.printer_name, "Set-Printer #{args} -Shared:$#{desired['Shared']}")
           else
             shared = desired['Shared'] ? ' -Shared' : ''
             "$ErrorActionPreference = 'Stop'; Add-Printer -Name #{ps_literal(new_resource.printer_name)} #{args}#{shared} -ErrorAction Stop"
           end
    powershell_script "Configure printer #{new_resource.printer_name}" do
      code code
    end
  end
end

action :delete do
  if print_state(:printer, new_resource.printer_name)
    powershell_script "Delete printer #{new_resource.printer_name}" do
      code mutate_print_object(:printer, new_resource.printer_name, 'Remove-Printer')
    end
  end
end

action_class do
  include WindowsPrintCookbook::Helpers
end
