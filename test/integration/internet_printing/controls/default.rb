# frozen_string_literal: true

describe windows_feature('Print-Internet', :powershell) do
  it { should be_installed }
end

describe windows_feature('Web-Server', :powershell) do
  it { should be_installed }
end
