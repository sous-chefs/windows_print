# frozen_string_literal: true

# Record arguments in a native executable. None of these strings is evaluated.
helper = Object.new.extend(WindowsPrintCookbook::Helpers)
probe_dir = ::File.join(Chef::Config[:file_cache_path], 'native-arguments')
probe_exe = ::File.join(probe_dir, 'Arguments.exe').tr('/', '\\')
probe_output = ::File.join(probe_dir, 'arguments.txt').tr('/', '\\')
probe_marker = ::File.join(probe_dir, 'verified')
values = ['one&two', 'one|two', '%LITERAL_ENV%', 'two words', 'say "hello"', "O'Brien", 'trailing\\', '$(literal)', '']
expected = values.map { |value| helper.ps_literal([value].pack('m0')) }.join(', ')

directory probe_dir do
  recursive true
end

powershell_script 'Verify literal native argument transport' do
  code <<~POWERSHELL
    $ErrorActionPreference = 'Stop'
    $source = @'
    using System;
    using System.IO;
    using System.Text;
    public class Arguments {
      public static void Main(string[] args) {
        string[] encoded = new string[args.Length - 1];
        for (int i = 1; i < args.Length; i++) {
          encoded[i - 1] = Convert.ToBase64String(Encoding.UTF8.GetBytes(args[i]));
        }
        File.WriteAllLines(args[0], encoded);
      }
    }
    '@
    if (-not (Test-Path -LiteralPath #{helper.ps_literal(probe_exe)})) {
      Add-Type -TypeDefinition $source -OutputAssembly #{helper.ps_literal(probe_exe)} -OutputType ConsoleApplication
    }
    #{helper.native_powershell(probe_exe, [probe_output] + values)}
    $actual = @(Get-Content -LiteralPath #{helper.ps_literal(probe_output)})
    $expected = @(#{expected})
    if ($actual.Count -ne $expected.Count) { throw 'Native argument count changed' }
    for ($i = 0; $i -lt $expected.Count; $i++) {
      if ($actual[$i] -cne $expected[$i]) { throw "Native argument $i changed" }
    }
    Write-Output 'Native arguments preserved exactly, including shell metacharacters'
    Set-Content -LiteralPath #{helper.ps_literal(probe_marker)} -Value 'Verified'
  POWERSHELL
  not_if { ::File.exist?(probe_marker) }
end
