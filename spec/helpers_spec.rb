# frozen_string_literal: true

require 'spec_helper'
require_relative '../libraries/helpers'
require 'tmpdir'

describe WindowsPrintCookbook::Helpers do
  subject(:helper) { Object.new.extend(described_class) }

  it 'quotes apostrophes while leaving PowerShell expressions literal' do
    expect(helper.ps_literal("Office O'Brien $(whoami); *")).to eq "'Office O''Brien $(whoami); *'"
  end

  it 'selects literal names instead of wildcard or substring matches' do
    expect(helper.print_selection(:printer, 'Office [1]*')).to include("$_.Name -eq 'Office [1]*'")
    expect(helper.print_selection(:printer, 'Office [1]*')).not_to include('-like')
  end

  it 'passes the exact object explicitly when deleting names containing wildcards' do
    script = helper.mutate_print_object(:printer, 'Office [1]*', 'Remove-Printer')
    expect(script).to include("$_.Name -eq 'Office [1]*'", 'Remove-Printer -InputObject $target')
    expect(script).not_to include('$target | Remove-Printer')
  end

  it 'selects ports from the explicit local server before deleting their object' do
    script = helper.mutate_print_object(:port, 'Office [1]', 'Remove-PrinterPort')
    expect(script).to include('Get-PrinterPort -ComputerName $env:COMPUTERNAME -ErrorAction Stop', 'Remove-PrinterPort -InputObject $target')
  end

  it 'rejects invalid PowerShell string input' do
    expect { helper.ps_literal("bad\0name") }.to raise_error(ArgumentError)
  end

  it 'preserves a missing object separately from a query failure' do
    allow(helper).to receive(:powershell_out!).and_return(double(stdout: 'null'))
    expect(helper.print_state(:printer, 'absent')).to be_nil
    allow(helper).to receive(:powershell_out!).and_raise(RuntimeError, 'access denied')
    expect { helper.print_state(:printer, 'absent') }.to raise_error('access denied')
  end

  it 'parses printer state without matching text output' do
    allow(helper).to receive(:powershell_out!).and_return(double(stdout: '{"Name":"Office","Shared":false,"PortName":"IP_1"}'))
    expect(helper.print_state(:printer, 'Office')).to include('Shared' => false, 'PortName' => 'IP_1')
  end

  it 'rejects ambiguous results instead of modifying several objects' do
    allow(helper).to receive(:powershell_out!).and_return(double(stdout: '[{"Name":"Office"},{"Name":"Office"}]'))
    expect { helper.print_state(:printer, 'Office') }.to raise_error(/more than one/)
  end

  it 'quotes native arguments containing shell metacharacters and empty values' do
    expect(helper.windows_arguments(['one&two', 'one|two', '%LITERAL_ENV%', '', 'two words'])).to eq '"one&two" "one|two" "%LITERAL_ENV%" "" "two words"'
  end

  it 'keeps simple syntax tokens bare for the PrintUI parser' do
    expect(helper.windows_arguments(['printui.dll,PrintUIEntry', '/Ss', '/q', 'd', 'u', 'g'])).to eq 'printui.dll,PrintUIEntry /Ss /q d u g'
    expect(helper.windows_arguments(['a>b', 'a<b', 'a^b', 'a;b', 'a$b'])).to eq '"a>b" "a<b" "a^b" "a;b" "a$b"'
  end

  it 'preserves quotes and trailing backslashes under Windows argument parsing' do
    expect(helper.windows_arguments(['say "hello"'])).to eq '"say \"hello\""'
    expect(helper.windows_arguments(['trailing\\'])).to eq('"trailing' + ('\\' * 2) + '"')
  end

  it 'invokes a native process without passing values through cmd.exe' do
    script = helper.native_powershell('C:\\Windows\\System32\\cscript.exe', ["O'Brien&%NAME%|value"])
    expect(script).to include('Start-Process -FilePath', "'\"O''Brien&%NAME%|value\"'", '$process.ExitCode -notin @(0)')
    expect(script).not_to include('cmd.exe', 'Invoke-Expression')
  end

  it 'uses Script Host quoting without doubling literal trailing backslashes' do
    expect(helper.script_host_arguments(['one&two', '%LITERAL_ENV%', 'trailing\\'])).to eq '"one&two" "%LITERAL_ENV%" "trailing\\"'
    expect { helper.script_host_arguments(['say "hello"']) }.to raise_error(ArgumentError, /double quotes/)
    expect { helper.script_host_arguments(["bad\0name"]) }.to raise_error(ArgumentError, /NUL/)
  end

  it 'preserves an existing backup when a fresh export is missing or empty' do
    Dir.mktmpdir('print-backup') do |dir|
      destination = File.join(dir, 'backup.bin')
      staged = File.join(dir, 'fresh.tmp')
      File.write(destination, 'previous backup')
      expect { helper.commit_backup!(staged, destination) }.to raise_error(/non-empty backup/)
      File.write(staged, '')
      expect { helper.commit_backup!(staged, destination) }.to raise_error(/non-empty backup/)
      expect(File.read(destination)).to eq 'previous backup'
    end
  end

  it 'replaces the destination only after validating a fresh export' do
    Dir.mktmpdir('print-backup') do |dir|
      destination = File.join(dir, 'backup.bin')
      staged = File.join(dir, 'fresh.tmp')
      File.write(destination, 'previous backup')
      File.write(staged, 'fresh backup')
      helper.commit_backup!(staged, destination)
      expect(File.read(destination)).to eq 'fresh backup'
      expect(File.exist?(staged)).to be false
    end
  end
end
