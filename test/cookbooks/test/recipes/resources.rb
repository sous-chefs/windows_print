# frozen_string_literal: true

include_recipe 'test::default'
include_recipe 'test::native_arguments'

queue_name = 'Kitchen Office [1] "quoted" & %LITERAL_ENV%'

windows_print_printer queue_name do
  driver_name 'Generic / Text Only'
  ports 'Kitchen TCP [1]' => '192.0.2.10'
  share_name 'KitchenOffice'
  location 'Original room'
  comment "O'Brien $printer; literal text"
end

windows_print_printer 'Kitchen Office 1 "quoted" & %LITERAL_ENV%' do
  driver_name 'Generic / Text Only'
  ports 'Kitchen TCP [1]' => nil
  location 'Sibling room'
  comment 'Keep this sibling unchanged'
end

backup_dir = ::File.join(Chef::Config[:file_cache_path], 'printer-backup')
marker = ::File.join(backup_dir, 'roundtrip-complete')

directory backup_dir do
  recursive true
end

# A successful fresh export must replace an existing backup on Windows too.
file ::File.join(backup_dir, 'settings.bin') do
  content 'Previous backup: replace only after a fresh export succeeds'
  action :create_if_missing
end

windows_print_printer_settings 'backup' do
  printer_name queue_name
  path backup_dir
  file 'settings.bin'
  action :nothing
end

windows_print_printer_settings 'restore' do
  printer_name queue_name
  path backup_dir
  file 'settings.bin'
  action :nothing
end

powershell_script 'Set baseline printer paper size' do
  code "Set-PrintConfiguration -PrinterName '#{queue_name}' -PaperSize Letter -ErrorAction Stop"
  not_if { ::File.exist?(marker) }
  notifies :create, 'windows_print_printer_settings[backup]', :immediately
end

powershell_script 'Change printer settings before restoring' do
  code <<~POWERSHELL
    $ErrorActionPreference = 'Stop'
    Set-PrintConfiguration -PrinterName '#{queue_name}' -PaperSize A4 -ErrorAction Stop
    if ((Get-PrintConfiguration -PrinterName '#{queue_name}').PaperSize -ne 'A4') {
      throw 'The fixture did not change the paper size before restore'
    }
  POWERSHELL
  not_if { ::File.exist?(marker) }
  notifies :restore, 'windows_print_printer_settings[restore]', :immediately
end

file marker do
  content 'Settings backup and restore completed'
end
