# frozen_string_literal: true

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
provides :windows_print_port

property :port_name, String, name_property: true
property :ipv4_address, String, regex: Resolv::IPv4::Regex

action :create do
  raise ArgumentError, 'ipv4_address is required to create a TCP/IP port' unless new_resource.ipv4_address

  current = print_state(:port, new_resource.port_name)
  if current.nil?
    powershell_script "Create printer port #{new_resource.port_name}" do
      code "$ErrorActionPreference = 'Stop'; Add-PrinterPort -Name #{ps_literal(new_resource.port_name)} -PrinterHostAddress #{ps_literal(new_resource.ipv4_address)} -ErrorAction Stop"
    end
  elsif current['PrinterHostAddress'].to_s.empty?
    raise "Port #{new_resource.port_name} exists but is not a TCP/IP printer port"
  elsif current['PrinterHostAddress'] != new_resource.ipv4_address
    script = printer_admin_script('prnport.vbs')
    invocation = native_powershell(windows_executable('cscript.exe'), ['//B', '//NoLogo', script, '-t', '-r', new_resource.port_name, '-h', new_resource.ipv4_address], script_host: true)
    powershell_script "Configure printer port #{new_resource.port_name}" do
      code invocation
    end
  end
end

action :delete do
  if print_state(:port, new_resource.port_name)
    powershell_script "Delete printer port #{new_resource.port_name}" do
      code mutate_print_object(:port, new_resource.port_name, 'Remove-PrinterPort')
    end
  end
end

action_class do
  include WindowsPrintCookbook::Helpers
end
