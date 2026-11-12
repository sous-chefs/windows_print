# frozen_string_literal: true

queue_name = 'Kitchen Office [1] "quoted" & %LITERAL_ENV%'
sibling_name = 'Kitchen Office 1 "quoted" & %LITERAL_ENV%'

{
  "(Get-Printer | Where-Object Name -eq '#{queue_name}').Location" => 'Updated room',
  "(Get-Printer | Where-Object Name -eq '#{queue_name}').Comment" => 'Updated comment',
  "(Get-Printer | Where-Object Name -eq '#{queue_name}').Shared" => 'False',
  "(Get-Printer | Where-Object Name -eq '#{sibling_name}').Comment" => 'Keep this sibling unchanged',
  "(Get-Printer | Where-Object Name -eq '#{sibling_name}').Location" => 'Sibling room',
  "(Get-PrinterPort | Where-Object Name -eq 'Kitchen TCP [1]').PrinterHostAddress" => '192.0.2.20',
}.each do |query, expected|
  describe powershell(query) do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq expected }
  end
end
