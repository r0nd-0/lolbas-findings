[CmdletBinding()]
param(
    [string]$HostPath = 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\Xml\Microsoft.XslDebugger.Host.exe'
)

$ErrorActionPreference = 'Stop'
$inputPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'input.xml')).Path
$stylesheetPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'messagebox.xsl')).Path

& $HostPath $inputPath $stylesheetPath /enable:all
exit $LASTEXITCODE
