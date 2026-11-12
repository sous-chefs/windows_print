# frozen_string_literal: true

provides :windows_print_install
unified_mode true

property :role, Symbol, default: :server, equal_to: %i(server internet_printing lpd_service distributed_scan_server)
property :source, String
property :timeout, Integer, default: 1800
property :management_tools, [true, false], default: true

action :install do
  if scan_available?
    windows_feature "Install Windows printing #{new_resource.role}" do
      feature_name printing_features(new_resource.role)
      source new_resource.source if new_resource.source
      timeout new_resource.timeout
      action :install
    end

    if new_resource.role == :server && new_resource.management_tools
      windows_feature 'Printing-AdminTools-Collection' do
        timeout new_resource.timeout
        action :install
        only_if do
          registry_data_exists?('HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion', name: 'InstallationType', type: :string, data: 'Server')
        end
      end
    end
  end
end

action :remove do
  unless new_resource.role == :distributed_scan_server && !legacy_scan_platform?
    windows_feature "Remove Windows printing #{new_resource.role}" do
      feature_name printing_role_feature(new_resource.role)
      timeout new_resource.timeout
      action :remove
    end
    if new_resource.role == :server && new_resource.management_tools
      windows_feature 'Printing-AdminTools-Collection' do
        timeout new_resource.timeout
        action :remove
        only_if do
          registry_data_exists?('HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion', name: 'InstallationType', type: :string, data: 'Server')
        end
      end
    end
  end
end

action_class do
  include WindowsPrintCookbook::Features
end
