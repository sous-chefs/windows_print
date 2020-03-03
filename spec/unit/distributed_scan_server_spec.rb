#
# Cookbook:: windows_print
# Spec:: distributed_scan_server
#
# Copyright:: 2020, The Authors, All Rights Reserved.

require 'spec_helper'

RSpec.shared_examples 'windows_print' do |platform, version|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        os: 'windows',
        platform: platform,
        version: version,
        step_into: ['windows_print::distributed_scan_server']
      ).converge(described_recipe)
    end

    it 'installs windows features' do
      expect(chef_run).to install_windows_feature('Printing-Server-Foundation-Features')
      expect(chef_run).to install_windows_feature('FSRM-Infrastructure-Services')
      expect(chef_run).to install_windows_feature('BusScan-ScanServer')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

RSpec.describe 'windows_print::distributed_scan_server' do
  platforms = {
    'windows' => %w(2012R2 2019),
  }

  platforms.each do |platform, versions|
    versions = versions.is_a?(String) ? [versions] : versions
    versions.each do |version|
      include_examples 'windows_print', platform, version
    end
  end
end
