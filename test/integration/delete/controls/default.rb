# frozen_string_literal: true

queue_name = 'Kitchen Office [1] "quoted" & %LITERAL_ENV%'
sibling_name = 'Kitchen Office 1 "quoted" & %LITERAL_ENV%'

[
  "Get-Printer | Where-Object Name -eq '#{queue_name}'",
  "Get-Printer | Where-Object Name -eq '#{sibling_name}'",
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

describe powershell("Test-Path -LiteralPath (Join-Path $env:TEMP 'kitchen/cache/printer-backup/settings.bin')") do
  its('exit_status') { should eq 0 }
  its('stdout.strip') { should eq 'False' }
end

describe powershell("Test-Path -LiteralPath (Join-Path $env:TEMP 'kitchen/cache/printer-backup/roundtrip-complete')") do
  its('exit_status') { should eq 0 }
  its('stdout.strip') { should eq 'True' }
end
