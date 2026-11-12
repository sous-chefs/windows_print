# frozen_string_literal: true

windows_print_printer 'Kitchen Office [1]' do
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
