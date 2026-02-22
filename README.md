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
- A `install.wim` or `install.esd` extracted from a Windows ISO

---

## Guide

### Step 1 — Get a Windows ISO

Download a Windows 10 or 11 ISO from Microsoft. Mount it (double-click) or extract it. The file you need is inside the `sources` folder:

```
D:\sources\install.wim
```
or
```
D:\sources\install.esd
```

### Step 2 — Check available indexes (editions)

A single WIM file contains multiple Windows editions (Home, Pro, Education, etc.), each with its own index number. Check which indexes are available:

```powershell
dism /Get-WimInfo /WimFile:"D:\sources\install.wim"
```

Example output:
```
Index : 1  → Windows 11 Home
Index : 2  → Windows 11 Home N
Index : 3  → Windows 11 Pro
Index : 4  → Windows 11 Pro N
```

Run the script once per index to cover all editions, or target only the edition you use.

### Step 3 — Run the script

Right-click PowerShell → **Run as Administrator**, then:

```powershell
.\Install-DoH-WIM.ps1 -WimPath "D:\sources\install.wim"
```

Targeting a specific edition by index:

```powershell
.\Install-DoH-WIM.ps1 -WimPath "D:\sources\install.wim" -WimIndex 3
```

The script will:
1. Mount the WIM to a temporary folder
2. Load the offline SYSTEM registry hive
3. Inject all 125 DoH server entries
4. Unload the hive
5. Commit and unmount the WIM

Completion takes under a minute on most systems.

### Step 4 — Install Windows

Use the modified WIM to install Windows as normal — bootable USB, deployment share, or any other method. The DoH entries are carried into the installation automatically.

### Step 5 — Configure DoH in Settings (2 minutes)

After installation and first boot:

1. Open **Settings** (Win+I)
2. Go to **Network & Internet → Advanced network settings → DNS Settings**
3. Click **Edit** next to DNS servers
4. Select **Manual**
5. Toggle **IPv4** to On
6. Toggle **IPv6** to On
7. Under **DNS over HTTPS**, select **On (automatic template)**
8. Type your preferred provider's IPv4 address
9. Type your preferred provider's IPv6 address
10. Click **Save** — Windows auto-fills the DoH endpoint

Your DNS is now encrypted from the first configuration.

---

## ESD Files

ISOs downloaded directly from Microsoft often contain `install.esd` (compressed format) instead of `install.wim`. DISM can mount ESD files directly the same way. If you encounter issues, convert to WIM first:

```powershell
dism /Export-Image /SourceImageFile:"D:\sources\install.esd" /SourceIndex:1 /DestinationImageFile:"D:\sources\install.wim" /Compress:max /CheckIntegrity
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

**`reg unload` fails with Access Denied**
Close any open registry editor windows and retry. The script includes `[gc]::Collect()` and a short delay to release PowerShell handles before unloading.

**DISM mount fails**
Ensure no other process has the WIM open. If a previous mount was left dirty, clean it first:
```powershell
dism /Cleanup-Wim
```

**ESD export fails**
Some ESD files require a different compression level:
```powershell
dism /Export-Image /SourceImageFile:install.esd /SourceIndex:1 /DestinationImageFile:install.wim /Compress:fast
```

---

## License

MIT License — No email. No tracking. No accounts.
