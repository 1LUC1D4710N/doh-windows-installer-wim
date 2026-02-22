#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Injects DoH Well-Known Servers into a Windows WIM/ESD image offline.
.DESCRIPTION
    Mounts a Windows WIM or ESD image using DISM, loads the offline SYSTEM
    registry hive, and injects all 125 DNS-over-HTTPS (DoH) Well-Known Server
    entries. The image is then committed and unmounted. After installing Windows
    from the modified image, all providers are pre-registered — no post-install
    tool required.
.PARAMETER WimPath
    Full path to install.wim or install.esd
.PARAMETER WimIndex
    Image index to modify (default: 1).
    Use 'dism /Get-WimInfo /WimFile:<path>' to list available indexes.
.PARAMETER AllIndexes
    Automatically detect and process all indexes found in the WIM.
    Overrides -WimIndex when specified.
.EXAMPLE
    .\Install-DoH-WIM.ps1 -WimPath "D:\ISO\sources\install.wim"
.EXAMPLE
    .\Install-DoH-WIM.ps1 -WimPath "D:\ISO\sources\install.wim" -WimIndex 6
.EXAMPLE
    .\Install-DoH-WIM.ps1 -WimPath "D:\ISO\sources\install.wim" -AllIndexes
#>

param(
    [Parameter(Mandatory)][string]$WimPath,
    [int]$WimIndex = 1,
    [switch]$AllIndexes
)

$DohServers = @{
    # Cloudflare
    "1.0.0.1"                    = "https://cloudflare-dns.com/dns-query"
    "1.0.0.2"                    = "https://security.cloudflare-dns.com/dns-query"
    "1.0.0.3"                    = "https://family.cloudflare-dns.com/dns-query"
    "1.1.1.1"                    = "https://cloudflare-dns.com/dns-query"
    "1.1.1.2"                    = "https://security.cloudflare-dns.com/dns-query"
    "1.1.1.3"                    = "https://family.cloudflare-dns.com/dns-query"
    "2606:4700:4700::1001"        = "https://cloudflare-dns.com/dns-query"
    "2606:4700:4700::1002"        = "https://security.cloudflare-dns.com/dns-query"
    "2606:4700:4700::1003"        = "https://family.cloudflare-dns.com/dns-query"
    "2606:4700:4700::1111"        = "https://cloudflare-dns.com/dns-query"
    "2606:4700:4700::1112"        = "https://security.cloudflare-dns.com/dns-query"
    "2606:4700:4700::1113"        = "https://family.cloudflare-dns.com/dns-query"
    # Control D
    "76.76.2.0"                   = "https://freedns.controld.com/p0"
    "76.76.10.0"                  = "https://freedns.controld.com/p0"
    "76.76.2.1"                   = "https://freedns.controld.com/p1"
    "76.76.10.1"                  = "https://freedns.controld.com/p1"
    "76.76.2.2"                   = "https://freedns.controld.com/p2"
    "76.76.10.2"                  = "https://freedns.controld.com/p2"
    "76.76.2.3"                   = "https://freedns.controld.com/p3"
    "76.76.10.3"                  = "https://freedns.controld.com/p3"
    "76.76.2.4"                   = "https://freedns.controld.com/family"
    "76.76.10.4"                  = "https://freedns.controld.com/family"
    "76.76.2.5"                   = "https://freedns.controld.com/uncensored"
    "76.76.10.5"                  = "https://freedns.controld.com/uncensored"
    "2606:1a40::"                 = "https://freedns.controld.com/p0"
    "2606:1a40:1::"               = "https://freedns.controld.com/p0"
    "2606:1a40::1"                = "https://freedns.controld.com/p1"
    "2606:1a40:1::1"              = "https://freedns.controld.com/p1"
    "2606:1a40::2"                = "https://freedns.controld.com/p2"
    "2606:1a40:1::2"              = "https://freedns.controld.com/p2"
    "2606:1a40::3"                = "https://freedns.controld.com/p3"
    "2606:1a40:1::3"              = "https://freedns.controld.com/p3"
    "2606:1a40::4"                = "https://freedns.controld.com/family"
    "2606:1a40:1::4"              = "https://freedns.controld.com/family"
    "2606:1a40::5"                = "https://freedns.controld.com/uncensored"
    "2606:1a40:1::5"              = "https://freedns.controld.com/uncensored"
    # DNS4EU
    "86.54.11.1"                  = "https://protective.joindns4.eu/dns-query"
    "86.54.11.201"                = "https://protective.joindns4.eu/dns-query"
    "86.54.11.12"                 = "https://child.joindns4.eu/dns-query"
    "86.54.11.212"                = "https://child.joindns4.eu/dns-query"
    "86.54.11.13"                 = "https://noads.joindns4.eu/dns-query"
    "86.54.11.213"                = "https://noads.joindns4.eu/dns-query"
    "86.54.11.11"                 = "https://child-noads.joindns4.eu/dns-query"
    "86.54.11.211"                = "https://child-noads.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:1"       = "https://protective.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:201"     = "https://protective.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:12"      = "https://child.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:212"     = "https://child.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:13"      = "https://noads.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:213"     = "https://noads.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:11"      = "https://child-noads.joindns4.eu/dns-query"
    "2a13:1001::86:54:11:211"     = "https://child-noads.joindns4.eu/dns-query"
    # Quad9
    "9.9.9.9"                     = "https://dns.quad9.net/dns-query"
    "149.112.112.112"             = "https://dns.quad9.net/dns-query"
    "9.9.9.10"                    = "https://dns10.quad9.net/dns-query"
    "9.9.9.11"                    = "https://dns11.quad9.net/dns-query"
    "149.112.112.9"               = "https://dns9.quad9.net/dns-query"
    "149.112.112.11"              = "https://dns11.quad9.net/dns-query"
    "2620:fe::9"                  = "https://dns.quad9.net/dns-query"
    "2620:fe::fe"                 = "https://dns.quad9.net/dns-query"
    "2620:fe::fe:9"               = "https://dns9.quad9.net/dns-query"
    "2620:fe::10"                 = "https://dns10.quad9.net/dns-query"
    "2620:fe::fe:10"              = "https://dns10.quad9.net/dns-query"
    "2620:fe::11"                 = "https://dns11.quad9.net/dns-query"
    "2620:fe::fe:11"              = "https://dns11.quad9.net/dns-query"
    # Google
    "8.8.8.8"                     = "https://dns.google/dns-query"
    "8.8.4.4"                     = "https://dns.google/dns-query"
    "2001:4860:4860::8888"        = "https://dns.google/dns-query"
    "2001:4860:4860::8844"        = "https://dns.google/dns-query"
    "2001:4860:4860::64"          = "https://dns64.dns.google/dns-query"
    "2001:4860:4860::6464"        = "https://dns64.dns.google/dns-query"
    # Mullvad
    "194.242.2.2"                 = "https://dns.mullvad.net/dns-query"
    "194.242.2.3"                 = "https://adblock.dns.mullvad.net/dns-query"
    "194.242.2.4"                 = "https://base.dns.mullvad.net/dns-query"
    "194.242.2.5"                 = "https://extended.dns.mullvad.net/dns-query"
    "194.242.2.6"                 = "https://family.dns.mullvad.net/dns-query"
    "194.242.2.9"                 = "https://all.dns.mullvad.net/dns-query"
    "2a07:e340::2"                = "https://dns.mullvad.net/dns-query"
    "2a07:e340::3"                = "https://adblock.dns.mullvad.net/dns-query"
    "2a07:e340::4"                = "https://base.dns.mullvad.net/dns-query"
    "2a07:e340::5"                = "https://extended.dns.mullvad.net/dns-query"
    "2a07:e340::6"                = "https://family.dns.mullvad.net/dns-query"
    "2a07:e340::9"                = "https://all.dns.mullvad.net/dns-query"
    # AdGuard
    "94.140.14.14"                = "https://dns.adguard-dns.com/dns-query"
    "94.140.15.15"                = "https://dns.adguard-dns.com/dns-query"
    "94.140.14.15"                = "https://family.adguard-dns.com/dns-query"
    "94.140.15.16"                = "https://family.adguard-dns.com/dns-query"
    "94.140.14.140"               = "https://unfiltered.adguard-dns.com/dns-query"
    "94.140.14.141"               = "https://unfiltered.adguard-dns.com/dns-query"
    "2a10:50c0::ad1:ff"           = "https://dns.adguard-dns.com/dns-query"
    "2a10:50c0::ad2:ff"           = "https://dns.adguard-dns.com/dns-query"
    "2a10:50c0::bad1:ff"          = "https://family.adguard-dns.com/dns-query"
    "2a10:50c0::bad2:ff"          = "https://family.adguard-dns.com/dns-query"
    "2a10:50c0::1:ff"             = "https://unfiltered.adguard-dns.com/dns-query"
    "2a10:50c0::2:ff"             = "https://unfiltered.adguard-dns.com/dns-query"
    # OpenDNS
    "208.67.222.222"              = "https://dns.opendns.com/dns-query"
    "208.67.220.220"              = "https://dns.opendns.com/dns-query"
    "208.67.222.123"              = "https://familyshield.opendns.com/dns-query"
    "208.67.220.123"              = "https://familyshield.opendns.com/dns-query"
    "208.67.222.2"                = "https://sandbox.opendns.com/dns-query"
    "208.67.220.2"                = "https://sandbox.opendns.com/dns-query"
    "2620:119:35::35"             = "https://dns.opendns.com/dns-query"
    "2620:119:53::53"             = "https://dns.opendns.com/dns-query"
    "2620:119:35::123"            = "https://familyshield.opendns.com/dns-query"
    "2620:119:53::123"            = "https://familyshield.opendns.com/dns-query"
    "2620:0:ccc::2"               = "https://sandbox.opendns.com/dns-query"
    "2620:0:ccd::2"               = "https://sandbox.opendns.com/dns-query"
    # Clean Browsing
    "185.228.168.168"             = "https://doh.cleanbrowsing.org/doh/family-filter/"
    "185.228.169.168"             = "https://doh.cleanbrowsing.org/doh/family-filter/"
    "185.228.168.10"              = "https://doh.cleanbrowsing.org/doh/adult-filter/"
    "185.228.169.11"              = "https://doh.cleanbrowsing.org/doh/adult-filter/"
    "185.228.168.9"               = "https://doh.cleanbrowsing.org/doh/security-filter/"
    "185.228.169.9"               = "https://doh.cleanbrowsing.org/doh/security-filter/"
    "2a0d:2a00:1::"               = "https://doh.cleanbrowsing.org/doh/family-filter/"
    "2a0d:2a00:2::"               = "https://doh.cleanbrowsing.org/doh/security-filter/"
    "2a0d:2a00:1::1"              = "https://doh.cleanbrowsing.org/doh/adult-filter/"
    "2a0d:2a00:2::1"              = "https://doh.cleanbrowsing.org/doh/adult-filter/"
    "2a0d:2a00:1::2"              = "https://doh.cleanbrowsing.org/doh/security-filter/"
    "2a0d:2a00:2::2"              = "https://doh.cleanbrowsing.org/doh/security-filter/"
    # LibreDNS
    "116.202.176.26"              = "https://doh.libredns.gr/noads"
    "2a01:4f8:1c0c:8274::1"      = "https://doh.libredns.gr/noads"
    # Uncensored DNS
    "91.239.100.100"              = "https://anycast.uncensoreddns.org/dns-query"
    "89.233.43.71"                = "https://unicast.uncensoreddns.org/dns-query"
    "2001:67c:28a4::"             = "https://anycast.uncensoreddns.org/dns-query"
    "2a01:3a0:53:53::"            = "https://unicast.uncensoreddns.org/dns-query"
}

$DohFlags = [byte[]](0x11,0x00,0x00,0x00,0x00,0x00,0x00,0x00)

function Get-AllWimIndexes {
    param([string]$Path)
    $output = dism /Get-WimInfo /WimFile:"$Path" 2>&1
    $indexes = $output | Where-Object { $_ -match "^\s*Index\s*:\s*\d+" } | ForEach-Object {
        [int]($_.Trim() -replace "Index\s*:\s*", "")
    }
    return $indexes
}

function Invoke-DohInjection {
    param([string]$WimFilePath, [int]$Index, [int]$Total)

    $MountDir  = "$env:TEMP\DoH-WIM-Mount-$Index"
    $HivePath  = "$MountDir\Windows\System32\config\SYSTEM"
    $HiveAlias = "HKLM\OFFLINE_SYSTEM_$Index"
    $WellKnown = "HKLM:\OFFLINE_SYSTEM_$Index\CurrentControlSet\Services\Dnscache\Parameters\DohWellKnownServers"
    $GlobalDoh = "HKLM:\OFFLINE_SYSTEM_$Index\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\GlobalDohIP"

    Write-Host ""
    Write-Host "──────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  Index $Index of $Total" -ForegroundColor Cyan
    Write-Host "──────────────────────────────────────────" -ForegroundColor DarkGray

    try {
        # Mount
        Write-Host "  Mounting index $Index..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Force -Path $MountDir | Out-Null
        dism /Mount-Wim /WimFile:"$WimFilePath" /Index:$Index /MountDir:"$MountDir" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "DISM mount failed (exit $LASTEXITCODE)." }
        Write-Host "  ✓ Mounted." -ForegroundColor Green

        # Load hive
        Write-Host "  Loading SYSTEM hive..." -ForegroundColor Cyan
        reg load $HiveAlias "$HivePath" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Hive load failed." }
        Write-Host "  ✓ Hive loaded." -ForegroundColor Green

        # Inject
        Write-Host "  Injecting $($DohServers.Count) DoH servers..." -ForegroundColor Cyan
        foreach ($entry in $DohServers.GetEnumerator()) {
            $ip  = $entry.Key
            $url = $entry.Value
            $wkPath = "$WellKnown\$ip"
            New-Item -Path $wkPath -Force | Out-Null
            Set-ItemProperty -Path $wkPath -Name "Template" -Value $url
            $gdPath = "$GlobalDoh\$ip"
            New-Item -Path $gdPath -Force | Out-Null
            Set-ItemProperty -Path $gdPath -Name "DohTemplate" -Value $url
            Set-ItemProperty -Path $gdPath -Name "DohFlags"    -Value $DohFlags -Type Binary
        }
        Write-Host "  ✓ $($DohServers.Count) servers injected." -ForegroundColor Green

        # Unload hive
        Write-Host "  Unloading hive..." -ForegroundColor Cyan
        [gc]::Collect()
        Start-Sleep -Milliseconds 500
        reg unload $HiveAlias | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Hive unload failed. Handles may still be open." }
        Write-Host "  ✓ Hive unloaded." -ForegroundColor Green

        # Commit and unmount
        Write-Host "  Committing and unmounting..." -ForegroundColor Cyan
        dism /Unmount-Wim /MountDir:"$MountDir" /Commit | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "DISM commit/unmount failed (exit $LASTEXITCODE)." }
        Write-Host "  ✓ Index $Index complete." -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "  ✗ ERROR on index ${Index}: $_" -ForegroundColor Red
        Write-Host "  Attempting cleanup (discard)..." -ForegroundColor Yellow
        [gc]::Collect()
        reg unload $HiveAlias 2>$null
        dism /Unmount-Wim /MountDir:"$MountDir" /Discard 2>$null
        return $false
    }
    finally {
        Remove-Item -Path $MountDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ── Banner ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔════════════════════════════════════════╗"
Write-Host "║   DoH WIM Installer                    ║"
Write-Host "║   Offline DNS-over-HTTPS Injector      ║"
Write-Host "╚════════════════════════════════════════╝"

# ── Validate path ──────────────────────────────────────────────────────────
if (-not (Test-Path $WimPath)) {
    Write-Host "`n✗ WIM/ESD file not found: $WimPath" -ForegroundColor Red
    exit 1
}

# ── Determine indexes to process ───────────────────────────────────────────
if ($AllIndexes) {
    Write-Host "`nDetecting all indexes in: $WimPath" -ForegroundColor Cyan
    $indexList = Get-AllWimIndexes -Path $WimPath
    if (-not $indexList -or $indexList.Count -eq 0) {
        Write-Host "✗ Could not detect any indexes. Check the WIM path." -ForegroundColor Red
        exit 1
    }
    Write-Host "Found $($indexList.Count) indexes: $($indexList -join ', ')" -ForegroundColor Green
} else {
    $indexList = @($WimIndex)
}

$total   = $indexList.Count
$passed  = @()
$failed  = @()

# ── Process each index ─────────────────────────────────────────────────────
foreach ($idx in $indexList) {
    $ok = Invoke-DohInjection -WimFilePath $WimPath -Index $idx -Total $total
    if ($ok) { $passed += $idx } else { $failed += $idx }
}

# ── Summary ────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════"
Write-Host "  Summary: $($passed.Count) of $total indexes completed."
if ($passed.Count -gt 0) {
    Write-Host "  ✓ Passed : $($passed -join ', ')" -ForegroundColor Green
}
if ($failed.Count -gt 0) {
    Write-Host "  ✗ Failed : $($failed -join ', ')" -ForegroundColor Red
}
Write-Host "══════════════════════════════════════════"
Write-Host ""
