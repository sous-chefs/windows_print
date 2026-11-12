# frozen_string_literal: true

require 'spec_helper'

describe 'windows_print_driver' do
  step_into :windows_print_driver
  platform 'windows', '2019'

  before do
    allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: '{"Name":"Generic / Text Only","PrinterEnvironment":"Windows x64","MajorVersion":3}'))
  end

  recipe do
    windows_print_driver 'Generic / Text Only' do
      action :delete
    end
  end

  it 'deletes an installed driver without requiring installation media' do
    expect(chef_run).to run_powershell_script('Delete printer driver Generic / Text Only')
    expect(chef_run.powershell_script('Delete printer driver Generic / Text Only').code).to include('Remove-PrinterDriver')
  end

  context 'when the installed driver type differs' do
    before do
      allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: '{"Name":"Generic / Text Only","MajorVersion":4}'))
    end

    it 'does not remove an unintended driver type' do
      expect { chef_run }.to raise_error(/has type 4/)
    end
  end

  context 'installing a missing vendor driver' do
    before do
      allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: 'null'))
    end

    recipe do
      windows_print_driver "Vendor O'Brien" do
        inf_path 'C:/drivers'
        inf_file 'vendor.inf'
      end
    end

    it 'stages the INF and preserves native command failures' do
      expect(chef_run).to run_powershell_script("Stage printer driver Vendor O'Brien")
      expect(chef_run.powershell_script("Stage printer driver Vendor O'Brien").code).to include('pnputil.exe /add-driver', '$LASTEXITCODE -notin @(0, 3010)')
      expect(chef_run.powershell_script("Install printer driver Vendor O'Brien").code).to include("-Name 'Vendor O''Brien'", '$driver.MajorVersion -ne 3')
    end
  end

  context 'when the driver is absent during deletion' do
    before do
      allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: 'null'))
    end

    it 'does not invoke a removal command' do
      expect(chef_run).not_to run_powershell_script('Delete printer driver Generic / Text Only')
    end
  end
end

describe 'windows_print_port' do
  step_into :windows_print_port
  platform 'windows', '2019'
  let(:state) { { 'Name' => 'Office TCP', 'PrinterHostAddress' => '192.0.2.9' } }

  before do
    allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: state.to_json))
    allow(Dir).to receive(:glob).and_call_original
    allow(Dir).to receive(:glob).with('C:/Windows/System32/Printing_Admin_Scripts/*/prnport.vbs').and_return(['C:/Windows/System32/Printing_Admin_Scripts/en-US/prnport.vbs'])
  end

  recipe do
    windows_print_port 'Office TCP' do
      ipv4_address '192.0.2.10'
    end
  end

  it 'updates an existing TCP port without removing its queues' do
    expect(chef_run).to run_powershell_script('Configure printer port Office TCP')
    expect(chef_run.powershell_script('Configure printer port Office TCP').code).to include('-t -r "Office TCP" -h 192.0.2.10')
  end

  context 'when already configured' do
    let(:state) { super().merge('PrinterHostAddress' => '192.0.2.10') }

    it 'does not report an update' do
      expect(chef_run.windows_print_port('Office TCP')).not_to be_updated_by_last_action
    end
  end
end

describe 'windows_print_printer_settings' do
  step_into :windows_print_printer_settings
  platform 'windows', '2019'

  before do
    allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: '{"Name":"Office"}'))
    allow(File).to receive(:file?).and_call_original
    allow(File).to receive(:file?).with('C:/backups/office.bin').and_return(true)
  end

  recipe do
    windows_print_printer_settings 'Office' do
      path 'C:/backups'
      file 'office.bin'
      action :restore
    end
  end

  it 'restores an existing backup and passes arguments separately' do
    expect(chef_run).to run_powershell_script('Restore printer settings Office')
    expect(chef_run.powershell_script('Restore printer settings Office').code).to include('/Sr', '/a', 'C:\\backups\\office.bin', '/q d u g r')
  end

  context 'creating a backup' do
    recipe do
      windows_print_printer_settings 'Office' do
        path 'C:/backups'
        file 'office.bin'
        action :create
      end
    end

    it 'uses native Windows path separators and verifies the backup' do
      expect(chef_run.powershell_script('Back up printer settings Office').code).to include('C:\\backups\\.office.bin.')
      expect(chef_run).to run_ruby_block('Verify printer settings backup Office')
      expect { chef_run.ruby_block('Verify printer settings backup Office').block.call }.to raise_error(/did not create a non-empty backup/)
    end
  end

  context 'when the backup is missing' do
    before { allow(File).to receive(:file?).with('C:/backups/office.bin').and_return(false) }

    it 'fails before invoking restore' do
      expect { chef_run }.to raise_error(/settings file .* does not exist/)
    end
  end

  context 'when the printer is missing' do
    before do
      allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: 'null'))
    end

    it 'fails before invoking restore' do
      expect { chef_run }.to raise_error(/Printer Office does not exist/)
    end
  end
end

describe 'windows_print_printer' do
  step_into :windows_print_printer
  platform 'windows', '2019'

  before do
    allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: state.to_json))
  end

  let(:state) { { 'Name' => 'Office', 'DriverName' => 'Generic / Text Only', 'PortName' => 'Office TCP', 'Shared' => false, 'Comment' => '', 'Location' => '' } }

  recipe do
    windows_print_printer 'Office' do
      driver_name 'Generic / Text Only'
      ports 'Office TCP' => '192.0.2.10'
    end
  end

  it 'leaves an unchanged printer alone without reporting a change' do
    expect(chef_run.windows_print_printer('Office')).not_to be_updated_by_last_action
    expect(chef_run).not_to run_powershell_script('Configure printer Office')
  end

  context 'when configuration has drifted' do
    let(:state) { super().merge('DriverName' => 'Wrong driver') }

    it 'updates the exact printer rather than creating a duplicate' do
      expect(chef_run).to run_powershell_script('Configure printer Office')
      expect(chef_run.powershell_script('Configure printer Office').code).to include("$_.Name -eq 'Office'", 'Set-Printer')
      expect(chef_run.powershell_script('Configure printer Office').code).to include('$target.Shared = $false', 'Set-Printer -InputObject $target')
    end
  end

  context 'with canonical Windows name casing' do
    let(:state) { super().merge('DriverName' => 'GENERIC / TEXT ONLY', 'PortName' => 'OFFICE TCP') }

    it 'does not repeatedly update case-insensitive references' do
      expect(chef_run).not_to run_powershell_script('Configure printer Office')
    end
  end

  context 'when deleting by name' do
    recipe do
      windows_print_printer 'Office' do
        action :delete
      end
    end

    it 'does not require create properties or delete shared dependencies' do
      expect(chef_run).to run_powershell_script('Delete printer Office')
      expect(chef_run.resource_collection.select { |r| r.resource_name == :windows_print_driver || r.resource_name == :windows_print_port }).to be_empty
    end
  end
end
