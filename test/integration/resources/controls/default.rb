# frozen_string_literal: true

{
  "(Get-Printer | Where-Object Name -eq 'Kitchen Office [1]').DriverName" => 'Generic / Text Only',
  "(Get-Printer | Where-Object Name -eq 'Kitchen Office [1]').ShareName" => 'KitchenOffice',
  "(Get-Printer | Where-Object Name -eq 'Kitchen Office [1]').Location" => 'Original room',
  "(Get-Printer | Where-Object Name -eq 'Kitchen Office [1]').Comment" => "O'Brien $printer; literal text",
  "(Get-PrinterPort | Where-Object Name -eq 'Kitchen TCP [1]').PrinterHostAddress" => '192.0.2.10',
  "(Get-PrintConfiguration -PrinterName 'Kitchen Office [1]').PaperSize" => 'Letter',
}.each do |query, expected|
  describe powershell(query) do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq expected }
  end
end
