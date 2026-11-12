# frozen_string_literal: true

describe windows_feature('Print-LPD-Service', :powershell) do
  it { should be_installed }
end
