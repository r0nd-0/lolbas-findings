[CmdletBinding()]
param(
    [string]$LcPath = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\lc.exe',
    [string]$CscPath = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe'
)

$ErrorActionPreference = 'Stop'
$testRoot = Join-Path $env:TEMP ('lc-messagebox-validation-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null

$assemblyPath = Join-Path $testRoot 'LcMessageBox.dll'
$componentListPath = Join-Path $testRoot 'messagebox.licx'
$sourcePath = Join-Path $PSScriptRoot 'MessageBoxComponent.cs'

Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'messagebox.licx') -Destination $componentListPath
& $CscPath /nologo /target:library "/out:$assemblyPath" $sourcePath
if ($LASTEXITCODE -ne 0) {
    throw "Canary compilation failed with exit code $LASTEXITCODE."
}

& $LcPath `
    /nologo `
    /target:fake.exe `
    "/complist:$componentListPath" `
    "/outdir:$testRoot" `
    "/i:$assemblyPath"

[pscustomobject]@{
    LcExitCode = $LASTEXITCODE
    AssemblyPath = $assemblyPath
    AssemblySignature = [string](Get-AuthenticodeSignature -LiteralPath $assemblyPath).Status
    TestDirectory = $testRoot
}
