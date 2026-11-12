# frozen_string_literal: true

require 'json'
require 'securerandom'

module WindowsPrintCookbook
  module Helpers
    COMMANDS = { printer: 'Get-Printer', port: 'Get-PrinterPort', driver: 'Get-PrinterDriver' }.freeze
    FIELDS = {
      printer: %w(Name DriverName PortName Comment Location Shared ShareName),
      port: %w(Name PrinterHostAddress),
      driver: %w(Name PrinterEnvironment MajorVersion),
    }.freeze

    def ps_literal(value)
      raise ArgumentError, 'PowerShell values cannot contain NUL bytes' if value.to_s.include?("\0")

      "'#{value.to_s.gsub("'", "''")}'"
    end

    def print_selection(kind, name, environment = nil, local_server: false)
      filter = "$_.Name -eq #{ps_literal(name)}"
      filter += " -and $_.PrinterEnvironment -eq #{ps_literal(environment)}" if environment
      server = local_server ? ' -ComputerName $env:COMPUTERNAME' : ''
      "#{COMMANDS.fetch(kind)}#{server} -ErrorAction Stop | Where-Object { #{filter} }"
    end

    def print_state(kind, name, environment = nil)
      result = powershell_out!("$ErrorActionPreference = 'Stop'; #{print_selection(kind, name, environment)} | Select-Object #{FIELDS.fetch(kind).join(',')} | ConvertTo-Json -Compress").stdout.strip
      return if result.empty? || result == 'null'

      state = JSON.parse(result)
      if state.is_a?(Array)
        raise "Printer query returned more than one #{kind} named #{name}" if state.length > 1

        state.first
      else
        state
      end
    end

    def printer_environment(environment)
      { 'x64' => 'Windows x64', 'x86' => 'Windows NT x86', 'Itanium' => 'Windows IA64' }.fetch(environment)
    end

    def printer_admin_script(name)
      root = ENV.fetch('SystemRoot', 'C:/Windows').tr('\\', '/')
      script = Dir.glob("#{root}/System32/Printing_Admin_Scripts/*/#{name}").min
      raise "Windows printing administration script #{name} is unavailable" unless script

      script
    end

    # Start-Process accepts one Windows command-line string. PrintUI requires its
    # syntax tokens bare. Quote all other values using Windows argument rules,
    # then keep the complete command line literal in PowerShell (never cmd.exe).
    def windows_arguments(arguments)
      arguments.map do |value|
        argument = value.to_s
        raise ArgumentError, 'Native arguments cannot contain NUL bytes' if argument.include?("\0")
        next argument if argument.match?(%r{\A[a-zA-Z0-9_.,:/-]+\z})

        escaped = argument.gsub(/(\\*)"/) { "#{Regexp.last_match(1) * 2}\\\"" }
        trailing = escaped[/\\+\z/]
        escaped += trailing if trailing
        "\"#{escaped}\""
      end.join(' ')
    end

    def windows_executable(name)
      "#{ENV.fetch('SystemRoot', 'C:/Windows').tr('/', '\\')}\\System32\\#{name}"
    end

    def script_host_arguments(arguments)
      arguments.map do |value|
        argument = value.to_s
        raise ArgumentError, 'Windows Script Host arguments cannot contain NUL bytes or double quotes' if argument.include?("\0") || argument.include?('"')

        argument.match?(%r{\A[a-zA-Z0-9_.,:/-]+\z}) ? argument : "\"#{argument}\""
      end.join(' ')
    end

    def native_powershell(executable, arguments, acceptable_exit_codes: [0], script_host: false)
      command_line = script_host ? script_host_arguments(arguments) : windows_arguments(arguments)
      <<~POWERSHELL
        $ErrorActionPreference = 'Stop'
        $process = Start-Process -FilePath #{ps_literal(executable)} -ArgumentList #{ps_literal(command_line)} -NoNewWindow -Wait -PassThru -ErrorAction Stop
        if ($process.ExitCode -notin @(#{acceptable_exit_codes.map { |code| Integer(code) }.join(', ')})) {
          throw "Native command failed with exit code $($process.ExitCode)"
        }
      POWERSHELL
    end

    def commit_backup!(staged, destination)
      raise "PrintUI did not create a non-empty backup at #{staged}" unless ::File.file?(staged) && ::File.size(staged).positive?

      ::File.rename(staged, destination)
    end

    def mutate_print_object(kind, name, command, environment = nil)
      <<~POWERSHELL
        $ErrorActionPreference = 'Stop'
        $target = #{print_selection(kind, name, environment, local_server: kind == :port)}
        if ($null -ne $target) { #{command} -InputObject $target -ErrorAction Stop }
      POWERSHELL
    end
  end
end
