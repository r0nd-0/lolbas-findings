[CmdletBinding()]
param(
    [string]$XperfPath = 'C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\xperf.exe',
    [string]$TestExecutable = (Join-Path $PSScriptRoot 'test.exe')
)

$ErrorActionPreference = 'Stop'
foreach ($requiredPath in @($XperfPath, $TestExecutable)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required file was not found: $requiredPath"
    }
}

$sessionName = 'XperfMessageBoxValidation_{0}' -f ([guid]::NewGuid().ToString('N'))
$exitCode = $null
try {
    & $XperfPath -start $sessionName -heap -PidNewProcess $TestExecutable -WaitForNewProcess
    $exitCode = $LASTEXITCODE
}
finally {
    if ($exitCode -eq 0) {
        & $XperfPath -stop $sessionName | Out-Null
    }
}

[pscustomobject]@{
    XperfExitCode = $exitCode
    SessionName = $sessionName
    TestExecutable = $TestExecutable
}
