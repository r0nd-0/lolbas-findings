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

## Message-box proof of concept

Build the benign child from an **x64 Native Tools Command Prompt for Visual
Studio**:

```cmd
cd /d <path-to-xperf-poc>
nmake
```

Run the validation from a standard Command Prompt:

```cmd
"C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\xperf.exe" -start XperfMessageBoxValidation -heap -PidNewProcess "<path-to-test.exe>" -WaitForNewProcess
```

Expected standard-user result: the selected child displays a defensive
validation message box. After the dialog is dismissed, Xperf reports access
denied (`0x80070005`) while creating the private ETW logger. This demonstrates
that the child starts before the privileged trace setup fails.

Remove the local compiler outputs when finished:

```cmd
nmake clean
```

## Detection opportunities

- `xperf.exe` command lines containing `-PidNewProcess`.
- Unexpected children of `xperf.exe`, especially from user-writable paths.
- `xperf.exe` launched by interactive or non-diagnostic parents.

This is process-parent proxy execution, not an application-control bypass;
policy still applies to the selected child. The proposed entry is
[`lolbas/Xperf.yml`](lolbas/Xperf.yml).

## References

- [Microsoft Xperf `start` documentation](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/start)
