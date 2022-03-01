# InSpec test for recipe test_windows_print::create_printers_data_bag

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe powershell('(Get-PrinterPort -Name HP-LaserJet-9050).Name') do
  its('stdout.chomp') { should eq 'HP-LaserJet-9050' }
end

describe powershell('(Get-PrinterDriver -Name "HP Universal Printing PCL 6 (v7.0.1)").Name') do
  its('stdout.chomp') { should eq 'HP Universal Printing PCL 6 (v7.0.1)' }
end

describe powershell('(Get-Printer -Name HP-LaserJet-9050).name') do
  its('stdout.chomp') { should eq 'HP-LaserJet-9050' }
end
