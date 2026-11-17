# Dxcap.exe `-expdll`

## Summary

`Dxcap.exe` contains an undocumented `-expdll` option that accepts an absolute
DLL path and loads the selected module while the Microsoft-signed host remains
in System32. The DLL entry point runs before Dxcap resolves the optional
`ListExperiments` export.

This is a confirmed behavior delta for the existing LOLBAS `Dxcap.exe` entry.
The upstream contribution should edit `yml/OtherMSBinaries/Dxcap.yml`, not add a
second Dxcap entry.

## Current validation

| Property | Value |
|---|---|
| Path | `C:\Windows\System32\dxcap.exe` |
| File version | `10.0.26100.9818` |
| SHA-256 | `8445632561E0F9CA14EEE2D01293EE75804A738ED9594D3AD989DB7C62DBCF19` |
| Signature | Valid, Microsoft Windows |
| Privilege | Standard user |

A follow-up test on build `10.0.26100.9549` loaded a benign unsigned marker DLL
from an arbitrary directory and executed its `DllMain` without relocating
Dxcap. With `-explist`, Dxcap subsequently reported that the selected DLL did
not export `ListExperiments`. That ordering confirms the module entry point runs
before export resolution.

The current-build safe control uses the Microsoft system DLL `version.dll`:

```powershell
& C:\Windows\System32\dxcap.exe `
  -measure `
  -expdll C:\Windows\System32\version.dll `
  -explist
```

Observed diagnostic:

```text
The specified experiment DLL (C:\Windows\System32\version.dll) does not export
the ListExperiments entry point.
```

The diagnostic occurs after the selected module has been loaded. A successful
capture or zero process exit code is not required.

## Source-to-sink path

Static analysis of `CSessionRequest::CSessionRequest` identified this flow:

1. Construct the parser key `expdll`.
2. Resolve the caller-supplied value with `CommandLineParser::FindValue`.
3. Pass the selected string to `LoadLibraryExW(path, NULL, 0)`.
4. When `-explist` is supplied, resolve `ListExperiments` with
   `GetProcAddress` after the module load.

An ordinary newly loaded DLL receives `DLL_PROCESS_ATTACH` during
`LoadLibraryExW`. It does not need to export a Dxcap-specific function for its
entry point to run.

## Visual proof of concept

[`POC/test.c`](POC/test.c) is a minimal DLL that displays a message box from
`DllMain`. It performs no persistence, networking, credential access, or system
modification.

Build it from an **x64 Native Tools Command Prompt for Visual Studio**:

```cmd
cd dxcap-expdll\POC
nmake
```

Run `nmake clean` to remove the local compiler outputs.

Run the proof from PowerShell:

```powershell
$dll = (Resolve-Path .\test.dll).Path
& C:\Windows\System32\dxcap.exe -measure -expdll $dll -explist
```

Expected results:

1. A message box titled `LOLBAS Defensive Validation` appears inside the
   `dxcap.exe` process.
2. After the dialog is dismissed, Dxcap reports that the DLL does not export
   `ListExperiments`.

This visual PoC intentionally calls `MessageBoxW` from `DllMain` for a short,
controlled demonstration. Calling complex APIs while the loader lock is held is
not an application-development pattern and should not be used in production
software.

For a payload-free control, run
[`POC/Test-DxcapExpDll.ps1`](POC/Test-DxcapExpDll.ps1), which selects the signed
system `version.dll` and validates the post-load diagnostic.

## Detection opportunities

- `dxcap.exe` with `-expdll` on its command line.
- DLL loads by `dxcap.exe` from user-writable, temporary, download, archive, or
  network paths.
- A module load followed by a missing-`ListExperiments` error or nonzero exit.
- Retain the existing detection coverage for `dxcap.exe -c` and the documented
  relocated `xperf.exe` behavior; those are separate techniques.

Application-control products may still evaluate and block the DLL load. This
finding does not claim a universal bypass of WDAC, AppLocker DLL rules, Smart
App Control, or endpoint security products.

## LOLBAS submission material

The [`lolbas/`](lolbas/) directory contains:

- [`Dxcap-expdll-DELTA.yml`](lolbas/Dxcap-expdll-DELTA.yml): command blocks to
  merge into the existing entry.
- [`UPSTREAM-INTEGRATION.md`](lolbas/UPSTREAM-INTEGRATION.md): code-sample,
  detection, resource, and acknowledgement changes for the upstream file.

Current official entry:

- https://lolbas-project.github.io/lolbas/OtherMSBinaries/Dxcap/
- https://github.com/LOLBAS-Project/LOLBAS/blob/master/yml/OtherMSBinaries/Dxcap.yml
