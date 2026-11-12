# frozen_string_literal: true

require 'json'

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

    def print_selection(kind, name, environment = nil)
      filter = "$_.Name -eq #{ps_literal(name)}"
      filter += " -and $_.PrinterEnvironment -eq #{ps_literal(environment)}" if environment
      "#{COMMANDS.fetch(kind)} -ErrorAction Stop | Where-Object { #{filter} }"
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

    def mutate_print_object(kind, name, command, environment = nil)
      <<~POWERSHELL
        $ErrorActionPreference = 'Stop'
        $target = #{print_selection(kind, name, environment)}
        if ($null -ne $target) { $target | #{command} -ErrorAction Stop }
      POWERSHELL
    end
  end
end
