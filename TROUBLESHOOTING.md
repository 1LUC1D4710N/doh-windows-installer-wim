# Troubleshooting

## 0x67 CONFIG_INITIALIZATION_FAILED After WIM Injection

If the system boots to a `0x67` stop code after a seemingly successful DoH injection, the registry configuration failed during boot. The confirmed root cause was the use of `CurrentControlSet` in the offline registry hive paths.

---

### Root Cause: `CurrentControlSet` vs `ControlSet001`

In a **live running system**, `CurrentControlSet` is a valid registry symlink that Windows resolves dynamically at boot. In an **offline loaded hive** — as used during WIM injection — `CurrentControlSet` does not resolve. It points to nothing, causing the injected keys to be written to an invalid location. When Windows boots and attempts to initialize DNS cache using those missing keys, it fails with `0x67 CONFIG_INITIALIZATION_FAILED`.

This can happen even when the injection appears to succeed — no error is thrown at write time because the symlink silently accepts the write without resolving it.

**Fix applied in this version:** The script now targets `ControlSet001` directly, which is the correct and stable path for all offline hive operations.

| Context | Correct Path |
|---|---|
| Live running system | `HKLM\SYSTEM\CurrentControlSet\...` |
| Offline WIM hive injection | `HKLM\SYSTEM\ControlSet001\...` |

---

### Additional Fixes Applied

#### 1 — Full GC flush before `reg unload`

PowerShell's .NET runtime can hold open handles to registry keys even after all explicit references are closed. The earlier version used only `[gc]::Collect()` with a 500ms sleep, which was not always sufficient. The fix adds `[gc]::WaitForPendingFinalizers()` and extends the sleep to 2 seconds to ensure all handles are fully released before the hive is unloaded.

```powershell
[gc]::Collect()
[gc]::WaitForPendingFinalizers()
Start-Sleep -Seconds 2
reg unload $HiveAlias
```

#### 2 — Hive verification gate before commit

A safety check was added after `reg unload` to confirm the hive path is no longer present before DISM commits the image. If the hive is still mounted, the script throws an error and aborts rather than committing a silently corrupted image.

```powershell
if (Test-Path "HKLM:\OFFLINE_SYSTEM_$Index") {
    throw "Hive still present after unload. Aborting commit to prevent WIM corruption."
}
```

---

### Corrected Injection Order

The script now follows this sequence for each index:

1. Mount WIM index via DISM
2. Load offline `SYSTEM` hive under a unique alias
3. Inject all DoH keys into `ControlSet001` (not `CurrentControlSet`)
4. Force full GC flush — `[gc]::Collect()` + `[gc]::WaitForPendingFinalizers()` + 2s sleep
5. Unload hive with `reg unload`
6. Verify hive path is gone before proceeding
7. Commit and unmount via DISM

---

### Diagnostic Commands

| Check | Command |
|---|---|
| View DISM log | `notepad C:\Windows\Logs\DISM\dism.log` |
| List stale mount points | `dism /Get-MountedWimInfo` |
| Clean up broken mounts | `dism /Cleanup-Wim` |
| Discard and unmount | `dism /Unmount-Image /MountDir:C:\Mount /Discard` |
| Check WIM indexes | `dism /Get-WimInfo /WimFile:C:\Temp\install.wim` |

---

### Environment Confirmed Working

- Windows 11 25H2
- PowerShell (Run as Administrator)
- DISM built into Windows — no ADK required
