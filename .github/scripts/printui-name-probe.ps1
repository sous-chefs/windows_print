$ErrorActionPreference = 'Stop'
$name = 'Kitchen "quoted" & %LITERAL_ENV%'
$port = 'Kitchen quote probe'
$directory = Join-Path $env:RUNNER_TEMP 'printui-name-probe'
New-Item -ItemType Directory -Path $directory -Force | Out-Null
if (-not (Get-PrinterDriver | Where-Object Name -eq 'Generic / Text Only')) {
  Add-PrinterDriver -Name 'Generic / Text Only'
}
Add-PrinterPort -Name $port -PrinterHostAddress '192.0.2.30'
try {
  Add-Printer -Name $name -PortName $port -DriverName 'Generic / Text Only'
  Get-Printer | Where-Object Name -eq $name | Format-List Name, DriverName, PortName
  $cases = @(
    @{ Name = 'windows-escaping'; Argument = '"Kitchen \"quoted\" & %LITERAL_ENV%"' },
    @{ Name = 'doubled-quotes'; Argument = '"Kitchen ""quoted"" & %LITERAL_ENV%"' }
  )
  foreach ($case in $cases) {
    Set-PrintConfiguration -PrinterName $name -PaperSize Letter
    $output = Join-Path $directory ($case.Name + '.bin')
    $arguments = 'printui.dll,PrintUIEntry /Ss /n ' + $case.Argument + ' /a "' + $output + '" /q d u g'
    Write-Output "Printer name diagnostic $($case.Name): $arguments"
    $process = Start-Process -FilePath "$env:SystemRoot\System32\rundll32.exe" -ArgumentList $arguments -NoNewWindow -PassThru
    if (-not $process.WaitForExit(15000)) {
      $process.Kill()
      Write-Output 'Name probe export did not exit within 15 seconds'
      continue
    }
    if (Test-Path -LiteralPath $output) {
      Get-Item -LiteralPath $output | Select-Object Name, Length
      Set-PrintConfiguration -PrinterName $name -PaperSize A4
      if ((Get-PrintConfiguration -PrinterName $name).PaperSize -ne 'A4') {
        throw 'The quoted-name probe did not change to A4 before restore'
      }
      $arguments = 'printui.dll,PrintUIEntry /Sr /n ' + $case.Argument + ' /a "' + $output + '" /q d u g r'
      $process = Start-Process -FilePath "$env:SystemRoot\System32\rundll32.exe" -ArgumentList $arguments -NoNewWindow -PassThru
      if (-not $process.WaitForExit(15000)) {
        $process.Kill()
        Write-Output 'Name probe restore did not exit within 15 seconds'
        continue
      }
      Write-Output "Restored paper: $((Get-PrintConfiguration -PrinterName $name).PaperSize)"
    } else {
      Write-Output 'No export file created for the exact quoted printer name'
    }
  }
} finally {
  Get-Printer | Where-Object Name -eq $name | Remove-Printer
  Get-PrinterPort | Where-Object Name -eq $port | Remove-PrinterPort
}
