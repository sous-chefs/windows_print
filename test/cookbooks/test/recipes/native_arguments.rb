# frozen_string_literal: true

# Record arguments in a native executable. None of these strings is evaluated.
helper = Object.new.extend(WindowsPrintCookbook::Helpers)
probe_dir = ::File.join(Chef::Config[:file_cache_path], 'native-arguments')
probe_exe = ::File.join(probe_dir, 'Arguments.exe').tr('/', '\\')
probe_output = ::File.join(probe_dir, 'arguments.txt').tr('/', '\\')
script_path = ::File.join(probe_dir, 'Arguments.vbs').tr('/', '\\')
script_output = ::File.join(probe_dir, 'script-arguments.txt').tr('/', '\\')
probe_marker = ::File.join(probe_dir, 'verified')
values = ['one&two', 'one|two', '%LITERAL_ENV%', 'two words', 'say "hello"', "O'Brien", 'trailing\\', '$(literal)', '']
expected = values.map { |value| helper.ps_literal([value].pack('m0')) }.join(', ')
script_values = values.reject { |value| value.include?('"') }
expected_values = script_values.map { |value| helper.ps_literal(value) }.join(', ')

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
    $scriptSource = @'
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set output = fs.CreateTextFile(WScript.Arguments(0), True, True)
    For i = 1 To WScript.Arguments.Count - 1
      output.WriteLine WScript.Arguments(i)
    Next
    output.Close
    '@
    Set-Content -LiteralPath #{helper.ps_literal(script_path)} -Value $scriptSource -Encoding ASCII
    #{helper.native_powershell(helper.windows_executable('cscript.exe'), ['//B', '//NoLogo', script_path, script_output] + script_values, script_host: true)}
    $actual = @(Get-Content -LiteralPath #{helper.ps_literal(script_output)})
    $expected = @(#{expected_values})
    if ($actual.Count -ne $expected.Count) { throw 'Windows Script Host argument count changed' }
    for ($i = 0; $i -lt $expected.Count; $i++) {
      if ($actual[$i] -cne $expected[$i]) { throw "Windows Script Host argument $i changed" }
    }
    Write-Output 'Native arguments preserved exactly, including shell metacharacters'
    Set-Content -LiteralPath #{helper.ps_literal(probe_marker)} -Value 'Verified'
  POWERSHELL
  not_if { ::File.exist?(probe_marker) }
end
