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

| Finding | Validation | Upstream plan |
|---|---|---|
| [Dxcap `-expdll`](dxcap-expdll/) | Confirmed on current Windows 11 build | Delta to existing `Dxcap.yml` |
| [VcxprojReader](vcxprojreader/) | Confirmed inline C# and child-process paths | New `OtherMSBinaries` entry |
| [NuGet.Build.Tasks.Console](nuget-build-tasks-console/) | Confirmed inline task execution | New `OtherMSBinaries` entry |
| [`lc.exe`](lc/) | Confirmed unsigned component construction | New `OtherMSBinaries` entry |
| [Xperf](xperf/) | Confirmed child-before-ETW-failure behavior | New entry; maintainer acceptance uncertain |
| [Microsoft.XslDebugger.Host](microsoft-xsldebugger-host/) | Overlaps an active upstream contribution | Coordinate with PR #496 |

## Project relationship

This is an independent defensive research repository and is not the official
LOLBAS repository. Final catalog contributions are submitted to the upstream
project through individual pull requests.

## License

This repository is licensed under the GNU General Public License v3.0. See
[`LICENSE`](LICENSE).
