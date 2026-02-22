# DNS Providers Reference

Complete list of all 125 DNS-over-HTTPS servers injected by the DoH WIM Installer.

---

## Cloudflare (12 configurations)

**Standard DNS**
- IPv4: `1.1.1.1` → https://cloudflare-dns.com/dns-query
- IPv4: `1.0.0.1` → https://cloudflare-dns.com/dns-query
- IPv6: `2606:4700:4700::1111` → https://cloudflare-dns.com/dns-query
- IPv6: `2606:4700:4700::1001` → https://cloudflare-dns.com/dns-query

**Security (Malware & Phishing Protection)**
- IPv4: `1.1.1.2` → https://security.cloudflare-dns.com/dns-query
- IPv4: `1.0.0.2` → https://security.cloudflare-dns.com/dns-query
- IPv6: `2606:4700:4700::1112` → https://security.cloudflare-dns.com/dns-query
- IPv6: `2606:4700:4700::1002` → https://security.cloudflare-dns.com/dns-query

**Family (Adult Content Filtering)**
- IPv4: `1.1.1.3` → https://family.cloudflare-dns.com/dns-query
- IPv4: `1.0.0.3` → https://family.cloudflare-dns.com/dns-query
- IPv6: `2606:4700:4700::1113` → https://family.cloudflare-dns.com/dns-query
- IPv6: `2606:4700:4700::1003` → https://family.cloudflare-dns.com/dns-query

---

## Control D (26 configurations)

**Malware & Phishing (p0)**
- IPv4: `76.76.2.0` → https://freedns.controld.com/p0
- IPv4: `76.76.10.0` → https://freedns.controld.com/p0
- IPv6: `2606:1a40::` → https://freedns.controld.com/p0
- IPv6: `2606:1a40:1::` → https://freedns.controld.com/p0

**Malware, Phishing, Ads (p1)**
- IPv4: `76.76.2.1` → https://freedns.controld.com/p1
- IPv4: `76.76.10.1` → https://freedns.controld.com/p1
- IPv6: `2606:1a40::1` → https://freedns.controld.com/p1
- IPv6: `2606:1a40:1::1` → https://freedns.controld.com/p1

**Malware, Phishing, Ads, Social Media (p2)**
- IPv4: `76.76.2.2` → https://freedns.controld.com/p2
- IPv4: `76.76.10.2` → https://freedns.controld.com/p2
- IPv6: `2606:1a40::2` → https://freedns.controld.com/p2
- IPv6: `2606:1a40:1::2` → https://freedns.controld.com/p2

**Malware, Phishing, Ads, Social, Trackers (p3)**
- IPv4: `76.76.2.3` → https://freedns.controld.com/p3
- IPv4: `76.76.10.3` → https://freedns.controld.com/p3
- IPv6: `2606:1a40::3` → https://freedns.controld.com/p3
- IPv6: `2606:1a40:1::3` → https://freedns.controld.com/p3

**Family Filter**
- IPv4: `76.76.2.4` → https://freedns.controld.com/family
- IPv4: `76.76.10.4` → https://freedns.controld.com/family
- IPv6: `2606:1a40::4` → https://freedns.controld.com/family
- IPv6: `2606:1a40:1::4` → https://freedns.controld.com/family

**Uncensored**
- IPv4: `76.76.2.5` → https://freedns.controld.com/uncensored
- IPv4: `76.76.10.5` → https://freedns.controld.com/uncensored
- IPv6: `2606:1a40::5` → https://freedns.controld.com/uncensored
- IPv6: `2606:1a40:1::5` → https://freedns.controld.com/uncensored

---

## DNS4EU (16 configurations)

**Protective Filtering**
- IPv4: `86.54.11.1` → https://protective.joindns4.eu/dns-query
- IPv4: `86.54.11.201` → https://protective.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:1` → https://protective.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:201` → https://protective.joindns4.eu/dns-query

**Child Safety**
- IPv4: `86.54.11.12` → https://child.joindns4.eu/dns-query
- IPv4: `86.54.11.212` → https://child.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:12` → https://child.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:212` → https://child.joindns4.eu/dns-query

**Ad Blocking**
- IPv4: `86.54.11.13` → https://noads.joindns4.eu/dns-query
- IPv4: `86.54.11.213` → https://noads.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:13` → https://noads.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:213` → https://noads.joindns4.eu/dns-query

**Child Safety + Ad Blocking**
- IPv4: `86.54.11.11` → https://child-noads.joindns4.eu/dns-query
- IPv4: `86.54.11.211` → https://child-noads.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:11` → https://child-noads.joindns4.eu/dns-query
- IPv6: `2a13:1001::86:54:11:211` → https://child-noads.joindns4.eu/dns-query

---

## Quad9 (13 configurations)

**Standard (Malware & Phishing)**
- IPv4: `9.9.9.9` → https://dns.quad9.net/dns-query
- IPv4: `149.112.112.112` → https://dns.quad9.net/dns-query
- IPv6: `2620:fe::9` → https://dns.quad9.net/dns-query
- IPv6: `2620:fe::fe` → https://dns.quad9.net/dns-query

**Malware + DNSSEC**
- IPv4: `9.9.9.10` → https://dns10.quad9.net/dns-query
- IPv4: `149.112.112.9` → https://dns9.quad9.net/dns-query
- IPv6: `2620:fe::10` → https://dns10.quad9.net/dns-query
- IPv6: `2620:fe::fe:10` → https://dns10.quad9.net/dns-query

**ECS Disabled**
- IPv4: `9.9.9.11` → https://dns11.quad9.net/dns-query
- IPv4: `149.112.112.11` → https://dns11.quad9.net/dns-query
- IPv6: `2620:fe::11` → https://dns11.quad9.net/dns-query
- IPv6: `2620:fe::fe:11` → https://dns11.quad9.net/dns-query

---

## Google DNS (6 configurations)

**Standard**
- IPv4: `8.8.8.8` → https://dns.google/dns-query
- IPv4: `8.8.4.4` → https://dns.google/dns-query
- IPv6: `2001:4860:4860::8888` → https://dns.google/dns-query
- IPv6: `2001:4860:4860::8844` → https://dns.google/dns-query

**IPv6 DNS64**
- IPv6: `2001:4860:4860::64` → https://dns64.dns.google/dns-query
- IPv6: `2001:4860:4860::6464` → https://dns64.dns.google/dns-query

---

## Mullvad DNS (10 configurations)

**Standard**
- IPv4: `194.242.2.2` → https://dns.mullvad.net/dns-query
- IPv6: `2a07:e340::2` → https://dns.mullvad.net/dns-query

**Adblock**
- IPv4: `194.242.2.3` → https://adblock.dns.mullvad.net/dns-query
- IPv6: `2a07:e340::3` → https://adblock.dns.mullvad.net/dns-query

**Base (Malware Blocking)**
- IPv4: `194.242.2.4` → https://base.dns.mullvad.net/dns-query
- IPv6: `2a07:e340::4` → https://base.dns.mullvad.net/dns-query

**Extended (Malware + Phishing + Adult)**
- IPv4: `194.242.2.5` → https://extended.dns.mullvad.net/dns-query
- IPv6: `2a07:e340::5` → https://extended.dns.mullvad.net/dns-query

**Family Filter**
- IPv4: `194.242.2.6` → https://family.dns.mullvad.net/dns-query
- IPv6: `2a07:e340::6` → https://family.dns.mullvad.net/dns-query

**All Protections**
- IPv4: `194.242.2.9` → https://all.dns.mullvad.net/dns-query
- IPv6: `2a07:e340::9` → https://all.dns.mullvad.net/dns-query

---

## AdGuard DNS (12 configurations)

**Standard**
- IPv4: `94.140.14.14` → https://dns.adguard-dns.com/dns-query
- IPv4: `94.140.15.15` → https://dns.adguard-dns.com/dns-query
- IPv6: `2a10:50c0::ad1:ff` → https://dns.adguard-dns.com/dns-query
- IPv6: `2a10:50c0::ad2:ff` → https://dns.adguard-dns.com/dns-query

**Family Filter**
- IPv4: `94.140.14.15` → https://family.adguard-dns.com/dns-query
- IPv4: `94.140.15.16` → https://family.adguard-dns.com/dns-query
- IPv6: `2a10:50c0::bad1:ff` → https://family.adguard-dns.com/dns-query
- IPv6: `2a10:50c0::bad2:ff` → https://family.adguard-dns.com/dns-query

**Unfiltered**
- IPv4: `94.140.14.140` → https://unfiltered.adguard-dns.com/dns-query
- IPv4: `94.140.14.141` → https://unfiltered.adguard-dns.com/dns-query
- IPv6: `2a10:50c0::1:ff` → https://unfiltered.adguard-dns.com/dns-query
- IPv6: `2a10:50c0::2:ff` → https://unfiltered.adguard-dns.com/dns-query

---

## OpenDNS (12 configurations)

**Resolver (Standard)**
- IPv4: `208.67.222.222` → https://dns.opendns.com/dns-query
- IPv4: `208.67.220.220` → https://dns.opendns.com/dns-query
- IPv6: `2620:119:35::35` → https://dns.opendns.com/dns-query
- IPv6: `2620:119:53::53` → https://dns.opendns.com/dns-query

**FamilyShield**
- IPv4: `208.67.222.123` → https://familyshield.opendns.com/dns-query
- IPv4: `208.67.220.123` → https://familyshield.opendns.com/dns-query
- IPv6: `2620:119:35::123` → https://familyshield.opendns.com/dns-query
- IPv6: `2620:119:53::123` → https://familyshield.opendns.com/dns-query

**Sandbox (No Content Filtering)**
- IPv4: `208.67.222.2` → https://sandbox.opendns.com/dns-query
- IPv4: `208.67.220.2` → https://sandbox.opendns.com/dns-query
- IPv6: `2620:0:ccc::2` → https://sandbox.opendns.com/dns-query
- IPv6: `2620:0:ccd::2` → https://sandbox.opendns.com/dns-query

---

## Clean Browsing (12 configurations)

**Family Filter**
- IPv4: `185.228.168.168` → https://doh.cleanbrowsing.org/doh/family-filter/
- IPv4: `185.228.169.168` → https://doh.cleanbrowsing.org/doh/family-filter/
- IPv6: `2a0d:2a00:1::` → https://doh.cleanbrowsing.org/doh/family-filter/
- IPv6: `2a0d:2a00:2::` → https://doh.cleanbrowsing.org/doh/family-filter/

**Adult Filter**
- IPv4: `185.228.168.10` → https://doh.cleanbrowsing.org/doh/adult-filter/
- IPv4: `185.228.169.11` → https://doh.cleanbrowsing.org/doh/adult-filter/
- IPv6: `2a0d:2a00:1::1` → https://doh.cleanbrowsing.org/doh/adult-filter/
- IPv6: `2a0d:2a00:2::1` → https://doh.cleanbrowsing.org/doh/adult-filter/

**Security Filter**
- IPv4: `185.228.168.9` → https://doh.cleanbrowsing.org/doh/security-filter/
- IPv4: `185.228.169.9` → https://doh.cleanbrowsing.org/doh/security-filter/
- IPv6: `2a0d:2a00:1::2` → https://doh.cleanbrowsing.org/doh/security-filter/
- IPv6: `2a0d:2a00:2::2` → https://doh.cleanbrowsing.org/doh/security-filter/

---

## LibreDNS (2 configurations)

**Ad-blocking**
- IPv4: `116.202.176.26` → https://doh.libredns.gr/noads
- IPv6: `2a01:4f8:1c0c:8274::1` → https://doh.libredns.gr/noads

---

## Uncensored DNS (4 configurations)

**Anycast**
- IPv4: `91.239.100.100` → https://anycast.uncensoreddns.org/dns-query
- IPv6: `2001:67c:28a4::` → https://anycast.uncensoreddns.org/dns-query

**Unicast**
- IPv4: `89.233.43.71` → https://unicast.uncensoreddns.org/dns-query
- IPv6: `2a01:3a0:53:53::` → https://unicast.uncensoreddns.org/dns-query

---

## Quick Provider Comparison

| Provider | Type | IPv4 | IPv6 | Best For |
|---|---|---|---|---|
| Cloudflare | Tiered | 1.1.1.1 | 2606:4700:4700::1111 | Speed + Reliability |
| Control D | Multi-filter | 76.76.2.x | 2606:1a40::x | Granular Control |
| DNS4EU | Multi-filter | 86.54.11.x | 2a13:1001::... | European Privacy |
| Quad9 | Security | 9.9.9.9 | 2620:fe::9 | Non-profit Security |
| Google | Standard | 8.8.8.8 | 2001:4860:4860::8888 | Performance |
| Mullvad | Privacy-first | 194.242.2.2 | 2a07:e340::2 | Privacy + Adblock |
| AdGuard | Multi-filter | 94.140.14.14 | 2a10:50c0::ad1:ff | All-in-one |
| OpenDNS | Enterprise | 208.67.222.222 | 2620:119:35::35 | Business Use |
| Clean Browsing | Family | 185.228.168.168 | 2a0d:2a00:1:: | Family Safety |
| LibreDNS | Minimal | 116.202.176.26 | 2a01:4f8:1c0c:8274::1 | Lightweight |
| Uncensored DNS | No-filter | 91.239.100.100 | 2001:67c:28a4:: | Unrestricted |
