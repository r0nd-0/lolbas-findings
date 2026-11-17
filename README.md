# LOLBAS Findings

Defensive research, benign validation harnesses, and supporting evidence for
proposed contributions to the [LOLBAS Project](https://github.com/LOLBAS-Project/LOLBAS).

## Purpose

This repository documents unexpected behavior in Microsoft-signed Windows
binaries so defenders can build process, command-line, module-load, file, and
network detections. Findings are prepared for responsible submission to the
official LOLBAS catalog.

Validation artifacts in this repository are designed to be benign. They write
marker files, display a local message box, or record process metadata to
demonstrate execution without persistence, credential access, destructive
actions, or operational payloads.

## Validation standard

Each finding should record:

- The legitimate purpose and installed path of the binary.
- File and product versions, SHA-256, signer, Windows build, and user integrity.
- A source-available benign reproduction and its expected result.
- The observed execution or retrieval path.
- Detection opportunities and important limitations.
- The corresponding LOLBAS entry or upstream pull-request status.

Microsoft binaries and compiled payloads are not included. Reproduction code is
provided as source with local build instructions.

## Repository layout

```text
<binary-technique>/
  README.md
  POC/
  lolbas/
```

- `README.md` combines the finding, validation evidence, reproduction steps,
  limitations, and defensive detection guidance.
- `POC/` contains benign source and repeatable validation scripts.
- `lolbas/` contains the proposed upstream YML or a patch for an existing entry.

## Findings

| Finding | Validation |
|---|---|
| [Dxcap `-expdll`](dxcap-expdll/) | On a current Windows 11 build, `-expdll` loads a caller-selected DLL before resolving the optional `ListExperiments` export. A signed system DLL produced the expected post-load missing-export diagnostic. The source PoC provides a visible message-box demonstration without persistence or network activity. |
| [VcxprojReader](vcxprojreader/) | The signed Visual Studio reader evaluates caller-controlled MSBuild XML and invokes fixed design-time targets. A redefined target executed inline C# through `CodeTaskFactory` inside `VcxprojReader.exe` as a standard user. The retained project displays a benign message box to demonstrate execution. |
| [NuGet.Build.Tasks.Console](nuget-build-tasks-console/) | The signed NuGet restore host evaluates a caller-supplied MSBuild project and builds `_CollectRestoreInputs`. A `RoslynCodeTaskFactory` task executed inline C# inside `NuGet.Build.Tasks.Console.exe` at medium integrity. Execution completes before the minimal project reaches its expected downstream restore error and exit code `1`. |
| [`lc.exe`](lc/) | The .NET Framework License Compiler loads an unsigned assembly supplied through `/i` and instantiates the component named by a `.licx` file. The component constructor ran inside the installed `lc.exe` process without elevation or host relocation. The PoC uses a local message box and leaves no persistent changes. |
| [Xperf](xperf/) | The `-PidNewProcess` option starts the selected child before private ETW session creation completes. Under a standard user, the benign child executed even though Xperf subsequently returned access denied for the ETW operation. This is a parent-process proxy behavior and does not bypass policy enforcement on the child executable. |
| [Microsoft.XslDebugger.Host](microsoft-xsldebugger-host/) | The signed Visual Studio XSLT host accepts local XML and XSL input and enables inline `msxsl:script` execution with `/enable:all`. The retained stylesheet displayed a benign message box from inline C# and returned the expected validation text. The behavior is same-user execution and does not cross a privilege boundary. |

## Project relationship

This is an independent defensive research repository and is not the official
LOLBAS repository. Final catalog contributions are submitted to the upstream
project through individual pull requests.

## License

This repository is licensed under the GNU General Public License v3.0. See
[`LICENSE`](LICENSE).
