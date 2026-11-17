# Xperf.exe `-PidNewProcess`

## Summary

The Microsoft-signed Windows Performance Toolkit trace controller starts the
process selected by `-PidNewProcess` before creating the requested private ETW
logger. On the validated build, a standard user's child ran even though ETW
setup subsequently failed with access denied.

Maintainer acceptance is less certain because process launch is an intended
option; the unexpected behavior is the child-before-privileged-failure ordering.

## Validation

| Property | Value |
|---|---|
| File version | `10.0.26100.7705` |
| SHA-256 | `6E0C15D303E9369A8756B7F9B63978220BA3C8F9B9471A00B0E63958CC095561` |
| Signature | Valid, Microsoft Corporation |
| Privilege | Standard user, non-administrator |
| Xperf result | Access denied, `0x80070005` |
| Child result | Executed and created the benign marker |

The non-GUI [`POC/Test-XperfProxy.ps1`](POC/Test-XperfProxy.ps1) uses a unique
session name, writes only under `%TEMP%`, and stops the session if an elevated
run succeeds.

## Message-box proof of concept

Build the benign child from an **x64 Native Tools Command Prompt for Visual
Studio**:

```cmd
cd xperf\POC
nmake
```

Then run from PowerShell:

```powershell
Set-Location .\xperf\POC
.\Test-XperfMessageBox.ps1
```

Expected standard-user result: the selected child displays a defensive
validation message box, and Xperf later reports access denied for the ETW
session. Dismiss the dialog to let the child exit. Run `nmake clean` to remove
the local compiler outputs.

## Detection opportunities

- `xperf.exe` command lines containing `-PidNewProcess`.
- Unexpected children of `xperf.exe`, especially from user-writable paths.
- `xperf.exe` launched by interactive or non-diagnostic parents.

This is process-parent proxy execution, not an application-control bypass;
policy still applies to the selected child. The proposed entry is
[`lolbas/Xperf.yml`](lolbas/Xperf.yml).
