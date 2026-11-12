# frozen_string_literal: true

module WindowsPrintCookbook
  module Features
    FEATURES = {
      server: %w(Printing-Server-Foundation-Features Printing-Server-Role ServerManager-Core-RSAT ServerManager-Core-RSAT-Role-Tools),
      internet_printing: %w(NetFx4Extended-ASPNET45 IIS-WebServerRole IIS-WebServer IIS-CommonHttpFeatures IIS-StaticContent IIS-DefaultDocument IIS-DirectoryBrowsing IIS-HttpErrors IIS-HttpRedirect IIS-ApplicationDevelopment IIS-NetFxExtensibility45 IIS-ISAPIExtensions IIS-ASP IIS-ISAPIFilter IIS-HealthAndDiagnostics IIS-HttpLogging IIS-LoggingLibraries IIS-RequestMonitor IIS-HttpTracing IIS-Security IIS-BasicAuthentication IIS-WindowsAuthentication IIS-RequestFiltering IIS-Performance IIS-HttpCompressionStatic IIS-WebServerManagementTools IIS-ManagementConsole IIS-IIS6ManagementCompatibility IIS-Metabase Printing-Server-Foundation-Features Printing-Server-Role Printing-InternetPrinting-Server),
      lpd_service: %w(Printing-Server-Foundation-Features Printing-Server-Role Printing-LPDPrintService),
      distributed_scan_server: %w(Printing-Server-Foundation-Features FSRM-Infrastructure-Services BusScan-ScanServer),
    }.freeze

    def printing_features(role)
      FEATURES.fetch(role)
    end

    def printing_role_feature(role)
      { server: 'Printing-Server-Role', internet_printing: 'Printing-InternetPrinting-Server', lpd_service: 'Printing-LPDPrintService', distributed_scan_server: 'BusScan-ScanServer' }.fetch(role)
    end

    def legacy_scan_platform?
      Gem::Version.new(node['os_version']) < Gem::Version.new('10.0.17763')
    end

    def scan_available?
      return true unless new_resource.role == :distributed_scan_server
      return false unless legacy_scan_platform?

      JSON.parse(powershell_out!("$ErrorActionPreference = 'Stop'; (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).PartOfDomain | ConvertTo-Json -Compress").stdout.strip)
    end
  end
end
