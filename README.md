# DoH WIM Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2B-0078d4)](https://microsoft.com)
[![Built with](https://img.shields.io/badge/Built%20with-PowerShell-5391FE)](https://microsoft.com/powershell)
[![Part of](https://img.shields.io/badge/Part%20of-DoH%20Windows%20Installer%20Suite-green)](https://github.com/1LUC1D4710N/doh-windows-installer)

**Bake 125 DoH servers into Windows before it even installs.**

Injects all 125 DNS-over-HTTPS Well-Known Server entries directly into a Windows `install.wim` or `install.esd` image — offline, before installation. When Windows is installed from the modified image, every provider is pre-registered from first boot. No post-install tool needed.

Part of the [DoH Windows Installer](https://github.com/1LUC1D4710N/doh-windows-installer) suite.

---

## How It Works

The script uses DISM to mount the WIM image, loads the offline `SYSTEM` registry hive, and writes all 125 DoH entries to:

- `HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\DohWellKnownServers`
- `HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\GlobalDohIP`

The image is then committed and unmounted. The changes are baked in — Windows Setup carries them into every installation from that image.

---

## Prerequisites

- Windows 10 or Windows 11 (DISM is built-in — no extra installs)
- PowerShell 5.1 or later (built-in)
- **Run as Administrator**
- A `install.wim` or `install.esd` from a Windows ISO

---

## Usage

**1. Find your WIM index** (one index per Windows edition — Home, Pro, etc.):

```powershell
dism /Get-WimInfo /WimFile:"D:\sources\install.wim"
```

**2. Run the script:**

```powershell
.\Install-DoH-WIM.ps1 -WimPath "D:\sources\install.wim"
```

Or target a specific edition index:

```powershell
.\Install-DoH-WIM.ps1 -WimPath "D:\sources\install.wim" -WimIndex 6
```

**3. Install Windows** from the modified WIM. DoH providers are pre-registered on first boot.

**4. Configure in Settings** (takes 2 minutes):

1. Open Settings → Network & Internet → Advanced network settings → DNS Settings
2. Click **Edit** next to DNS servers
3. Select **Manual** → Toggle IPv4 and IPv6 On
4. Under **DNS over HTTPS**, select **On (automatic template)**
5. Type your preferred DNS provider's IPv4 and IPv6 address
6. Click **Save** — Windows auto-fills the DoH endpoint

---

## ESD Files

ISOs downloaded directly from Microsoft often use `install.esd` (compressed) instead of `install.wim`. DISM can mount ESD files the same way. If you encounter issues, convert first:

```powershell
dism /Export-Image /SourceImageFile:install.esd /SourceIndex:1 /DestinationImageFile:install.wim /Compress:max /CheckIntegrity
```

Then run the script against the exported `install.wim`.

---

## Supported Providers

| Provider | Type | IPv4 | Best For |
|---|---|---|---|
| Cloudflare | Tiered | 1.1.1.1 | Speed + Reliability |
| Control D | Multi-filter | 76.76.2.x | Granular Control |
| DNS4EU | Multi-filter | 86.54.11.x | European Privacy |
| Quad9 | Security | 9.9.9.9 | Non-profit Security |
| Google | Standard | 8.8.8.8 | Performance |
| Mullvad | Privacy-first | 194.242.2.2 | Privacy + Adblock |
| AdGuard | Multi-filter | 94.140.14.14 | All-in-one Protection |
| OpenDNS | Enterprise | 208.67.222.222 | Business Use |
| Clean Browsing | Family | 185.228.168.168 | Family Safety |
| LibreDNS | Minimal | 116.202.176.26 | Lightweight |
| Uncensored DNS | No-filter | 91.239.100.100 | Unrestricted |

**125 configurations total — IPv4 and IPv6 for all providers.**

→ [See full DNS Providers Reference](https://github.com/1LUC1D4710N/doh-windows-installer/blob/master/DNS-PROVIDERS-REFERENCE.md) for all IPs and DoH endpoints.

---

## Why This Exists

Microsoft's built-in `DohWellKnownServers` list has not been updated since 2020 or earlier. This means many modern DNS providers are not recognized out-of-the-box, and Windows cannot auto-template them in DNS Settings. This tool — and the broader DoH Windows Installer suite — fills that gap for both live systems and fresh installations.

---

## License

MIT License — No email. No tracking. No accounts.
