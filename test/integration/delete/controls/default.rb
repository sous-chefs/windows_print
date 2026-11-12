# frozen_string_literal: true

[
  "Get-Printer | Where-Object Name -eq 'Kitchen Office [1] & %LITERAL_ENV%'",
  "Get-PrinterPort | Where-Object Name -eq 'Kitchen TCP [1]'",
  "Get-PrinterDriver | Where-Object Name -eq 'Generic / Text Only'",
].each do |query|
  describe powershell("@(#{query}).Count") do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq '0' }
  end
end

describe service('Spooler') do
  it { should be_running }
end
