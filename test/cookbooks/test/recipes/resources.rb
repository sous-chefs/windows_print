# frozen_string_literal: true

include_recipe 'test::default'

windows_print_printer 'Kitchen Office [1]' do
  driver_name 'Generic / Text Only'
  ports 'Kitchen TCP [1]' => '192.0.2.10'
  share_name 'KitchenOffice'
  location 'Original room'
  comment "O'Brien $printer; literal text"
end

backup_dir = ::File.join(Chef::Config[:file_cache_path], 'printer-backup')
marker = ::File.join(backup_dir, 'roundtrip-complete')

windows_print_printer_settings 'backup' do
  printer_name 'Kitchen Office [1]'
  path backup_dir
  file 'settings.bin'
  action :nothing
end

windows_print_printer_settings 'restore' do
  printer_name 'Kitchen Office [1]'
  path backup_dir
  file 'settings.bin'
  action :nothing
end

powershell_script 'Set baseline printer paper size' do
  code "Set-PrintConfiguration -PrinterName 'Kitchen Office [1]' -PaperSize Letter -ErrorAction Stop"
  not_if { ::File.exist?(marker) }
  notifies :create, 'windows_print_printer_settings[backup]', :immediately
end

powershell_script 'Change printer settings before restoring' do
  code "Set-PrintConfiguration -PrinterName 'Kitchen Office [1]' -PaperSize A4 -ErrorAction Stop"
  not_if { ::File.exist?(marker) }
  notifies :restore, 'windows_print_printer_settings[restore]', :immediately
end

file marker do
  content 'Settings backup and restore completed'
end
