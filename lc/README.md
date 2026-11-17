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

The PoC requires two source files:

- [`MessageBoxComponent.cs`](POC/MessageBoxComponent.cs): component constructor
  that displays the benign validation message.
- [`messagebox.licx`](POC/messagebox.licx): identifies the component type and
  the `LcMessageBox` assembly.

Compile the component from `cmd.exe`. The output must be named
`LcMessageBox.dll` to match the assembly name in `messagebox.licx`:

```cmd
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe" /nologo /target:library /out:"<path-to-LcMessageBox.dll>" "<path-to-MessageBoxComponent.cs>"
```

Run the proof with the installed License Compiler:

```cmd
"C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\lc.exe" /nologo /target:fake.exe /complist:"<path-to-messagebox.licx>" /outdir:"<writable-output-directory>" /i:"<path-to-LcMessageBox.dll>"
```

Expected result: a dialog reports that `lc.exe` loaded the unsigned assembly
and instantiated the component. Dismissing it allows license compilation to
complete.

## Detection opportunities

- `/i` or `/complist` paths under user-writable, temporary, or download areas.
- Unsigned or user-writable assemblies loaded into `lc.exe`.
- Interactive or non-build parents and unexpected child/network activity.

Application-control products may still evaluate and block the assembly load;
this finding does not claim a universal bypass. The proposed entry is
[`lolbas/Lc.yml`](lolbas/Lc.yml).
