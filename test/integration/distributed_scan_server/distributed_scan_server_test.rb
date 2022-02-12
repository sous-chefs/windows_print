# InSpec test for recipe windows_print::distributed_scan_server

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe windows_feature('Printing-Server-Foundation-Features', :dism) do
  it { should be_installed }
end

describe windows_feature('FSRM-Infrastructure-Services', :dism) do
  it { should be_installed }
end

describe windows_feature('BusScan-ScanServer', :dism) do
  it { should be_installed }
end
