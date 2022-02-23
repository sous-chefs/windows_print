#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook:: windows_print
# Resource:: printer_settings
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
property :path, String, required: true
property :file, String, required: true
property :domain_username, String
property :domain_password, String

action :restore do
  converge_by "Restore printer settings for #{new_resource.printer_name}" do
    if printer_exists?
      if file_exists?
        Chef::Log.debug("\"#{new_resource.file}\" does not exist - skipping.")
      else
        execute new_resource.printer_name do
          command "RUNDLL32 PRINTUI.DLL,PrintUIEntry /Sr /n \"#{new_resource.printer_name}\" /a \"#{new_resource.path}\\#{new_resource.file}\" d u g 8 r"
          not_if { ::File.exist?("#{new_resource.path}\\#{new_resource.file}") }
        end
      end
    else
      Chef::Log.debug("\"#{new_resource.printer_name}\" printer not found - unable to restore settings.")
    end
  end
end

action :create do
  converge_by "Create printer settings for #{new_resource.printer_name}" do
    if printer_exists?
      execute "Create #{new_resource.printer_name}.bin" do
        command "RUNDLL32 PRINTUI.DLL,PrintUIEntry /Ss /n \"#{new_resource.printer_name}\" /a \"#{new_resource.path}\\#{new_resource.file}\" d u g 8"
      end
    else
      Chef::Log.debug("\"#{new_resource.printer_name}\" printer not found - unable to create settings.")
    end
  end
end

action_class do
  def printer_exists?
    check = powershell_out("Get-wmiobject -Class Win32_Printer -EnableAllPrivileges | where {$_.name -like '#{new_resource.printer_name}'} | fl name").run_command
    check.stdout.include?(new_resource.printer_name)
  end

  def file_exists?
    ::File.exist?("#{new_resource.path}\\#{new_resource.file}")
  end
end
