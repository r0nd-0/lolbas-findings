# Infgate.exe WDK INF Validator

## Summary

`Infgate.exe` is a Microsoft-signed Windows Driver Kit (WDK) tool that validates
printer INF files for conformance. Its `/WTT` logging option loads the WTT logger
assembly `Microsoft.Wtt.Log.dll` by bare name through `Assembly.LoadFrom` when the
expected GAC directory is absent (the default), resolving it from the **current
working directory**. A caller who places an unsigned `Microsoft.Wtt.Log.dll` in
that directory has it loaded and its `TestLogger` constructor executed **in-process**
while `infgate.exe` remains in its installed Windows Kits directory.

Because the payload runs inside the signed host rather than as a child process,
this is an application-control (AppLocker DLL-rules-off) bypass as well as a proxy
execution finding. It is a standard-user, same-token technique; it does not cross a
privilege boundary or claim a universal policy bypass. This is a confirmed
candidate for a new LOLBAS `OtherMSBinaries` entry.

## Validation

| Property | Value |
|---|---|
| Path | `C:\Program Files (x86)\Windows Kits\10\Tools\10.0.26100.0\x64\infgate.exe` |
| File version | `10.0.26100.3323` |
| SHA-256 | `62ACECE5662285BFB8D075AFAB0955A1C2EC877FD20D2B2A0254D99E2641B145` |
| Signature | Valid, Microsoft Corporation |
| Privilege | Standard user (medium integrity) |
| Result | Unsigned assembly loaded from the working directory and its constructor executed inside `infgate.exe` |

The non-GUI validation compiled an unsigned assembly under the unrelated internal
name `NotWtt`, renamed the file to `Microsoft.Wtt.Log.dll`, placed it in a
user-writable working directory, and ran the installed `infgate.exe` with `/WTT`.
The constructor executed and recorded process metadata identifying the signed
`infgate.exe` image and the loaded assembly's unrelated `NotWtt` identity:

```text
Image=...\Windows Kits\10\Tools\10.0.26100.0\x64\infgate.exe
Assembly=...\Microsoft.Wtt.Log.dll
AssemblyIdentity=NotWtt, Version=3.0.0.0, Culture=neutral, PublicKeyToken=null
User=<domain>\<user>
```

No host relocation, elevation, persistence, networking, or child process was
required. The assembly name, strong name, and Authenticode signature are not
checked; the only pre-activation gate is a file-version check (major > 2, or
major == 2 and minor >= 2).

## Message-box proof of concept

The payload is a single managed class whose namespace, type name, and constructor
shape are fixed by what infgate reflects on:

- [`POC/MicrosoftWttLogCanary.cs`](POC/MicrosoftWttLogCanary.cs): a
  `Microsoft.DistributedAutomation.Logger.TestLogger(string)` constructor that
  displays a benign message box through `user32!MessageBoxW`.
- [`POC/trigger.inf`](POC/trigger.inf): a syntactically valid INF used only to
  satisfy option validation; its contents do not reference the DLL.

Compile the payload from `cmd.exe`. The output **must** be named
`Microsoft.Wtt.Log.dll`; its own assembly identity is irrelevant:

```cmd
"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:library /out:"<writable-dir>\Microsoft.Wtt.Log.dll" "<path-to-MicrosoftWttLogCanary.cs>"
```

Run the proof with the installed WDK validator, using the directory that holds
`Microsoft.Wtt.Log.dll` as the current directory and a fresh output directory:

```cmd
cd /d "<writable-dir containing Microsoft.Wtt.Log.dll>"
"C:\Program Files (x86)\Windows Kits\10\Tools\10.0.26100.0\x64\infgate.exe" "<path-to-trigger.inf>" /WTT "/O=<fresh-output-dir>"
```

Expected result: a message box titled `LOLBAS Defensive Validation` appears. The
constructor runs **before** infgate prints `Microsoft.Wtt.Log.dll is not found or
load error occurred` / `/WTT option is turned off` — that message is expected and
appears only because the minimal DLL omits the remaining WTT API members that
infgate reflects on next; it is not evidence that no code ran.

Notes:

- Use a **fresh** `/O=` output directory. If it already contains `summary.htm`,
  infgate prompts `Overwrite [Y]?` and waits for console input.
- A `Zone.Identifier` (`ZoneId=3`) stream on the DLL blocks the load; delivery
  must land the DLL without Mark-of-the-Web.
- An alternate placement sets the child process `windir` to a crafted root
  containing `...\Microsoft.NET\assembly\GAC_MSIL\Microsoft.Wtt.Log\<any>\Microsoft.Wtt.Log.dll`.

## Detection opportunities

- `infgate.exe` with `/WTT`, especially outside a WDK validation/build process
  tree or launched by an interactive, Office, browser, or script-host parent.
- `infgate.exe` loading `Microsoft.Wtt.Log.dll` from its current working directory
  or any path outside Windows Kits/TAEF/GAC locations.
- The loaded `Microsoft.Wtt.Log.dll` is unsigned, has a non-Microsoft signer,
  lacks the strong-name token `399d95e6b32b7391`, or has an internal assembly name
  other than `Microsoft.Wtt.Log`.
- The `infgate.exe` child-process environment carries a `windir` value that differs
  from the real Windows directory.

Application-control products may still evaluate and block the assembly load; this
finding does not claim a universal bypass. The proposed entry is
[`lolbas/Infgate.yml`](lolbas/Infgate.yml).

## Upstream status

As checked on 2026-11-17, the current LOLBAS catalog contains no `infgate` entry.
`infgate.exe` is a Microsoft binary distributed with the Windows Kits (WDK), which
is within LOLBAS scope for Microsoft-downloaded binaries. Recheck before opening
the pull request.
