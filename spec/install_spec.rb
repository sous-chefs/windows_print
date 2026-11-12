# frozen_string_literal: true

require 'spec_helper'

describe 'windows_print_install' do
  step_into :windows_print_install
  platform 'windows', '2019'

  %i(server internet_printing lpd_service).each do |selected_role|
    context selected_role.to_s do
      recipe do
        windows_print_install 'printing' do
          role selected_role
          management_tools false
        end
      end

      it 'installs the existing role and its prerequisites through the native resource' do
        expect(chef_run).to install_windows_feature("Install Windows printing #{selected_role}")
      end
    end
  end

  context 'removing Internet Printing' do
    recipe do
      windows_print_install 'printing' do
        role :internet_printing
        action :remove
      end
    end

    it 'removes the print role while preserving shared IIS dependencies' do
      expect(chef_run).to remove_windows_feature('Remove Windows printing internet_printing').with(feature_name: 'Printing-InternetPrinting-Server')
    end
  end

  context 'Distributed Scan on Server 2019 or later' do
    recipe do
      windows_print_install 'scan' do
        role :distributed_scan_server
      end
    end

    it 'preserves the legacy unavailable-platform no-op' do
      expect(chef_run.resource_collection.select { |r| r.resource_name == :windows_feature }).to be_empty
    end
  end

  context 'Distributed Scan on Server 2016' do
    platform 'windows', '2016'
    let(:domain_member) { false }

    before do
      allow_any_instance_of(Chef::Provider).to receive(:powershell_out!).and_return(double(stdout: domain_member.to_json))
    end

    recipe do
      windows_print_install 'scan' do
        role :distributed_scan_server
      end
    end

    it 'does not install on a standalone machine' do
      expect(chef_run.resource_collection.select { |r| r.resource_name == :windows_feature }).to be_empty
    end

    context 'with domain membership' do
      let(:domain_member) { true }

      it 'installs the scanner role' do
        expect(chef_run).to install_windows_feature('Install Windows printing distributed_scan_server')
      end
    end
  end
end
