#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook Name:: windows_print
# Provider:: printer_settings
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

action :restore do
  execute "Sanitize Network Drives" do
    command "net use * /d /y"
	new_resource.updated_by_last_action(true)
  end

  if printer_exists?
    execute "Map Network Drive" do
      command "net use z: \"#{new_resource.path}\" /user:\"#{new_resource.domain_username}\" \"#{new_resource.domain_password}\""
    end
	  if file_exists?
	    Chef::Log.info("\"#{new_resource.file}\" does not exist - skipping.")
	  else
        execute '#{new_resource.printer_name}' do
          #not_if { File.exists?("#{new_resource.path}\\#{new_resource.file}") }
		  command "RUNDLL32 PRINTUI.DLL,PrintUIEntry /Sr /n \"#{new_resource.printer_name}\" /a \"#{new_resource.path}\\#{new_resource.file}\" d u g 8 r"
		end
      end
	execute "Unmap Network Drive" do
      command "net use z: /d"
    end
  else
    Chef::Log.info("\"#{new_resource.printer_name}\" printer not found - unable to restore settings.")
  end
end

action :create do
  execute "Sanitize Network Drives" do
    command "net use * /d /y"
	new_resource.updated_by_last_action(true)
  end

  if printer_exists?
    execute "Map Network Drive" do
      command "net use z: \"#{new_resource.path}\" /user:\"#{new_resource.domain_username}\" \"#{new_resource.domain_password}\""
    end

    execute "new_resource.printer_name" do
      command "RUNDLL32 PRINTUI.DLL,PrintUIEntry /Ss /n \"#{new_resource.printer_name}\" /a \"c:\\chef\\cache\\#{new_resource.file}\" d u g 8"
    end
  
    execute "Upload file" do
      command "move \"c:\\chef\\cache\\#{new_resource.file}\" \"z:\\\""
    end

    execute "Unmap Network Drive" do
      command "net use z: /d"
    end
  else
    Chef::Log.info("\"#{new_resource.printer_name}\" printer not found - unable to create settings.")
  end
end

def printer_exists?
  check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_Printer -EnableAllPrivileges | where {$_.name -like '#{new_resource.printer_name}'} | fl name\"").run_command
  check.stdout.include? new_resource.printer_name
end

def file_exists?
   powershell_script "check file" do
     code "Test-Path \"#{new_resource.path}\\#{new_resource.file}\""
   end
end