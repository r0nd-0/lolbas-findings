# VcxprojReader.exe

## Summary

`VcxprojReader.exe` is a Microsoft-signed Visual Studio C++ design-time project
reader. It evaluates a caller-supplied MSBuild document and invokes a fixed set
of design-time targets. A redefined target can execute inline C# through
`CodeTaskFactory` inside the signed process or use `Exec` to create a child.

This is a confirmed candidate for a new LOLBAS `OtherMSBinaries` entry.

## Validation

| Property | Value |
|---|---|
| Installed path | `C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\VcxprojReader.exe` |
| File version | `17.0.37627.8` |
| SHA-256 | `8A4B0B4D4CF3588E7834CFE63BD6A8D20897C7476D0C6F040516A05C889EEC42` |
| Signature | Valid, Microsoft Corporation |
| Privilege | Standard user, medium integrity |
| Current result | Design-time build succeeded, exit `0`, inline marker created |

The validated target path is:

```text
Project XML
  -> BuildManager.GetProjectInstanceForBuild
  -> BuildRequestData for fixed design-time target names
  -> BuildManager.Build
  -> caller-defined target body
  -> CodeTaskFactory or Exec
```

Confirmed target names include `GetProjectDirectories`, `GetClCommandLines`,
`GetGeneratedFiles`, `GetAssemblyReferences`, `GetProjectReferences`, and
`GetResolvedReferences`. The PoC uses `GetProjectDirectories`.

MSBuild XML executed under multiple filename extensions and extensionless names.
A tested input retaining Internet-zone MOTW still executed on the CLI path.

## Message-box proof of concept

From `cmd.exe`:

```cmd
"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\VcxprojReader.exe" "/DataBase:%TEMP%\VcxprojReaderMessageBox-%RANDOM%.db" /WriteProjectData /WriteDynamicConfigData "/p:Configuration=Debug;Platform=x64" "<path-to-MessageBox.csproj>"
```

[`POC/MessageBox.csproj`](POC/MessageBox.csproj) is the complete proof. The
command supplies a fresh writable database, `/WriteProjectData`,
`/WriteDynamicConfigData`, and the quoted configuration property. Expected
result: a message box reports that inline C# executed inside
`VcxprojReader.exe`; dismissing it allows the process to complete.

## Detection opportunities

- Interactive or non-Visual-Studio parents launching `VcxprojReader.exe`.
- `/WriteDynamicConfigData`, especially with `/WriteProjectData` and a fresh
  database or project path in a user-writable directory.
- `UsingTask`, `CodeTaskFactory`, `RoslynCodeTaskFactory`, or executable tasks
  inside one of the fixed design-time target names.
- Unexpected child processes, network activity, or writes outside normal
  Visual Studio project-cache locations.
- Do not restrict content inspection to `.vcxproj` filenames.

No elevation or privilege boundary crossing was observed. The proposed entry is
[`lolbas/VcxprojReader.yml`](lolbas/VcxprojReader.yml).
