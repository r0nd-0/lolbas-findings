[CmdletBinding()]
param(
    [string]$XperfPath,
    [string]$MarkerPath = (Join-Path $env:TEMP 'xperf-proxy-poc.txt')
)

$ErrorActionPreference = 'Stop'

if (-not $XperfPath) {
    $command = Get-Command xperf.exe -ErrorAction SilentlyContinue
    if (-not $command) {
        throw 'xperf.exe was not found. Install the Windows Performance Toolkit or supply -XperfPath.'
    }
    $XperfPath = $command.Source
}

$XperfPath = (Resolve-Path -LiteralPath $XperfPath).Path
$markerDirectory = Split-Path -Parent $MarkerPath
if ($markerDirectory -and -not (Test-Path -LiteralPath $markerDirectory)) {
    New-Item -ItemType Directory -Path $markerDirectory -Force | Out-Null
}

Remove-Item -LiteralPath $MarkerPath -Force -ErrorAction SilentlyContinue

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$sessionName = 'XperfProxyPoc_{0}' -f ([Guid]::NewGuid().ToString('N'))
$childCommand = 'cmd.exe /d /c echo XPERF_PROXY_CONFIRMED>"{0}"' -f $MarkerPath

Write-Host "User:       $($identity.Name)"
Write-Host "Admin:      $isAdmin"
Write-Host "XPerf:      $XperfPath"
Write-Host "Session:    $sessionName"
Write-Host "Marker:     $MarkerPath"

$xperfExitCode = $null
$markerCreated = $false

try {
    # Expected standard-user behavior on the validated build:
    # the child executes, then private ETW session creation fails with 0x80070005.
    & $XperfPath -start $sessionName -heap -PidNewProcess $childCommand -WaitForNewProcess
    $xperfExitCode = $LASTEXITCODE
    Start-Sleep -Milliseconds 300
    $markerCreated = Test-Path -LiteralPath $MarkerPath
}
finally {
    # If run elevated, the session may have started successfully. Stop it.
    if ($xperfExitCode -eq 0) {
        & $XperfPath -stop $sessionName | Out-Null
    }
}

Write-Host "XPerf exit: $xperfExitCode"
Write-Host "Executed:   $markerCreated"

if (-not $markerCreated) {
    throw 'The child-command marker was not created.'
}

Get-Item -LiteralPath $MarkerPath
