# frozen_string_literal: true

require 'spec_helper'
require_relative '../libraries/helpers'

describe WindowsPrintCookbook::Helpers do
  subject(:helper) { Object.new.extend(described_class) }

  it 'quotes apostrophes while leaving PowerShell expressions literal' do
    expect(helper.ps_literal("Office O'Brien $(whoami); *")).to eq "'Office O''Brien $(whoami); *'"
  end

  it 'selects literal names instead of wildcard or substring matches' do
    expect(helper.print_selection(:printer, 'Office [1]*')).to include("$_.Name -eq 'Office [1]*'")
    expect(helper.print_selection(:printer, 'Office [1]*')).not_to include('-like')
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
end
