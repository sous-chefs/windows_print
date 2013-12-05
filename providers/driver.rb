#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook Name:: windows_print
# Provider:: driver
#
# Copyright 2013, Texas A&M
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
require 'mixlib/shellout'

action :create do
  if driver_exists?
    Chef::Log.info("#{new_resource.driver_name} already installed - nothing to do.")
    new_resource.updated_by_last_action(false)
  else
    windows_batch "Create Local Cache" do
      code "xcopy \"#{new_resource.inf_path}\" \"C:\\chef\\cache\\#{new_resource.driver_name}\" /Y /S /I"
    end
    windows_batch "Creating print driver: #{new_resource.driver_name}" do
      code "rundll32 printui.dll PrintUIEntry /ia /m \"#{new_resource.driver_name}\" /h \"#{ new_resource.environment}\" /v \"#{new_resource.version}\" /f \"C:\\chef\\cache\\#{new_resource.driver_name}\\#{new_resource.inf_file}\""
    end

    Chef::Log.info("#{ new_resource.driver_name } installed.")
    new_resource.updated_by_last_action(true)
    
    windows_batch "Cleanup" do
      code "rmdir \"C:\\chef\\cache\\#{new_resource.driver_name}\" /S /Q"
    end
  end
end

action :delete do
  if exists?
    windows_batch "Deleting print driver: #{new_resource.driver_name}" do
      code "rundll32 printui.dll PrintUIEntry /dd /m \"#{new_resource.driver_name}\" /h \"#{new_resource.environment}\" /v \"#{new_resource.version}\""
    end

    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("#{ new_resource.driver_name } doesn't exist - can't delete.")
    new_resource.updated_by_last_action(false)
  end
end
  
def driver_exists?
  case new_resource.environment
  when "x64"
    check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_PrinterDriver -EnableAllPrivileges | where {$_.name -like '#{new_resource.driver_name},3,Windows x64'} | fl name\"").run_command
    Chef::Log.info("\"#{new_resource.driver_name}\" x64 driver found.")
  when "x86"
    check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_PrinterDriver -EnableAllPrivileges | where {$_.name -like '#{new_resource.driver_name},3,Windows NT x86'} | fl name\"").run_command
    Chef::Log.info("\"#{new_resource.driver_name}\" x86 driver found.")
  when "Itanium"
    check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_PrinterDriver -EnableAllPrivileges | where {$_.name -like '#{new_resource.driver_name},3,Itanium'} | fl name\"").run_command
    Chef::Log.info("\"#{new_resource.driver_name}\" xItanium driver found.")
  else
    Chef::Log.info("Please use \"x64\", \"x86\" or \"Itanium\" as the environment type")
  end
  check.stdout.include? new_resource.driver_name
end

# Attempt to prevent typos in new_resource.name
def driver_name
  case new_resource.environment
  when "x64"
    File.readlines("#{new_resource.inf_path}").grep(/NTamd64/)
    #Grab Next line String Between " and " and make that new_resource.name
  when "x86"
    File.readlines("#{new_resource.inf_path}").grep(/NTx86/)
    #Grab Next line String Between " and " and make that new_resource.name
  when "Itanium"
    File.readlines("#{new_resource.inf_path}").grep(/NTx86/)
    #Grab Next line String Between " and " and make that new_resource.name
  else
    Chef::Log.info("Please use \"x64\", \"x86\" or \"Itanium\" as the environment type")
  end
  
end