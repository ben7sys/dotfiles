**Standardisierte (XDG) Pfade**

| Verzeichnis                    | Zweck                                      | XDG-Variable (Default)                 |
| ------------------------------ | ------------------------------------------ | -------------------------------------- |
| `~/.config/`                   | Benutzer‑Konfigurationen                   | `$XDG_CONFIG_HOME` (`~/.config`)       |
| `~/.local/share/`              | Benutzer‑Daten (keine Konfig)              | `$XDG_DATA_HOME` (`~/.local/share`)    |
| `~/.cache/`                    | Caches/temporäre Daten                     | `$XDG_CACHE_HOME` (`~/.cache`)         |
| `~/.local/state/`              | Zustandsdaten (Logs, History)              | `$XDG_STATE_HOME` (`~/.local/state`)   |
| `~/.local/bin/`                | Benutzer‑Executables (Empfehlung der Spec) | *(kein XDG‑Var; explizite Empfehlung)* |
| `/run/user/<UID>/`             | Laufzeit‑Dateien (Sockets, Pipes …)        | `$XDG_RUNTIME_DIR` (systemd setzt)     |
| `~/.config/systemd/user/`      | **eigene** systemd‑User‑Units              | *(unter `$XDG_CONFIG_HOME`)*           |
| `~/.local/share/systemd/user/` | per‑User **installierte** Units (Data)     | *(unter `$XDG_DATA_HOME`)*             |
| `~/.local/share/fonts/`        | Benutzer‑Schriftarten                      | *(unter `$XDG_DATA_HOME`)*             |
| `~/.local/share/icons/`        | Benutzer‑Icon‑Themes                       | *(unter `$XDG_DATA_HOME`)*             |

**Hinweise & Quellen (Kernpunkte):**

* XDG‑Defaults für **config/data/state/cache** sowie die Definitionen: freedesktop Spec. ([specifications.freedesktop.org][1])
* **Executables:** Die Spec empfiehlt ausdrücklich `~/.local/bin` und dass Distros es in den `PATH` aufnehmen. ([specifications.freedesktop.org][1])
* **`XDG_RUNTIME_DIR`** (typisch `/run/user/<UID>`), Eigenschaften/Zweck: man‑/Arch‑Dokumentation. ([ArchWiki][2], [Ask Ubuntu][3])
* **systemd User‑Units**: Suchpfade inkl. `~/.config/systemd/user/` **und** `~/.local/share/systemd/user/`. ([freedesktop.org][4], [man.archlinux.org][5])
* **Fonts:** User‑Installation unter `~/.local/share/fonts/` (statt altem `~/.fonts/`). ([ArchWiki][6])
* **Icons:** User‑Pfad unter `$XDG_DATA_HOME/icons` ist üblich; Fallback auf `~/.icons` wird noch von einigen Tools beachtet. ([ArchWiki][7], [Ask Ubuntu][8])
* **Wallpapers:** Es gibt **kein** offizielles XDG‑Standardverzeichnis. Sinnvoll ist eine eigene Ordnerstruktur unter `$XDG_DATA_HOME` (z. B. `~/.local/share/wallpapers/`). GNOME kann zusätzliche Hintergründe über XML unter `~/.local/share/gnome-background-properties/` referenzieren; systemweite liegen oft unter `/usr/share/backgrounds/`. KDE nutzt u. a. `/usr/share/wallpapers/`. ([Unix & Linux Stack Exchange][9], [docs.redhat.com][10], [Ask Ubuntu][11])

**[sources]**
[1]: https://specifications.freedesktop.org/basedir-spec/latest/?utm_source=chatgpt.com "XDG Base Directory Specification"
[2]: https://wiki.archlinux.org/title/XDG_Base_Directory?utm_source=chatgpt.com "XDG Base Directory - ArchWiki"
[3]: https://askubuntu.com/questions/872792/what-is-xdg-runtime-dir?utm_source=chatgpt.com "command line - What is XDG_RUNTIME_DIR?"
[4]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html?utm_source=chatgpt.com "systemd.unit"
[5]: https://man.archlinux.org/man/systemd.unit.5?utm_source=chatgpt.com "systemd.unit(5) — Arch manual pages"
[6]: https://wiki.archlinux.org/title/Fonts?utm_source=chatgpt.com "Fonts - ArchWiki"
[7]: https://wiki.archlinux.org/title/Icons?utm_source=chatgpt.com "Icons - ArchWiki"
[8]: https://askubuntu.com/questions/435603/desktop-files-how-to-specify-the-icon-path?utm_source=chatgpt.com "desktop files: how to specify the icon path [duplicate]"
[9]: https://unix.stackexchange.com/questions/134141/how-to-have-user-directory-for-gnome-wallpapers?utm_source=chatgpt.com "How to have user directory for GNOME wallpapers"
[10]: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/customizing_the_gnome_desktop_environment/customizing-desktop-appearance-and-branding_customizing-the-gnome-desktop-environment?utm_source=chatgpt.com "Chapter 8. Customizing desktop appearance and branding"
[11]: https://askubuntu.com/questions/1120432/how-to-add-entire-folder-of-wallpapers-in-kde-plasma-5?utm_source=chatgpt.com "How to add entire folder of wallpapers in KDE plasma 5"
