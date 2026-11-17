# Upstream integration notes

Edit the existing upstream file:

```text
yml/OtherMSBinaries/Dxcap.yml
```

Merge the command blocks from `Dxcap-expdll-DELTA.yml` into `Commands`, then
append the new code sample without removing the entry's existing links:

```yaml
Code_Sample:
  - Code: https://github.com/r0nd-0/lolbas-findings/blob/main/dxcap-expdll/POC/test.c
```

Merge the following detection, resource, and acknowledgement information into
the existing lists without duplicating existing values:

```yaml
Detection:
  - IOC: dxcap.exe command line containing -expdll
  - IOC: dxcap.exe loading a DLL from a user-writable, temporary, download, archive, or network path
Resources:
  - Link: https://github.com/r0nd-0/lolbas-findings/tree/main/dxcap-expdll
Acknowledgement:
  - Person: 'Cory Rondorf (@r0nd-0)'
```

For submission, copy the fully merged `Dxcap.yml` from this directory over the
existing upstream file. The delta remains only as a concise research reference.
