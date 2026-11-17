# Microsoft.XslDebugger.Host.exe

## Status

Research retained for coordination only. Do not open a competing new-entry PR.

The upstream LOLBAS project already has an active proposal for this binary in
[PR #496](https://github.com/LOLBAS-Project/LOLBAS/pull/496), covering stronger
XSL script execution and download behavior. The local draft records an
additional direct remote-input retrieval observation that should be offered to
the existing contributor only if independently revalidated as a material delta.

The installed binary's help confirms this argument order:

```text
Microsoft.XslDebugger.Host.exe <xml-file> [<xsl-file>] [<option>+]
```

## Installed binary

| Property | Value |
|---|---|
| File version | `17.0.36015.10` |
| SHA-256 | `44A6F99CA5BE706419760FA456549DD91DCA47F983EDAF5571EDB6BE8CA45A9D` |
| Signature | Valid, Microsoft Corporation |

## Message-box proof of concept

The PoC uses a local XML document and an XSL stylesheet containing a minimal
`msxsl:script` C# block. The script calls `MessageBoxW` through P/Invoke and
does not create persistence, access credentials, or connect to a network.

Run from PowerShell:

```powershell
Set-Location .\microsoft-xsldebugger-host\POC
.\Test-XslDebuggerMessageBox.ps1
```

Expected result: a message box reports that inline XSLT C# executed inside
`Microsoft.XslDebugger.Host.exe`; after dismissal, the transform writes
`Validation completed` to standard output.

Useful defensive signals include `/enable:all`, input containing
`msxsl:script`, unexpected child processes or network activity, and invocation
outside Visual Studio debugging workflows.

No independent upstream submission is currently planned. The held draft is
under [`lolbas/`](lolbas/).
