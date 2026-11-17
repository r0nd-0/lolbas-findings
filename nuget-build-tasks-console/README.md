# NuGet.Build.Tasks.Console.exe

## Summary

The Microsoft-signed NuGet static-graph restore console evaluates
caller-controlled MSBuild XML. A project can define `_CollectRestoreInputs`, or
attach a target with `BeforeTargets`, and execute inline C# through
`RoslynCodeTaskFactory` or `CodeTaskFactory` inside the signed host.

This is a confirmed candidate for a new LOLBAS `OtherMSBinaries` entry.

## Validation

| Property | Value |
|---|---|
| File version | `6.14.3.1` |
| SHA-256 | `167021C0DB2956A58145D928E18E2D0746ADDC597E8CAA3964192C64A2B755F4` |
| Signature | Valid, Microsoft Corporation |
| Privilege | Standard user, medium integrity |
| Build result | `1 builds, 0 failures` before downstream restore processing |
| Expected final exit | `1`, after inline execution |

The execution path reaches `ProjectInstance.FromFile`, builds
`_CollectRestoreInputs`, and invokes tasks defined in the caller-controlled
project. Inline Roslyn C#, legacy `CodeTaskFactory`, an external unsigned task
assembly, and `Exec` were all independently confirmed.

Identical MSBuild XML executed under `.proj`, `.csproj`, `.vcxproj`, `.xml`,
`.txt`, `.props`, `.targets`, a renamed `.tt`, and an extensionless name. A
genuine T4 document was rejected; this is extension-independent MSBuild parsing,
not T4 interpretation.

## Message-box proof of concept

From `cmd.exe`:

```cmd
"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\NuGet\NuGet.Build.Tasks.Console.exe" "RestoreRecursive=false" "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "<path-to-MessageBox.csproj>" "TargetFramework=net472"
```

[`POC/MessageBox.csproj`](POC/MessageBox.csproj) is the complete proof. Expected
result: the dialog identifies `NuGet.Build.Tasks.Console.exe` as the process
executing the inline task. After the dialog is dismissed, the deliberately
minimal project may reach the known downstream `GetPackageSpec` error and exit
`1`; that occurs after execution.

## Detection opportunities

- Launches outside an expected Visual Studio/MSBuild/NuGet restore chain.
- Entry projects or global properties sourced from user-writable directories.
- Project content containing `_CollectRestoreInputs`,
  `_IsProjectRestoreSupported`, `UsingTask`, or inline task factories.
- Roslyn compiler or generated task assemblies loaded into the host.
- Unexpected child processes; do not require a successful process exit.

The proposed entry is
[`lolbas/NuGet.Build.Tasks.Console.yml`](lolbas/NuGet.Build.Tasks.Console.yml).
