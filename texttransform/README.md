# TextTransform.exe and TextTransformCore.exe

## Summary

Microsoft Visual Studio includes the signed T4 text-template transformation
host `TextTransform.exe` and its worker `TextTransformCore.exe`. A
caller-selected `.tt` template can contain inline C# or VB code that is
compiled and executed by the signed host during transformation. Inline code
can also invoke native Windows APIs through P/Invoke.

This is a same-user proxy-execution and application-control research finding.
It does not cross a privilege boundary or claim a universal policy bypass.

## Validation

Current installed binaries:

| Binary | File version | SHA-256 | Signature |
|---|---|---|---|
| `TextTransform.exe` | `17.0.37627.8` | `8BBDDCB96CA9563BD31020D66C7C85526E43326CEC4FF8D9B13A89C81E98675F` | Valid, Microsoft Corporation |
| `TextTransformCore.exe` | `17.14.40966.2924` | `A13402620DCFC289D6A4FD4D39524F4036B2C8C224C0B0898BDCA9F677806554` | Valid, Microsoft Corporation |

The original visual proof used a signed `TextTransformCore.exe` copy with file
version `17.14.40783.9283` and SHA-256
`9BF5704D2EAE22BA63EBE3506CDC12F66964F990C7B2ABE1EEF982EB3255AE82`.
The Microsoft executable is intentionally not included in this repository.

A follow-up non-GUI validation used the installed `TextTransform.exe` from its
Visual Studio directory with a harmless T4 template. The process exited `0`,
created the requested transformation output, and updated a marker containing
only a timestamp. No elevation, persistence, credential access, networking,
or child process was involved.

## Message-box proof of concept

[`POC/msgbox.tt`](POC/msgbox.tt) contains inline C# that calls `MessageBoxW`
through P/Invoke. It performs no persistence, networking, credential access,
or system modification.

Run from `cmd.exe`:

```cmd
"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\TextTransform.exe" -out "<path-to-output.txt>" "<path-to-msgbox.tt>"
```

Expected result: a message box titled `LOLBAS Defensive Validation` appears.
After it is dismissed, the output contains `Validation completed`.

## Detection opportunities

- `TextTransform.exe` or `TextTransformCore.exe` launched outside an expected
  Visual Studio or build workflow.
- A `.tt` argument under a user-writable, temporary, download, or archive path.
- Template content containing executable T4 control blocks, P/Invoke, or an
  assembly directive referencing a user-writable DLL.
- Unexpected unsigned assembly loads, child processes, or network activity
  from `TextTransformCore.exe`.

## Upstream status

The proposed entry is [`lolbas/TextTransform.yml`](lolbas/TextTransform.yml).
LOLBAS PR [#496](https://github.com/LOLBAS-Project/LOLBAS/pull/496) already
includes TextTransform research from another contributor. Coordinate this
independent validation with that PR rather than opening a competing entry while
it remains active.
