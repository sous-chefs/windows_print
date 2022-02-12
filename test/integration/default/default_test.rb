# InSpec test for recipe windows_print::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe windows_feature('Printing-Server-Foundation-Features', :dism) do
  it { should be_installed }
end

describe windows_feature('Printing-Server-Role', :dism) do
  it { should be_installed }
end

# Test will fail on Server Core
describe windows_feature('Printing-AdminTools-Collection', :dism) do
  it { should be_installed }
end

describe windows_feature('ServerManager-Core-RSAT', :dism) do
  it { should be_installed }
end

describe windows_feature('ServerManager-Core-RSAT-Role-Tools', :dism) do
  it { should be_installed }
end
