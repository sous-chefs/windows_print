# frozen_string_literal: true

queue_name = 'Kitchen Office [1] "quoted" & %LITERAL_ENV%'
sibling_name = 'Kitchen Office 1 "quoted" & %LITERAL_ENV%'

{
  "(Get-Printer | Where-Object Name -eq '#{queue_name}').DriverName" => 'Generic / Text Only',
  "(Get-Printer | Where-Object Name -eq '#{queue_name}').ShareName" => 'KitchenOffice',
  "(Get-Printer | Where-Object Name -eq '#{queue_name}').Location" => 'Original room',
  "(Get-Printer | Where-Object Name -eq '#{queue_name}').Comment" => "O'Brien $printer; literal text",
  "(Get-Printer | Where-Object Name -eq '#{sibling_name}').Comment" => 'Keep this sibling unchanged',
  "(Get-PrinterPort | Where-Object Name -eq 'Kitchen TCP [1]').PrinterHostAddress" => '192.0.2.10',
  "(Get-PrintConfiguration -PrinterName '#{queue_name}').PaperSize" => 'Letter',
}.each do |query, expected|
  describe powershell(query) do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq expected }
  end
end
