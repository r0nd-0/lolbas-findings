[CmdletBinding()]
param(
    [string]$LcPath = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\lc.exe',
    [string]$CscPath = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe'
)

$ErrorActionPreference = 'Stop'

foreach ($requiredPath in @($LcPath, $CscPath, (Join-Path $PSScriptRoot 'CanaryComponent.cs'), (Join-Path $PSScriptRoot 'canary.licx'))) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required file was not found: $requiredPath"
    }
}

$testRoot = Join-Path $env:TEMP ('lc-proxy-validation-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null

$assemblyPath = Join-Path $testRoot 'LcCanary.dll'
$componentListPath = Join-Path $testRoot 'canary.licx'
$markerPath = Join-Path $testRoot 'lc-constructor-evidence.txt'
$sourcePath = Join-Path $PSScriptRoot 'CanaryComponent.cs'

Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'canary.licx') -Destination $componentListPath

& $CscPath /nologo /target:library "/out:$assemblyPath" $sourcePath
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $assemblyPath -PathType Leaf)) {
    throw "Canary assembly compilation failed with exit code $LASTEXITCODE."
}

$previousMarkerEnvironment = $env:LOLBAS_LC_MARKER
$lcExitCode = $null
try {
    $env:LOLBAS_LC_MARKER = $markerPath
    & $LcPath `
        /nologo `
        /target:fake.exe `
        "/complist:$componentListPath" `
        "/outdir:$testRoot" `
        "/i:$assemblyPath"
    $lcExitCode = $LASTEXITCODE
}
finally {
    $env:LOLBAS_LC_MARKER = $previousMarkerEnvironment
}

$markerCreated = Test-Path -LiteralPath $markerPath -PathType Leaf
$assemblySignature = Get-AuthenticodeSignature -LiteralPath $assemblyPath

[pscustomobject]@{
    LcPath = $LcPath
    LcExitCode = $lcExitCode
    MarkerCreated = $markerCreated
    MarkerPath = $markerPath
    AssemblyPath = $assemblyPath
    AssemblySignature = [string]$assemblySignature.Status
    TestRoot = $testRoot
}

if (-not $markerCreated) {
    throw 'Lc.exe did not instantiate the component or create the constructor marker.'
}

Get-Content -LiteralPath $markerPath
