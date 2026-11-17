[CmdletBinding()]
param(
    [string]$DxcapPath = 'C:\Windows\System32\dxcap.exe',
    [string]$ControlDll = 'C:\Windows\System32\version.dll'
)

$ErrorActionPreference = 'Stop'
foreach ($requiredPath in @($DxcapPath, $ControlDll)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required file was not found: $requiredPath"
    }
}

# Native stderr is expected because version.dll intentionally lacks the
# ListExperiments export. Keep PowerShell 7 from promoting it to a terminating
# error while retaining normal error handling for the script itself.
if (Test-Path -LiteralPath Variable:PSNativeCommandUseErrorActionPreference) {
    $PSNativeCommandUseErrorActionPreference = $false
}

$output = & $DxcapPath -measure -expdll $ControlDll -explist 2>&1
$exitCode = $LASTEXITCODE
$text = $output | Out-String
$output | ForEach-Object { Write-Host $_ }

if ($text -notmatch 'does not export\s+the ListExperiments entry point') {
    throw 'Dxcap did not emit the expected post-load ListExperiments diagnostic.'
}

[pscustomobject]@{
    DxcapPath = $DxcapPath
    ControlDll = $ControlDll
    DxcapExitCode = $exitCode
    PostLoadDiagnosticObserved = $true
}
