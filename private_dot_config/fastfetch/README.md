# Fastfetch

Fastfetch ersetzt neofetch da neofetch nicht mehr weiter entwickelt wird.
Fastfetch ist ein schnelles und flexibles System-Informations-Tool, das in der Arch-basierten Community beliebt ist.

https://github.com/fastfetch-cli/fastfetch
Fastfetch is a neofetch-like tool for fetching system information and displaying it prettily. It is written mainly in C, with performance and customizability in mind. Currently, Linux, Android, FreeBSD, macOS, SunOS and Windows 7+ are supported.

Arch:
`pacman -S fastfetch`

Debian:
`apt install fastfetch`

Fastfetch-Kommandoliste:

| Beschreibung | Command |
| ---------------------------- | ------------------------------- |
| Hilfe und Befehlsliste | `fastfetch --help` |
| Konfigurationspfade anzeigen | `fastfetch --list-config-paths` |
| Mit allen Modulen ausführen | `fastfetch --full` oder `fastfetch -a` |
| Nur bestimmte Module anzeigen | `fastfetch -s [Modulname1,Modulname2,...]` |
| Bestimmte Module ausschließen | `fastfetch -S [Modulname1,Modulname2,...]` |
| Verfügbare Module auflisten | `fastfetch --list-modules` |
| Verfügbare Farben anzeigen | `fastfetch --list-colors` |
| Verfügbare Logos auflisten | `fastfetch --list-logos` |
| Benutzerdefiniertes Logo verwenden | `fastfetch -l [LogoName]` |
| ASCII-Logo anstelle von Unicode | `fastfetch --logo-type ascii` |
| Kleine Logo-Version anzeigen | `fastfetch --logo-type small` |
| Ausgabe in JSON-Format | `fastfetch --format json` |
| Benutzerdefinierte Konfigurationsdatei | `fastfetch -c /pfad/zur/config` |
| Detaillierte System-Infos | `fastfetch --structure-detailed` |
| Kompakte Ausgabe | `fastfetch --structure-basic` |
| Nur Logo anzeigen | `fastfetch --logo-only` |
| Keine Farben verwenden | `fastfetch --color-disable` |
| Benutzerdefinierte Farbpalette | `fastfetch --color-keys [Farbe]` |
| Leistungsmessung | `fastfetch --stat` |
| Mit bestimmtem Ausgabeformat | `fastfetch --format [json/yaml/xml/...]` |


### Releases
https://github.com/fastfetch-cli/fastfetch/releases/

```
sudo apt install wget
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.11.5/fastfetch-linux-amd64.deb
```