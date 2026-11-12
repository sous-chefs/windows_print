# frozen_string_literal: true

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
provides :windows_print_printer_settings

property :printer_name, String, name_property: true
property :path, String, required: true
property :file, String, required: true
property :domain_username, String
property :domain_password, String, sensitive: true

default_action :restore

action :restore do
  settings = ::File.join(new_resource.path, new_resource.file)
  raise "Printer settings file #{settings} does not exist" unless ::File.file?(settings)
  raise "Printer #{new_resource.printer_name} does not exist" unless print_state(:printer, new_resource.printer_name)

  invocation = native_powershell(windows_executable('rundll32.exe'), ['printui.dll,PrintUIEntry', '/Sr', '/n', new_resource.printer_name, '/a', settings.tr('/', '\\'), '/q', 'd', 'u', 'g', 'r'])
  powershell_script "Restore printer settings #{new_resource.printer_name}" do
    code invocation
  end
end

action :create do
  raise "Printer #{new_resource.printer_name} does not exist" unless print_state(:printer, new_resource.printer_name)

  directory new_resource.path do
    recursive true
  end

  settings = ::File.join(new_resource.path, new_resource.file)
  staged = ::File.join(::File.dirname(settings), ".#{::File.basename(settings)}.#{SecureRandom.hex(8)}.tmp")
  finalize = method(:commit_backup!)
  begin
    invocation = native_powershell(windows_executable('rundll32.exe'), ['printui.dll,PrintUIEntry', '/Ss', '/n', new_resource.printer_name, '/a', staged.tr('/', '\\'), '/q', 'd', 'u', 'g'])
    powershell_script "Back up printer settings #{new_resource.printer_name}" do
      code invocation
    end

    ruby_block "Verify printer settings backup #{new_resource.printer_name}" do
      block { finalize.call(staged, settings) }
    end
  ensure
    ::File.delete(staged) if ::File.exist?(staged)
  end
end

action :delete do
  file ::File.join(new_resource.path, new_resource.file) do
    action :delete
  end
end

action_class do
  include WindowsPrintCookbook::Helpers
end
