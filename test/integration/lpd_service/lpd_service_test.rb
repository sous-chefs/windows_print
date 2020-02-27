# InSpec test for recipe windows_print::lpd_service

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe windows_feature('Printing-Server-Foundation-Features', :dism) do
  it { should be_installed }
end

describe windows_feature('Printing-Server-Role', :dism) do
  it { should be_installed }
end

describe windows_feature('Printing-LPDPrintService', :dism) do
  it { should be_installed }
end
