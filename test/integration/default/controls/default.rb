# frozen_string_literal: true

describe windows_feature('Print-Server', :powershell) do
  it { should be_installed }
end

describe service('Spooler') do
  it { should be_running }
end
