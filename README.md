# DoH WIM Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2B-0078d4)](https://microsoft.com)
[![Built with](https://img.shields.io/badge/Built%20with-PowerShell-5391FE)](https://microsoft.com/powershell)

**Bake 125 DoH servers into Windows before it even installs.**

Injects all 125 DNS-over-HTTPS Well-Known Server entries directly into a Windows `install.wim` or `install.esd` image — offline, before installation. When Windows is installed from the modified image, every provider is pre-registered from first boot. No post-install tool needed.

---

## How It Works

Windows 10 and 11 have a built-in DNS-over-HTTPS feature accessible via **Settings → Network & Internet → DNS Settings**. When you set a DNS server IP, Windows checks its internal `DohWellKnownServers` registry list to see if that IP has a known DoH endpoint — if it does, it auto-fills the HTTPS template for you.

The problem: Microsoft's built-in list ships with only **3 providers** — Cloudflare, Google, and Quad9 — unchanged since the feature was first introduced in Windows 10 Insider Build 20185 (August 2020). The [official Microsoft documentation](https://learn.microsoft.com/en-us/windows-server/networking/dns/doh-client-support) (last updated December 2023) still reflects only these same 3 providers. All other DNS providers — including Mullvad, AdGuard, Control D, OpenDNS, DNS4EU, Clean Browsing, LibreDNS, Uncensored DNS, and more — are not on the list, so Windows cannot auto-template them.

This script solves that by injecting all 125 provider entries **directly into the WIM image** before Windows is installed, using two registry paths:

- `HKLM\SYSTEM\ControlSet001\Services\Dnscache\Parameters\DohWellKnownServers`
  Registers each DNS IP with its DoH `Template` URL. This is the key path Windows reads to auto-fill the endpoint.

- `HKLM\SYSTEM\ControlSet001\Services\Dnscache\InterfaceSpecificParameters\GlobalDohIP`
  Sets `DohTemplate` and `DohFlags` per IP. Using `GlobalDohIP` as the key name circumvents the need to target individual network adapter GUIDs, which change per machine and would make offline injection impractical.

> **Note:** The script targets `ControlSet001` rather than `CurrentControlSet`. In an offline loaded hive, `CurrentControlSet` is an unresolved symlink — writing to it silently places keys at an invalid location, which causes `0x67 CONFIG_INITIALIZATION_FAILED` on first boot. `ControlSet001` is the correct path for offline hive operations. On a running Windows system, `CurrentControlSet` maps to `ControlSet001`, so all injected keys are read correctly after installation.

The script mounts the WIM via DISM, loads the offline `SYSTEM` hive into a temporary registry alias, writes all entries into `ControlSet001`, flushes all .NET handles, unloads the hive, verifies the hive is fully released, and then commits the image. Changes are baked into the WIM — Windows Setup carries them into every installation from that image.

---

## Prerequisites

- Windows 10 or Windows 11
- DISM — built into Windows, no install needed
- PowerShell 5.1 or later — built into Windows
- Run as **Administrator**
- A Windows ISO (downloaded from Microsoft)
- [Rufus](https://rufus.ie) for creating the USB installer

---

## Guide

### Step 1 — Download a Windows ISO from Microsoft

Download a genuine Windows 10 or 11 ISO directly from Microsoft:

- [Windows 11 ISO](https://www.microsoft.com/software-download/windows11)
- [Windows 10 ISO](https://www.microsoft.com/software-download/windows10)

Save the ISO to your local PC. Do not mount it — it is only needed for the next step.

### Step 2 — Download the script

**Recommended: Use `git clone`** — this is the preferred method. It gives you the latest version of the script, avoids Windows script-blocking issues with browser-downloaded files, and makes updating a single command in Step 7.

```powershell
git clone https://github.com/1LUC1D4710N/doh-windows-installer-wim.git C:\Tools\doh-wim
```

> **Don't have Git?** Download [Git for Windows](https://git-scm.com/download/win) — it takes two minutes to install and is worth having.

**Alternative (no Git):** Click **Install-DoH-WIM.ps1** in the file list above → click the download button → save to `C:\Tools\doh-wim\`. Note that files downloaded through a browser may be flagged by Windows and require extra steps before PowerShell will run them. Using `git clone` avoids this entirely.

### Step 3 — Create your USB installer with Rufus

Download [Rufus](https://rufus.ie) and use it to create a bootable Windows USB installer:

1. Run Rufus
2. Select your USB drive
3. Click **SELECT** and choose your Windows ISO
4. Click **START** and follow the prompts
5. Wait for Rufus to finish writing the USB

The USB will now contain `sources\install.wim` — this is the file you will replace in the next steps.

### Step 4 — Extract install.wim from the USB installer to your PC

The `install.wim` on the USB installer created in Step 3 is read-only and cannot be modified in place. Copy it from the USB to a local working folder on your PC so DISM can mount and modify it.

```powershell
New-Item -ItemType Directory -Path "C:\Temp" -Force
Copy-Item "X:\sources\install.wim" "C:\Temp\install.wim"
```

Replace `X:` with your USB drive letter. To check your USB drive letter, open File Explorer — it is shown next to your USB drive name.

> **Note:** Copying 6+ GB takes a few minutes. Wait for the prompt to return before continuing.

### Step 5 — Strip the read-only attribute

Files copied from a USB carry the read-only attribute. Remove it before running the script:

```powershell
attrib -R "C:\Temp\install.wim"
```

### Step 6 — Check available indexes (optional)

A single WIM file contains all Windows editions, each with its own index number. To see what is inside:

```powershell
dism /Get-WimInfo /WimFile:"C:\Temp\install.wim"
```

Example output:
```
Index : 1  → Windows 11 Home
Index : 2  → Windows 11 Home N
Index : 3  → Windows 11 Pro
...
```

Using `-AllIndexes` processes all editions automatically, so you do not need to note individual numbers unless targeting a specific edition.

### Step 7 — Verify you have the latest script version

Before running, make sure you are using the latest version of the script. If you cloned the repository, pull the latest changes:

```powershell
git -C C:\Tools\doh-wim pull
```

If you downloaded `Install-DoH-WIM.ps1` manually, re-download it from the repo to ensure you have the current version before continuing.

### Step 8 — Run the script

Open PowerShell **as Administrator** (right-click → Run as Administrator), then allow the script to run (required once — Windows blocks unsigned scripts by default):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

The commands below use the full path to the script so they work from any folder — you do not need to navigate into the script directory first.

Process all editions in one run:

```powershell
C:\Tools\doh-wim\Install-DoH-WIM.ps1 -WimPath "C:\Temp\install.wim" -AllIndexes
```

Or target a single edition by index number (replace `6` with your chosen index from Step 6):

```powershell
C:\Tools\doh-wim\Install-DoH-WIM.ps1 -WimPath "C:\Temp\install.wim" -WimIndex 6
```

The script will mount, inject, and commit each index one by one. A summary is printed at the end showing which indexes passed or failed. Expect 5–15 minutes for all 11 editions depending on drive speed.

### Step 9 — Restore the read-only attribute

After injection is complete, restore the read-only attribute before copying the file back to the USB:

```powershell
attrib +R "C:\Temp\install.wim"
```

This mirrors the original state of the file on the USB installer.

### Step 10 — Copy the modified WIM back to the USB

Once the script completes successfully, replace the original `install.wim` on your USB with the modified one:

```powershell
Copy-Item "C:\Temp\install.wim" "X:\sources\install.wim"
```

Replace `X:` with your USB drive letter.

### Step 11 — Install Windows

Boot from the USB and install Windows as normal. All 125 DoH providers are pre-registered from the moment installation completes — no post-install tools required.

### Step 12 — Configure DoH in Settings (2 minutes)

After first boot:

1. Open **Settings** (Win+I)
2. Go to **Network & Internet → Advanced network settings → DNS Settings**
3. Click **Edit** next to DNS servers
4. Select **Manual**
5. Toggle **IPv4** to On and **IPv6** to On
6. Under **DNS over HTTPS**, select **On (automatic template)**
7. Type your preferred provider's IPv4 address
8. Type your preferred provider's IPv6 address
9. Click **Save** — Windows auto-fills the DoH endpoint

Your DNS is now encrypted from the first configuration.

---

## ESD Files

Some ISOs contain `install.esd` instead of `install.wim`. Convert it to WIM before running the script:

```powershell
dism /Export-Image /SourceImageFile:"C:\Temp\install.esd" /SourceIndex:1 /DestinationImageFile:"C:\Temp\install.wim" /Compress:max /CheckIntegrity
```

Then run the script against the exported `install.wim`.

---

## Supported Providers

| Provider | Type | IPv4 | IPv6 | Best For |
|---|---|---|---|---|
| Cloudflare | Tiered | 1.1.1.1 | 2606:4700:4700::1111 | Speed + Reliability |
| Control D | Multi-filter | 76.76.2.x | 2606:1a40::x | Granular Control |
| DNS4EU | Multi-filter | 86.54.11.x | 2a13:1001::... | European Privacy |
| Quad9 | Security | 9.9.9.9 | 2620:fe::9 | Non-profit Security |
| Google | Standard | 8.8.8.8 | 2001:4860:4860::8888 | Performance |
| Mullvad | Privacy-first | 194.242.2.2 | 2a07:e340::2 | Privacy + Adblock |
| AdGuard | Multi-filter | 94.140.14.14 | 2a10:50c0::ad1:ff | All-in-one Protection |
| OpenDNS | Enterprise | 208.67.222.222 | 2620:119:35::35 | Business Use |
| Clean Browsing | Family | 185.228.168.168 | 2a0d:2a00:1:: | Family Safety |
| LibreDNS | Minimal | 116.202.176.26 | 2a01:4f8:1c0c:8274::1 | Lightweight |
| Uncensored DNS | No-filter | 91.239.100.100 | 2001:67c:28a4:: | Unrestricted |

**125 configurations total — IPv4 and IPv6 for all providers.**

→ [See full DNS Providers Reference](DNS-PROVIDERS-REFERENCE.md) for all 125 IPs and DoH endpoints.

---

## Troubleshooting

**Script will not run / blocked by Windows**
Run this once in an Administrator PowerShell window, then retry:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**DISM mount fails with permissions error (0xc1510111)**
The WIM file is read-only. Strip the attribute before running the script:
```powershell
attrib -R "C:\Temp\install.wim"
```

**DISM mount fails with dirty mount error**
A previous mount was not cleaned up. Run:
```powershell
dism /Cleanup-Wim
```

**`reg unload` fails with Access Denied**
Close any open registry editor windows and retry. The script includes `[gc]::Collect()`, `[gc]::WaitForPendingFinalizers()`, and a 2-second delay to fully release all handles before unloading.

**ESD export fails**
Try a lower compression level:
```powershell
dism /Export-Image /SourceImageFile:install.esd /SourceIndex:1 /DestinationImageFile:install.wim /Compress:fast
```

**System boots to 0x67 (CONFIG_INITIALIZATION_FAILED) after injection**
The registry configuration failed on boot. This was caused by writing DoH keys to `CurrentControlSet` in the offline hive — `CurrentControlSet` is a symlink that does not resolve in an offline loaded hive, so the keys were written to an invalid location. The script has been corrected to use `ControlSet001` instead. If you are seeing this error from a previous version, re-run the script against a fresh copy of `install.wim`.

If the issue persists after re-running, use these diagnostics:

| Check | Command |
|---|---|
| View DISM log | `notepad C:\Windows\Logs\DISM\dism.log` |
| List stale mount points | `dism /Get-MountedWimInfo` |
| Clean up broken mounts | `dism /Cleanup-Wim` |
| Discard and unmount | `dism /Unmount-Image /MountDir:C:\Mount /Discard` |
| Check WIM indexes | `dism /Get-WimInfo /WimFile:C:\Temp\install.wim` |

---

## Verifying the Injection (Post-Install Test)

After installing Windows from the modified image, run these checks in PowerShell to confirm all 125 entries were baked in correctly and survived the full Windows Setup process.

### Test 1 — DohWellKnownServers (125 entries)

```powershell
$keys = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\DohWellKnownServers"
Write-Host "DohWellKnownServers entries: $($keys.Count)"
```

Expected output: `DohWellKnownServers entries: 125`

### Test 2 — GlobalDohIP (125 entries)

```powershell
$keys = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\GlobalDohIP"
Write-Host "GlobalDohIP entries: $($keys.Count)"
```

Expected output: `GlobalDohIP entries: 125`

### Test 3 — Spot check a specific provider

```powershell
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\DohWellKnownServers\9.9.9.9"
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\GlobalDohIP\9.9.9.9"
```

Expected: `Template` shows `https://dns.quad9.net/dns-query`, `DohTemplate` matches, and `DohFlags` is present.

### Test 4 — Settings UI confirmation

1. Open **Settings → Network & Internet → Advanced network settings → DNS Settings**
2. Click **Edit** next to DNS servers
3. Select **Manual** and toggle IPv4 on
4. Type any provider IP from the list — for example `9.9.9.9`, `94.140.14.14`, or `194.242.2.2`
5. **"On (automatic template)"** should appear and auto-fill the DoH URL without you typing it

If all four tests pass — the image was correctly modified and Windows was born with all 125 DoH providers registered. ✅

---

## License

MIT License — No email. No tracking. No accounts.
