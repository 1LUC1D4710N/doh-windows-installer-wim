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

- `HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\DohWellKnownServers`
  Registers each DNS IP with its DoH `Template` URL. This is the key path Windows reads to auto-fill the endpoint.

- `HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\GlobalDohIP`
  Sets `DohTemplate` and `DohFlags` per IP. Using `GlobalDohIP` as the key name circumvents the need to target individual network adapter GUIDs, which change per machine and would make offline injection impractical.

The script mounts the WIM via DISM, loads the offline `SYSTEM` hive into a temporary registry alias, writes all entries, unloads the hive, and commits the image. Changes are baked into the WIM — Windows Setup carries them into every installation from that image.

---

## Prerequisites

- Windows 10 or Windows 11
- DISM — built into Windows, no install needed
- PowerShell 5.1 or later — built into Windows
- Run as **Administrator**
- A Windows ISO (downloaded from Microsoft)
- A USB installer created with Rufus or the Windows Media Creation Tool

---

## Guide

### Step 1 — Download the script

Clone this repository or download `Install-DoH-WIM.ps1` directly. The examples below use `C:\Tools\doh-wim` as the script location.

```powershell
git clone https://github.com/1LUC1D4710N/doh-windows-installer-wim.git C:\Tools\doh-wim
```

Or download the raw file manually: click **Install-DoH-WIM.ps1** in the file list above → click the download button → save to `C:\Tools\doh-wim\`.

### Step 2 — Create your USB installer

Create a bootable Windows USB drive as normal using **Rufus** or the **Windows Media Creation Tool**. Do this first — the USB will contain a `sources\install.wim` that you will replace later.

### Step 3 — Copy install.wim to your local PC

DISM requires **read/write access** to the WIM file. A mounted ISO and a freshly created USB installer both provide read-only files. You must copy `install.wim` to a local writable folder first.

Create a working folder and copy the file from your USB installer:

```powershell
New-Item -ItemType Directory -Path "C:\Temp" -Force
Copy-Item "E:\sources\install.wim" "C:\Temp\install.wim"
```

Replace `E:` with your USB drive letter.

> **Note:** Copying 6+ GB takes a few minutes. Wait for the prompt to return before continuing.

### Step 4 — Strip the read-only attribute

Files copied from a USB or ISO often carry the read-only attribute. Remove it before running the script:

```powershell
attrib -R "C:\Temp\install.wim"
```

### Step 5 — Check available indexes (optional)

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

### Step 6 — Run the script

Open PowerShell **as Administrator** (right-click → Run as Administrator), then:

```powershell
cd C:\Tools\doh-wim
```

Allow the script to run (required once — Windows blocks unsigned scripts by default):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Process all editions in one run:

```powershell
.\Install-DoH-WIM.ps1 -WimPath "C:\Temp\install.wim" -AllIndexes
```

Or target a single edition by index:

```powershell
.\Install-DoH-WIM.ps1 -WimPath "C:\Temp\install.wim" -WimIndex 6
```

The script will mount, inject, and commit each index one by one. A summary is printed at the end showing which indexes passed or failed. Expect 5–15 minutes for all 11 editions depending on drive speed.

### Step 7 — Copy the modified WIM back to the USB

Once the script completes successfully, replace the original `install.wim` on your USB installer with the modified one:

```powershell
Copy-Item "C:\Temp\install.wim" "E:\sources\install.wim"
```

Replace `E:` with your USB drive letter. The file is the same size so no space issues.

### Step 8 — Install Windows

Boot from the USB and install Windows as normal. All 125 DoH providers are pre-registered from the moment installation completes — no post-install tools required.

### Step 9 — Configure DoH in Settings (2 minutes)

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
Close any open registry editor windows and retry. The script includes `[gc]::Collect()` and a short delay to release handles before unloading.

**ESD export fails**
Try a lower compression level:
```powershell
dism /Export-Image /SourceImageFile:install.esd /SourceIndex:1 /DestinationImageFile:install.wim /Compress:fast
```

---

## License

MIT License — No email. No tracking. No accounts.
