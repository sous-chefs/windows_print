# frozen_string_literal: true

queue_name = 'Kitchen Office [1] "quoted" & %LITERAL_ENV%'
sibling_name = 'Kitchen Office 1 "quoted" & %LITERAL_ENV%'
marker = ::File.join(Chef::Config[:file_cache_path], 'printer-backup', 'sibling-verified')

windows_print_printer queue_name do
  action :delete
end

powershell_script 'Verify exact deletion preserves the sibling queue' do
  code <<~POWERSHELL
    $ErrorActionPreference = 'Stop'
    if ($null -ne (Get-Printer | Where-Object Name -eq '#{queue_name}')) { throw 'Target queue still exists' }
    if ($null -eq (Get-Printer | Where-Object Name -eq '#{sibling_name}')) { throw 'Sibling queue was removed' }
    if ($null -eq (Get-PrinterPort | Where-Object Name -eq 'Kitchen TCP [1]')) { throw 'Shared port was removed' }
    if ($null -eq (Get-PrinterDriver | Where-Object Name -eq 'Generic / Text Only')) { throw 'Shared driver was removed' }
  POWERSHELL
  not_if { ::File.exist?(marker) }
end

file marker do
  content 'Exact deletion preserved the sibling queue, shared port and driver'
end

windows_print_printer sibling_name do
  action :delete
end

windows_print_port 'Kitchen TCP [1]' do
  action :delete
end

windows_print_driver 'Generic / Text Only' do
  action :delete
end

windows_print_printer_settings 'backup' do
  path ::File.join(Chef::Config[:file_cache_path], 'printer-backup')
  file 'settings.bin'
  action :delete
end
