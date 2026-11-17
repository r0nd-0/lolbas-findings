# Lc.exe License Compiler

## Summary

The Microsoft-signed .NET Framework License Compiler loads assemblies supplied
through `/i`, resolves component types listed in a `.licx` file, and
instantiates them. A component constructor therefore executes inside `lc.exe`
while the host remains in its installed Windows SDK directory.

This is a confirmed candidate for a new LOLBAS `OtherMSBinaries` entry.

## Validation

| Property | Value |
|---|---|
| Path | `C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\lc.exe` |
| File version | `4.8.9037.0` |
| SHA-256 | `83B0692251CBCC461C8252C3C3944C094D5A4E9AEF6CDDFB8B94B12E3C40AFC2` |
| Signature | Valid, Microsoft Corporation |
| Privilege | Standard user |
| Result | Exit `0`; unsigned temporary assembly instantiated inside `lc.exe` |

The non-GUI validation compiled an unsigned component assembly in a
user-writable temporary directory. Its constructor wrote process metadata that
identified the installed `lc.exe` image. No host relocation, elevation,
persistence, networking, or child process was required.

## Message-box proof of concept

Run from PowerShell:

```powershell
Set-Location .\lc\POC
.\Test-LcMessageBox.ps1
```

The script compiles [`MessageBoxComponent.cs`](POC/MessageBoxComponent.cs) with
the 32-bit .NET Framework compiler, copies the `.licx` file and unsigned
assembly into a new temporary directory, and invokes the installed 4.8.1
`lc.exe`. Expected result: a dialog reports that `lc.exe` loaded the assembly
and instantiated the component; dismissing it allows the license compilation
to complete.

For a non-GUI control, run [`POC/Test-LcProxy.ps1`](POC/Test-LcProxy.ps1). It
uses `CanaryComponent.cs` to write a harmless marker with the executing image,
PID, and user.

## Detection opportunities

- `/i` or `/complist` paths under user-writable, temporary, or download areas.
- Unsigned or user-writable assemblies loaded into `lc.exe`.
- Interactive or non-build parents and unexpected child/network activity.

Application-control products may still evaluate and block the assembly load;
this finding does not claim a universal bypass. The proposed entry is
[`lolbas/Lc.yml`](lolbas/Lc.yml).
