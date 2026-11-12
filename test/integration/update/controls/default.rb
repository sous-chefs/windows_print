# frozen_string_literal: true

{
  "(Get-Printer | Where-Object Name -eq 'Kitchen Office [1]').Location" => 'Updated room',
  "(Get-Printer | Where-Object Name -eq 'Kitchen Office [1]').Comment" => 'Updated comment',
  "(Get-Printer | Where-Object Name -eq 'Kitchen Office [1]').Shared" => 'False',
  "(Get-PrinterPort | Where-Object Name -eq 'Kitchen TCP [1]').PrinterHostAddress" => '192.0.2.20',
}.each do |query, expected|
  describe powershell(query) do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq expected }
  end
end
