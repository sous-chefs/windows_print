$ErrorActionPreference = 'Continue'
Get-Printer | Where-Object Name -eq 'Kitchen Office [1] & %LITERAL_ENV%' | Format-List Name, DriverName, PortName, Comment, Location, Shared, ShareName
Get-PrintConfiguration -PrinterName 'Kitchen Office [1] & %LITERAL_ENV%' | Format-List PaperSize
$directory = Join-Path $env:RUNNER_TEMP 'printui-diagnostics'
New-Item -ItemType Directory -Path $directory -Force | Out-Null
$cases = @(
  @{ Name = 'quoted'; Prefix = '"printui.dll,PrintUIEntry" "/Ss" "/n" "Kitchen Office [1] & %LITERAL_ENV%" "/a"'; Suffix = '"/q" "d" "u" "g"' },
  @{ Name = 'documented'; Prefix = 'printui.dll,PrintUIEntry /Ss /n "Kitchen Office [1] & %LITERAL_ENV%" /a'; Suffix = '/q d u g' },
  @{ Name = 'global'; Prefix = 'printui.dll,PrintUIEntry /Ss /n "Kitchen Office [1] & %LITERAL_ENV%" /a'; Suffix = '/q d g' },
  @{ Name = 'minimal'; Prefix = 'printui.dll,PrintUIEntry /Ss /n "Kitchen Office [1] & %LITERAL_ENV%" /a'; Suffix = '/q m' },
  @{ Name = 'default'; Prefix = 'printui.dll,PrintUIEntry /Ss /n "Kitchen Office [1] & %LITERAL_ENV%" /a'; Suffix = '/q' }
)
foreach ($case in $cases) {
  $output = Join-Path $directory ($case.Name + '.bin')
  $arguments = $case.Prefix + ' "' + $output + '" ' + $case.Suffix
  Write-Output "PrintUI diagnostic $($case.Name): $arguments"
  $process = Start-Process -FilePath "$env:SystemRoot\System32\rundll32.exe" -ArgumentList $arguments -NoNewWindow -PassThru
  if (-not $process.WaitForExit(15000)) {
    $process.Kill()
    Write-Output 'Export did not exit within 15 seconds'
  } else {
    Write-Output "Exit code: $($process.ExitCode)"
  }
  if (Test-Path -LiteralPath $output) {
    Get-Item -LiteralPath $output | Select-Object Name, Length
  } else {
    Write-Output 'No export file created'
  }
}
