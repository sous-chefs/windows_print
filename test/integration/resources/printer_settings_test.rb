# InSpec test for recipe test_windows_print::create_printer_settings_data_bag

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('C:\\chef\cache\\HP-LaserJet-9050.bin') do
  it { should exist }
end
