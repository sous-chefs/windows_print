#
# Cookbook:: windows_print
# Recipe:: printer_data_bag
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

directory 'c:\\chef\\cache'

remote_file 'c:\\chef\\cache\\upd-pcl6-x64-7.0.1.24923.zip' do
  source 'https://ftp.ext.hp.com/pub/softlib/software13/COL40842/ds-99374-24/upd-pcl6-x64-7.0.1.24923.exe'
  action :create
end

archive_file 'upd-pcl6-x64-7.0.1.24923.zip' do
  path 'c:\\chef\\cache\\upd-pcl6-x64-7.0.1.24923.zip'
  destination 'c:\\HP Universal Print Driver'
end

printers = data_bag('printers')

Chef::Log.error('Data bag cannot be empty') if printers.empty?

printers.each do |printer|
  printer_info = data_bag_item('printers', printer)

  windows_print_printer(printer) do
    action [:create]
    printer_name printer_info['printer_name']
    share_name printer_info['share_name']
    inf_path printer_info['inf_path']
    inf_file printer_info['inf_file']
    comment printer_info['comment']
    location printer_info['location']
    driver_name printer_info['driver_name']
    ports printer_info['ports']
    environment printer_info['environment']
    domain_username printer_info['domain_username']
    domain_password printer_info['domain_password']
  end
end
