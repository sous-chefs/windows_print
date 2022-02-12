# InSpec test for recipe windows_print::internet_printing

# The InSpec reference', with examples and extensive documentation', can be
# found at http://inspec.io/docs/reference/resources/

describe windows_feature('NetFx4Extended-ASPNET45', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-WebServerRole', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-WebServer', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-CommonHttpFeatures', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-StaticContent', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-DefaultDocument', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-DirectoryBrowsing', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-HttpErrors', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-HttpRedirect', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-ApplicationDevelopment', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-NetFxExtensibility45', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-ISAPIExtensions', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-ASP', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-ISAPIFilter', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-HealthAndDiagnostics', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-HttpLogging', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-LoggingLibraries', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-RequestMonitor', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-HttpTracing', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-Security', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-BasicAuthentication', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-WindowsAuthentication', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-RequestFiltering', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-Performance', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-HttpCompressionStatic', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-WebServerManagementTools', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-ManagementConsole', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-IIS6ManagementCompatibility', :dism) do
  it { should be_installed }
end

describe windows_feature('IIS-Metabase', :dism) do
  it { should be_installed }
end

describe windows_feature('Printing-Server-Foundation-Features', :dism) do
  it { should be_installed }
end

describe windows_feature('Printing-Server-Role', :dism) do
  it { should be_installed }
end

describe windows_feature('Printing-InternetPrinting-Server', :dism) do
  it { should be_installed }
end
