#
# Cookbook:: windows_print
# Spec:: default
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
        step_into: ['windows_print::default']
      ).converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

RSpec.describe 'windows_print::default' do
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
