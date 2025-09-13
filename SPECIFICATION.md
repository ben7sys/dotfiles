# SPECIFICATION — Dotfiles (chezmoi) Repository

Ziel dieses Dokuments ist eine klare, intent‑getriebene Spezifikation des Dotfiles‑Repos. Es beschreibt das „Was“ (Entscheidungen, Ziele, Randbedingungen) vor dem „Wie“ (konkrete Implementierung) und dient als Referenz für Erweiterungen im Sinne von Spec‑Driven Development.

## Ziele

- Produktive, wiederholbare Shell‑Umgebung für Linux (Arch/Debian) und kompatible Distros.
- XDG‑konforme Pfade und saubere Trennung von Config, Daten, Cache, State.
- Zentrale, template‑fähige Umgebungsvariablenverwaltung (einheitlich für POSIX/Bash/Fish).
- Per‑User systemd‑Einheiten (z. B. ssh‑agent) ohne globale Root‑Eingriffe.
- Optionale Tools (fastfetch, rclone) integrieren, aber nicht erzwingen.
- NAS‑Mount‑Workflows (Synology) reproduzierbar, ohne Secrets im Repo.

## Nicht‑Ziele

- Distribution‑spezifische Systemtweaks außerhalb Shell/Benutzerbereich.
- Geheimnisverwaltung im Repo (Secrets bleiben lokal/extern).
- Vollständiges Provisioning ganzer Systeme (nur ausgewählte Helper‑Skripte).

## Geltungsbereich / Laufzeitumgebungen

- Primär Linux Desktop/Server; getestet auf Arch/Debian.
- Shells: Bash (interaktiv und Login), POSIX‑/sh, Fish.
- systemd User‑Scope für agent/Socket Units.

## Leitlinien (Guardrails)

- XDG Base Directory strikt einhalten, wo möglich.
- „Feature detection“ vor Distro‑Checks (z. B. `command -v`, Pfad‑Probe).
- Reprozierbar und „opt‑in“ für potentiell intrusive Aktionen (Install/Netzwerk/Admin).
- Templates werden ausschließlich aus `data/env.yaml` gespeist und generieren Shell‑Env.
- Kein Hardcoding sensibler Daten; lokale Overrides via private Dateien/Environment.

## Repository‑Layout (Absicht)

- Dotfiles folgen chezmoi‑Konvention: Dateien mit Präfix `dot_` landen unter `$HOME/.*`, `private_` unter `$XDG_*` im Home‑Scope.
- Zentrale Datenquelle: `data/env.yaml` (einheitliche Quelle für Shell‑Env).
- Systemd‑User‑Units unter `~/.config/systemd/user` via `private_dot_config/systemd/user/*`.
- Optionale Assets (Logos, Wallpapers, Avatare) im `$XDG_DATA_HOME`‑Baum.

Siehe u. a.:
- `XDG_VARS.md:1` — Zusammenfassung XDG‑Pfade.
- `data/env.yaml:1` — zentrale Konfigurationswerte.
- `private_dot_config/fish/conf.d/00-env.fish.tmpl:1` — Fish‑Env Template.
- `dot_env_common.tmpl:1` — POSIX/Bash‑Env Template.
- `private_dot_config/systemd/user/ssh-agent.socket:1` und `private_dot_config/systemd/user/ssh-agent.service:1` — systemd Units.

## Konfigurationsmodell

- Quelle der Wahrheit: `data/env.yaml` (Locale, Editor, `NODE_ENV`, GTK‑Skalierung, Storage/NAS, Pfade wie `~/.local/bin`, `~/.cache/npm-global/bin`).
- Templates rendern zwei Pfade:
  - POSIX/Bash: `~/.env_common` aus `dot_env_common.tmpl:1`.
  - Fish: `~/.config/fish/conf.d/00-env.fish` aus `private_dot_config/fish/conf.d/00-env.fish.tmpl:1`.
- PATH‑Politik: User‑Bin voranstellen, npm‑Global‑Bin optional anhängen.
- Locale‑Fallback: bevorzugt `de_DE.UTF-8`, fallback `C.UTF-8` → `C`.
- SSH_AUTH_SOCK: Standard auf `$XDG_RUNTIME_DIR/ssh-agent.socket` setzen.

## Shell‑Initialisierung (Intent)

- Einheitlicher Einstieg über `~/.profile` für POSIX‑Shells; Bash lädt zusätzlich `~/.bashrc`.
- `~/.bashrc` lädt gemeinsame Env/Aliases/Exports und richtet interaktive Komfortfunktionen ein (dircolors, fastfetch, Prompt, Completion).
- Fish setzt per conf.d‑Snippet PATH/Locale/Editor/GTK u. a. aus Template.

Implementierungsreferenzen:
- `dot_profile:1`, `dot_bash_profile:1`, `dot_bashrc:1`.
- `private_dot_config/fish/config.fish:1`, `private_dot_config/fish/conf.d/00-env.fish.tmpl:1`.

## SSH‑Agent (User‑Scope)

- Socket‑aktivierter ssh‑agent im User‑Namespace; Socket unter `$XDG_RUNTIME_DIR`.
- Vorteil: Kein systemweiter Dienst, Session‑lebenszyklusfreundlich, XDG‑konform.

Implementierungsreferenzen:
- `private_dot_config/systemd/user/ssh-agent.socket:1`
- `private_dot_config/systemd/user/ssh-agent.service:1`
- `dot_env_common.tmpl:1` und `private_dot_config/fish/conf.d/00-env.fish.tmpl:1` (setzt `SSH_AUTH_SOCK`).

## Optionales Tooling

- fastfetch: Start im interaktiven Bash, konfigurierbar über `$XDG_CONFIG_HOME/fastfetch`.
  - Siehe `private_dot_config/fastfetch/*` und `dot_bashrc:1` (Aufruf, Logo/Config‑Pfad).
- rclone: Installation ist „opt‑in“ via Umgebungsvariable; bevorzugt Paketmanager, Fallback offizielles Script; optional Version/Min‑Version.
  - Siehe `run_once_install_rclone.sh:1` (steuert per `RCLONE_*` Env; bricht ab ohne Opt‑In).

## NAS‑Mounts (Synology)

- CIFS‑Mehrfach‑Shares + NFS‑Home‑Share; Mountpoints unter `/$STORAGE_NAME/...`.
- Konfiguration wird über `STORAGE_IP`, `STORAGE_NAME`, `USER` parametrisiert; Credentials extern (`~/.smbcred`).
- Unmount‑Optionen für alle/einzelne Shares; Idempotenz über `mountpoint`‑Prüfung.

Implementierungsreferenzen:
- `dot_scripts/executable_syno-mount.sh:1`
- Beispiele/Notizen: `commands.md:1`, `notes.md:1`.

## Sicherheits‑Provisioning (Ubuntu, optional)

- Hardening‑Skript richtet neuen Admin‑User ein, konfiguriert SSH (Key‑Auth, Custom Port), UFW und Fail2Ban.
- Interaktiv mit Bestätigung, Logging, Rollback bei Fehler, Validierungen.
- Parameter per Flags oder im Skriptkopf; Nur mit Root ausführen.

Implementierungsreferenz:
- `dot_scripts/dev_ubuntu_secure_server.sh:1`.

## Git‑Konfiguration

- Globaler Editor `vim`, EOL‑Handhabung `autocrlf=input`, Whitespace‑Regeln; globale Ignore‑Datei.
- Komfort‑Aliase und `help.autocorrect=1`; Credential‑Cache (1h). Lokales Overlay via `~/.safe/gitconfig.local`.

Implementierungsreferenz:
- `dot_gitconfig:1`, `dot_gitignore_global:1`.

## Aliase und Hilfsskripte

- Navigations‑/ls‑/grep‑Aliase, Git‑Kurzbefehle, Python‑Venv‑Helpers, Docker‑Shortcuts.
- Synology‑Shortcuts (`syno-*`) verweisen auf lokale Skripte; passen an die eigene Struktur an.

Implementierungsreferenz:
- `dot_aliases:1`, `dot_scripts/*`.

## XDG‑Konformität (konkret)

- Config unter `$XDG_CONFIG_HOME` (Fish, systemd user, fastfetch), Data unter `$XDG_DATA_HOME` (Logos, Wallpapers), Cache unter `$XDG_CACHE_HOME` (npm global bin).
- RUNTIME unter `$XDG_RUNTIME_DIR` (ssh‑agent Socket).

Referenzübersicht: `XDG_VARS.md:1`.

## Geheimnisse & private Daten

- Keine Secrets im Repo. Lokale Files/Verzeichnisse außerhalb der Versionskontrolle (z. B. `~/.smbcred`, `~/.safe/*`).
- Git: `~/.safe/` ist global ignoriert (`dot_gitignore_global:1`).

## Installations‑/Apply‑Fluss (ChezMoi)

- Init: `chezmoi init <repo>`; Änderungen prüfen: `chezmoi diff`; Anwenden: `chezmoi -v[n] apply`.
- Push‑Flow via `chezmoi cd` → `chezmoi git -- ...` (siehe `README.md:1`, `README_DE.md:1`).

## Änderungsmanagement / Versionierung

- Änderungen zuerst als Spez‑Erweiterung/ADR‑Eintrag dokumentieren, dann implementieren.
- Scripts bleiben idempotent und defensiv (Prüfungen, `set -euo pipefail`, „opt‑in“ bei Systemeingriffen).

---

## ADR‑Lite: Entscheidungen mit Begründung

1) XDG‑Adoption und RUNTIME‑Sockel
- Entscheidung: Strikte XDG‑Pfade; ssh‑agent‑Socket unter `$XDG_RUNTIME_DIR`.
- Begründung: Vorhersagbarkeit, sauberes Scoping, Desktop/Server kompatibel.
- Implementiert in: `XDG_VARS.md:1`, `private_dot_config/systemd/user/ssh-agent.*:1`, `dot_env_common.tmpl:1`, `private_dot_config/fish/conf.d/00-env.fish.tmpl:1`.

2) Zentrales Env aus `data/env.yaml`
- Entscheidung: Eine Quelle steuert POSIX und Fish via Templates.
- Begründung: Konsistenz, weniger Drift, leicht austauschbar.
- Implementiert in: `data/env.yaml:1`, `dot_env_common.tmpl:1`, `private_dot_config/fish/conf.d/00-env.fish.tmpl:1`.

3) PATH‑Reihenfolge (User‑Bin vorn, npm‑Global optional)
- Entscheidung: `$HOME/.local/bin` voran; npm‑Global unter `$XDG_CACHE_HOME/npm-global/bin`.
- Begründung: Nutzerbinaries priorisieren; npm ohne globale Adminrechte.
- Implementiert in: `data/env.yaml:1`, Templates oben.

4) Opt‑in Installationen (rclone)
- Entscheidung: Installationsskripte laufen nur mit explizitem Opt‑in (`RCLONE_AUTO_INSTALL=1`).
- Begründung: Vermeidung gescheiterter non‑interactive „apply“‑Läufe; geringeres Risiko.
- Implementiert in: `run_once_install_rclone.sh:1`.

5) systemd User‑Units statt systemweiter Dienste
- Entscheidung: ssh‑agent als User‑Dienst/socket.
- Begründung: Sicherheit, Portabilität, kein Root nötig, korrekter Lifecycle.
- Implementiert in: `private_dot_config/systemd/user/ssh-agent.*:1`.

6) Bash Startup‑Strategie „ein Einstiegspunkt“
- Entscheidung: Login‑Shell via `~/.bash_profile` → `~/.profile` → `~/.bashrc`; POSIX lädt `~/.profile`.
- Begründung: Vermeidet doppelte Konfiguration, klarer Datenfluss.
- Implementiert in: `dot_profile:1`, `dot_bash_profile:1`, `dot_bashrc:1`.

7) Fastfetch als optionaler Komfort
- Entscheidung: Nur in interaktiven Shells, per Existenz‑Check, konfigurierbar.
- Begründung: Keine harten Abhängigkeiten; schneller Überblick bei Start.
- Implementiert in: `dot_bashrc:1`, `private_dot_config/fastfetch/*`.

8) NAS‑Mounts parametrisierbar und idempotent
- Entscheidung: CIFS/NFS‑Mounts aus Variablen, `mountpoint`‑Prüfung, Unmount‑Optionen.
- Begründung: Wiederholbarkeit ohne Seiteneffekte; keine Secrets im Repo.
- Implementiert in: `dot_scripts/executable_syno-mount.sh:1`.

9) Security‑Hardening als separates, zustimmungsbasiertes Skript
- Entscheidung: Ubuntu‑Hardening mit Confirm, Logging, Rollback, Validierung.
- Begründung: Sicherheit sensibel → nicht automatisch, sondern bewusst ausführen.
- Implementiert in: `dot_scripts/dev_ubuntu_secure_server.sh:1`.

10) Git: lokale Overlays und globale Ignore
- Entscheidung: Nutzer‑spezifische Overrides via `~/.safe/gitconfig.local`; `.safe/` global ignoriert.
- Begründung: Trennung von öffentlichen Defaults und privaten Daten.
- Implementiert in: `dot_gitconfig:1`, `dot_gitignore_global:1`.

---

## Offene Punkte / Erweiterungen

- Einheitlicher Secrets‑Pfad dokumentieren (`~/.config/chezmoi/age/` o. ä.) und optionales SOPS/age‑Setup.
- Test‑Playbooks (z. B. „smoke‑test“ für Env/PATH, ssh‑agent, fastfetch, rclone vorhanden?).
- Optional: Zsh‑Support analog Fish/POSIX, falls benötigt.

## Arbeitsweise: Spec‑Driven Development (kurz)

1) What/Why zuerst: Änderungsvorschlag hier im SPEC (Ziel, Constraints, Implikationen).
2) ADR‑Eintrag anlegen/erweitern (Entscheidung, Begründung, Alternativen, Auswirkungen, Rollback).
3) Minimal‑Implementierung in Templates/Skripten; idempotent und opt‑in bei Systemeingriffen.
4) Validierung: Dry‑Run (`chezmoi -vn apply`), dann Apply, manuelle Checks (ssh‑agent, PATH, Tools).
5) Iteration: Feedback einarbeiten, SPEC aktualisieren, Code nachziehen.

## Referenzen / Dateien

- `README.md:1`, `README_DE.md:1`, `SETUP.md:1` — Onboarding und Workflow.
- `commands.md:1`, `notes.md:1` — Beispiele/Notizen für lokale Workflows.
- Fastfetch: `private_dot_config/fastfetch/README.md:1`.

Ende der Spezifikation.

